package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Usuario;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class UsuarioRepositoryTest {

    @Autowired
    private TestEntityManager em;

    @Autowired
    private UsuarioRepository usuarioRepository;

    private Usuario persistirUsuario(String username, String email) {
        Usuario u = new Usuario();
        u.setUsername(username);
        u.setEmail(email);
        u.setPassword("$2a$10$hashedpassword");
        return em.persistFlushFind(u);
    }

    @Test
    void findByUsername_existente_returnsUsuario() {
        persistirUsuario("uxia", "uxia@test.com");

        Optional<Usuario> resultado = usuarioRepository.findByUsername("uxia");

        assertThat(resultado).isPresent();
        assertThat(resultado.get().getEmail()).isEqualTo("uxia@test.com");
    }

    @Test
    void findByUsername_noExistente_returnsEmpty() {
        Optional<Usuario> resultado = usuarioRepository.findByUsername("fantasma");

        assertThat(resultado).isEmpty();
    }

    @Test
    void findByEmail_existente_returnsUsuario() {
        persistirUsuario("usuario2", "usuario2@test.com");

        Optional<Usuario> resultado = usuarioRepository.findByEmail("usuario2@test.com");

        assertThat(resultado).isPresent();
        assertThat(resultado.get().getUsername()).isEqualTo("usuario2");
    }

    @Test
    void findByEmail_noExistente_returnsEmpty() {
        Optional<Usuario> resultado = usuarioRepository.findByEmail("no@existe.com");

        assertThat(resultado).isEmpty();
    }

    @Test
    void save_persisteYAsignaId() {
        Usuario u = new Usuario();
        u.setUsername("nuevo");
        u.setEmail("nuevo@test.com");
        u.setPassword("hashed");

        Usuario guardado = usuarioRepository.save(u);

        assertThat(guardado.getId()).isNotNull();
    }
}