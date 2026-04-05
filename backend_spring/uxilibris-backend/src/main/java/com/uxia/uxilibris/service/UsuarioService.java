package com.uxia.uxilibris.service;

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
                .map(u -> new LoginResponse(u.getId(), u.getUsername()));
    }
}
