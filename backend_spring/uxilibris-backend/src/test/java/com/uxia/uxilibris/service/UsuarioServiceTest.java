package com.uxia.uxilibris.service;

import com.uxia.uxilibris.dto.LoginRequest;
import com.uxia.uxilibris.dto.LoginResponse;
import com.uxia.uxilibris.entity.Usuario;
import com.uxia.uxilibris.repository.UsuarioRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UsuarioServiceTest {

    @Mock
    private UsuarioRepository usuarioRepository;

    @InjectMocks
    private UsuarioService usuarioService;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    // ── guardar ───────────────────────────────────────────────────────────────

    @Test
    void guardar_usuarioNuevo_returnsTrueYHasheaPassword() {
        when(usuarioRepository.findByEmail(any())).thenReturn(Optional.empty());
        when(usuarioRepository.findByUsername(any())).thenReturn(Optional.empty());
        when(usuarioRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        Usuario usuario = new Usuario();
        usuario.setUsername("nuevousuario");
        usuario.setEmail("nuevo@test.com");
        usuario.setPassword("plaintextpassword");

        boolean resultado = usuarioService.guardar(usuario);

        assertThat(resultado).isTrue();
        assertThat(usuario.getPassword()).doesNotContain("plaintextpassword");
        assertThat(encoder.matches("plaintextpassword", usuario.getPassword())).isTrue();
        verify(usuarioRepository).save(usuario);
    }

    @Test
    void guardar_emailYaExistente_returnsFalseYNoGuarda() {
        Usuario existente = new Usuario();
        existente.setEmail("ocupado@test.com");
        when(usuarioRepository.findByEmail("ocupado@test.com")).thenReturn(Optional.of(existente));

        Usuario nuevo = new Usuario();
        nuevo.setUsername("cualquiera");
        nuevo.setEmail("ocupado@test.com");
        nuevo.setPassword("password");

        boolean resultado = usuarioService.guardar(nuevo);

        assertThat(resultado).isFalse();
        verify(usuarioRepository, never()).save(any());
    }

    @Test
    void guardar_usernameYaExistente_returnsFalseYNoGuarda() {
        when(usuarioRepository.findByEmail(any())).thenReturn(Optional.empty());
        Usuario existente = new Usuario();
        existente.setUsername("ocupado");
        when(usuarioRepository.findByUsername("ocupado")).thenReturn(Optional.of(existente));

        Usuario nuevo = new Usuario();
        nuevo.setUsername("ocupado");
        nuevo.setEmail("libre@test.com");
        nuevo.setPassword("password");

        boolean resultado = usuarioService.guardar(nuevo);

        assertThat(resultado).isFalse();
        verify(usuarioRepository, never()).save(any());
    }

    // ── verificar ─────────────────────────────────────────────────────────────

    @Test
    void verificar_credencialesCorrectas_returnsLoginResponse() {
        String passwordPlana = "miPassword123";
        Usuario usuario = new Usuario();
        usuario.setId(1L);
        usuario.setUsername("usuario");
        usuario.setEmail("usuario@test.com");
        usuario.setPassword(encoder.encode(passwordPlana));
        when(usuarioRepository.findByUsername("usuario")).thenReturn(Optional.of(usuario));

        LoginRequest request = new LoginRequest();
        request.setUsername("usuario");
        request.setPassword(passwordPlana);

        Optional<LoginResponse> resultado = usuarioService.verificar(request);

        assertThat(resultado).isPresent();
        assertThat(resultado.get().getUsername()).isEqualTo("usuario");
        assertThat(resultado.get().getEmail()).isEqualTo("usuario@test.com");
        assertThat(resultado.get().getUserId()).isEqualTo(1L);
    }

    @Test
    void verificar_passwordIncorrecta_returnsEmpty() {
        Usuario usuario = new Usuario();
        usuario.setUsername("usuario");
        usuario.setPassword(encoder.encode("passwordCorrecta"));
        when(usuarioRepository.findByUsername("usuario")).thenReturn(Optional.of(usuario));

        LoginRequest request = new LoginRequest();
        request.setUsername("usuario");
        request.setPassword("passwordIncorrecta");

        Optional<LoginResponse> resultado = usuarioService.verificar(request);

        assertThat(resultado).isEmpty();
    }

    @Test
    void verificar_usuarioNoExistente_returnsEmpty() {
        when(usuarioRepository.findByUsername(any())).thenReturn(Optional.empty());

        LoginRequest request = new LoginRequest();
        request.setUsername("noexiste");
        request.setPassword("cualquiera");

        Optional<LoginResponse> resultado = usuarioService.verificar(request);

        assertThat(resultado).isEmpty();
    }
}