package com.uxia.uxilibris.dto;

import lombok.Data;

/**
 * DTO con las credenciales que el cliente envía al endpoint de inicio de sesión.
 *
 * <p>Recibido en el cuerpo de la petición {@code POST /api/auth/login}.</p>
 */
@Data
public class LoginRequest {

    /** Nombre de usuario con el que está registrado el usuario. */
    private String username;

    /** Contraseña en texto plano. Se compara con el hash BCrypt almacenado. */
    private String password;
}