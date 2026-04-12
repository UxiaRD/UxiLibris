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

@Service
public class UsuarioService {
    @Autowired
    private UsuarioRepository usuarioRepository;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    @Transactional
    public boolean guardar(Usuario usuario) {
        if (usuarioRepository.findByEmail(usuario.getEmail()).isPresent() ||
                usuarioRepository.findByUsername(usuario.getUsername()).isPresent()) {
            return false;
        }
        // Guardamos la contraseña cifrada con BCrypt
        usuario.setPassword(encoder.encode(usuario.getPassword()));
        usuarioRepository.save(usuario);
        return true;
    }

    public Optional<LoginResponse> verificar(LoginRequest loginRequest) {
        return usuarioRepository.findByUsername(loginRequest.getUsername())
                .filter(u -> encoder.matches(loginRequest.getPassword(), u.getPassword()))
                .map(u -> new LoginResponse(u.getId(), u.getUsername(), u.getEmail()));
    }

    /**
     * Actualiza los datos del usuario. Requiere la contraseña actual para verificar identidad.
     * @return LoginResponse con los datos actualizados, o vacío si la contraseña es incorrecta.
     * @throws IllegalArgumentException si el nuevo username o email ya está en uso.
     */
    @Transactional
    public Optional<LoginResponse> actualizar(Long id, ActualizarUsuarioRequest req) {
        Usuario usuario = usuarioRepository.findById(id).orElse(null);
        if (usuario == null) return Optional.empty();

        // Verificar contraseña actual
        if (!encoder.matches(req.getPasswordActual(), usuario.getPassword())) {
            return Optional.empty();
        }

        // Cambiar username si es distinto y no está ocupado
        if (req.getNuevoUsername() != null && !req.getNuevoUsername().isBlank()
                && !req.getNuevoUsername().equals(usuario.getUsername())) {
            if (usuarioRepository.findByUsername(req.getNuevoUsername()).isPresent()) {
                throw new IllegalArgumentException("El nombre de usuario ya está en uso");
            }
            usuario.setUsername(req.getNuevoUsername());
        }

        // Cambiar email si es distinto y no está ocupado
        if (req.getNuevoEmail() != null && !req.getNuevoEmail().isBlank()
                && !req.getNuevoEmail().equals(usuario.getEmail())) {
            if (usuarioRepository.findByEmail(req.getNuevoEmail()).isPresent()) {
                throw new IllegalArgumentException("El correo electrónico ya está en uso");
            }
            usuario.setEmail(req.getNuevoEmail());
        }

        // Cambiar contraseña si se proporcionó una nueva
        if (req.getNuevaPassword() != null && !req.getNuevaPassword().isBlank()) {
            usuario.setPassword(encoder.encode(req.getNuevaPassword()));
        }

        usuarioRepository.save(usuario);
        return Optional.of(new LoginResponse(usuario.getId(), usuario.getUsername(), usuario.getEmail()));
    }
}
