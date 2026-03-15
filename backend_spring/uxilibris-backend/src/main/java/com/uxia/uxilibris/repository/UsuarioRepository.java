package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    // Spring Data JPA crea la consulta automáticamente basándose en el nombre
    Optional<Usuario> findByEmail(String email);
    Optional<Usuario> findByUsername(String username);
}
