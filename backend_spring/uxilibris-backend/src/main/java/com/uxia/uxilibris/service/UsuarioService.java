package com.uxia.uxilibris.service;

import com.uxia.uxilibris.dto.LoginRequest;
import com.uxia.uxilibris.entity.Usuario;
import com.uxia.uxilibris.repository.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UsuarioService {
    @Autowired
    private UsuarioRepository usuarioRepository;

    // Método para registrar (recuerda que en el futuro usaremos BCrypt aquí)
    @Transactional
    public boolean guardar(Usuario usuario) {
        // Comprobamos si ya existe por email o username
        if (usuarioRepository.findByEmail(usuario.getEmail()).isPresent() ||
                usuarioRepository.findByUsername(usuario.getUsername()).isPresent()) {
            return false; // Esto hará que Flutter reciba un error y no se registre
        }
        usuarioRepository.save(usuario);
        return true;
    }

    public boolean verificar(LoginRequest loginRequest) {
        // 1. Buscamos al usuario por email en la tabla 'usuarios'
        return usuarioRepository.findByUsername(loginRequest.getUsername())
                .map(usuario -> {
                    // 2. Comparamos la contraseña (por ahora texto plano, luego hash)
                    return usuario.getPassword().equals(loginRequest.getPassword());
                })
                .orElse(false); // Si el usuario no existe, devuelve false
    }
}
