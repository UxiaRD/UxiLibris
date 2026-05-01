package com.uxia.uxilibris.service;

import com.uxia.uxilibris.dto.ActualizarUsuarioRequest;
import com.uxia.uxilibris.dto.LoginRequest;
import com.uxia.uxilibris.dto.LoginResponse;
import com.uxia.uxilibris.entity.Usuario;
import com.uxia.uxilibris.repository.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Servicio que gestiona el ciclo de vida de los usuarios: registro,
 * autenticación y actualización de datos de cuenta.
 *
 * <p>Las contraseñas se cifran siempre con <strong>BCrypt</strong> antes de
 * persistirlas y nunca se almacenan ni devuelven en texto plano.</p>
 */
@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    /** Codificador BCrypt compartido por todos los métodos del servicio. */
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    /**
     * Registra un nuevo usuario en el sistema.
     *
     * <p>Antes de persistir verifica que el email y el username no estén
     * ya en uso. Si alguno de los dos está ocupado, no se crea el usuario
     * y el método devuelve {@code false}.</p>
     *
     * @param usuario entidad con los datos del nuevo usuario (contraseña en texto plano)
     * @return {@code true} si el usuario se creó correctamente;
     *         {@code false} si el email o el username ya existen
     */
    @Transactional
    public boolean guardar(Usuario usuario) {
        if (usuarioRepository.findByEmail(usuario.getEmail()).isPresent() ||
                usuarioRepository.findByUsername(usuario.getUsername()).isPresent()) {
            return false;
        }
        usuario.setPassword(encoder.encode(usuario.getPassword()));
        usuarioRepository.save(usuario);
        return true;
    }

    /**
     * Verifica las credenciales de inicio de sesión.
     *
     * <p>Busca al usuario por username y compara la contraseña proporcionada
     * con el hash BCrypt almacenado. Si la verificación es correcta, devuelve
     * un {@link LoginResponse} con los datos públicos del usuario.</p>
     *
     * @param loginRequest DTO con el username y la contraseña en texto plano
     * @return {@code Optional} con los datos del usuario si las credenciales son válidas;
     *         vacío si el usuario no existe o la contraseña es incorrecta
     */
    public Optional<LoginResponse> verificar(LoginRequest loginRequest) {
        return usuarioRepository.findByUsername(loginRequest.getUsername())
                .filter(u -> encoder.matches(loginRequest.getPassword(), u.getPassword()))
                .map(u -> new LoginResponse(u.getId(), u.getUsername(), u.getEmail()));
    }

    /**
     * Actualiza los datos de cuenta de un usuario existente.
     *
     * <p>Solo se modifican los campos no nulos y no vacíos del request.
     * La contraseña actual es obligatoria para confirmar la identidad;
     * si no coincide, el método devuelve {@code Optional.empty()} sin
     * aplicar ningún cambio.</p>
     *
     * @param id  identificador del usuario a actualizar
     * @param req DTO con los nuevos valores y la contraseña de verificación
     * @return {@code Optional} con los datos actualizados si la operación fue exitosa;
     *         vacío si el usuario no existe o la contraseña actual es incorrecta
     * @throws IllegalArgumentException si el nuevo username o email ya está en uso
     *                                  por otro usuario
     */
    @Transactional
    public Optional<LoginResponse> actualizar(Long id, ActualizarUsuarioRequest req) {
        Usuario usuario = usuarioRepository.findById(id).orElse(null);
        if (usuario == null) return Optional.empty();

        if (!encoder.matches(req.getPasswordActual(), usuario.getPassword())) {
            return Optional.empty();
        }

        if (req.getNuevoUsername() != null && !req.getNuevoUsername().isBlank()
                && !req.getNuevoUsername().equals(usuario.getUsername())) {
            if (usuarioRepository.findByUsername(req.getNuevoUsername()).isPresent()) {
                throw new IllegalArgumentException("El nombre de usuario ya está en uso");
            }
            usuario.setUsername(req.getNuevoUsername());
        }

        if (req.getNuevoEmail() != null && !req.getNuevoEmail().isBlank()
                && !req.getNuevoEmail().equals(usuario.getEmail())) {
            if (usuarioRepository.findByEmail(req.getNuevoEmail()).isPresent()) {
                throw new IllegalArgumentException("El correo electrónico ya está en uso");
            }
            usuario.setEmail(req.getNuevoEmail());
        }

        if (req.getNuevaPassword() != null && !req.getNuevaPassword().isBlank()) {
            usuario.setPassword(encoder.encode(req.getNuevaPassword()));
        }

        usuarioRepository.save(usuario);
        return Optional.of(new LoginResponse(usuario.getId(), usuario.getUsername(), usuario.getEmail()));
    }
}