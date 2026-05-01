package com.uxia.uxilibris.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * Entidad que representa un usuario registrado en UxiLibris.
 *
 * <p>Cada usuario tiene su propia biblioteca de libros y sagas. La contraseña
 * se almacena <strong>siempre cifrada con BCrypt</strong>; nunca en texto plano.</p>
 *
 * <p>Mapeada a la tabla {@code usuarios}.</p>
 */
@Entity
@Table(name = "usuarios")
@Data
public class Usuario {

    /** Identificador único generado automáticamente por la base de datos. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Nombre de usuario único para identificarse en el inicio de sesión. */
    @Column(unique = true)
    private String username;

    /** Correo electrónico único asociado a la cuenta. */
    @Column(unique = true)
    private String email;

    /**
     * Contraseña del usuario almacenada como hash BCrypt.
     *
     * <p>Nunca se devuelve en los DTOs de respuesta; se utiliza únicamente
     * para verificar credenciales en {@link com.uxia.uxilibris.service.UsuarioService}.</p>
     */
    private String password;
}