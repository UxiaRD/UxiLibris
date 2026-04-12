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

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@RequestBody Usuario usuario) {
        return ResponseEntity.ok(usuarioService.guardar(usuario));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        return usuarioService.verificar(loginRequest)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error de credenciales"));
    }

    // PUT /api/auth/usuario/{id} → actualiza username, email y/o contraseña
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
