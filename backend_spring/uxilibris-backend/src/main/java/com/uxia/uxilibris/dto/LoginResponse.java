package com.uxia.uxilibris.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * DTO con los datos del usuario que se devuelven tras un inicio de sesión
 * o actualización de cuenta correctos.
 *
 * <p>Devuelto por {@code POST /api/auth/login} y {@code PUT /api/auth/usuario/{id}}.
 * No incluye la contraseña ni ningún otro dato sensible.</p>
 */
@Data
@AllArgsConstructor
public class LoginResponse {

    /** Identificador único del usuario en la base de datos. */
    private Long userId;

    /** Nombre de usuario actualizado. */
    private String username;

    /** Correo electrónico actualizado. */
    private String email;
}