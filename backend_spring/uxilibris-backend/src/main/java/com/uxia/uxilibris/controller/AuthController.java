package com.uxia.uxilibris.controller;

import com.uxia.uxilibris.dto.LoginRequest;
import com.uxia.uxilibris.entity.Usuario;
import com.uxia.uxilibris.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@RequestBody Usuario usuario) {
        // Lógica para guardar usuario (con cifrado de contraseña)
        return ResponseEntity.ok(usuarioService.guardar(usuario));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        // Lógica para verificar credenciales
        boolean esValido = usuarioService.verificar(loginRequest);
        if(esValido) return ResponseEntity.ok("Login correcto");
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error de credenciales");
    }
}
