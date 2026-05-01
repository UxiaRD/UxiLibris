package com.uxia.uxilibris.controller;

import com.uxia.uxilibris.dto.ActualizarUsuarioRequest;
import com.uxia.uxilibris.dto.LoginRequest;
import com.uxia.uxilibris.dto.LoginResponse;
import com.uxia.uxilibris.entity.Usuario;
import com.uxia.uxilibris.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST que gestiona el registro, inicio de sesión y
 * actualización de datos de cuenta de los usuarios.
 *
 * <p>Base URL: {@code /api/auth}</p>
 */
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UsuarioService usuarioService;

    /**
     * Registra un nuevo usuario en el sistema.
     *
     * <p>{@code POST /api/auth/registro}</p>
     *
     * @param usuario entidad con username, email y contraseña en texto plano
     * @return {@code 200 OK} con {@code true} si el registro fue exitoso;
     *         {@code 200 OK} con {@code false} si el email o username ya existen
     */
    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@RequestBody Usuario usuario) {
        return ResponseEntity.ok(usuarioService.guardar(usuario));
    }

    /**
     * Autentica a un usuario con sus credenciales.
     *
     * <p>{@code POST /api/auth/login}</p>
     *
     * @param loginRequest DTO con username y contraseña
     * @return {@code 200 OK} con {@link LoginResponse} si las credenciales son válidas;
     *         {@code 401 Unauthorized} si son incorrectas
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        return usuarioService.verificar(loginRequest)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error de credenciales"));
    }

    /**
     * Actualiza el username, el email y/o la contraseña del usuario indicado.
     *
     * <p>{@code PUT /api/auth/usuario/{id}}</p>
     *
     * <p>Solo se modifican los campos no nulos del request. La contraseña
     * actual siempre es obligatoria para confirmar la identidad.</p>
     *
     * @param id  identificador del usuario a actualizar
     * @param req DTO con los nuevos valores y la contraseña de verificación
     * @return {@code 200 OK} con {@link LoginResponse} actualizado si la operación es exitosa;
     *         {@code 401 Unauthorized} si la contraseña actual es incorrecta;
     *         {@code 409 Conflict} si el nuevo username o email ya están en uso
     */
    @PutMapping("/usuario/{id}")
    public ResponseEntity<?> actualizar(@PathVariable Long id,
                                        @RequestBody ActualizarUsuarioRequest req) {
        try {
            return usuarioService.actualizar(id, req)
                    .<ResponseEntity<?>>map(ResponseEntity::ok)
                    .orElse(ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Contraseña incorrecta"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
        }
    }
}