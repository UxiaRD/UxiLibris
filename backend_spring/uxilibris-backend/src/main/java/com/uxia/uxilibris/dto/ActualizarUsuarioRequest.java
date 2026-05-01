package com.uxia.uxilibris.dto;

import lombok.Data;

/**
 * DTO con los campos que el usuario puede modificar en su perfil.
 *
 * <p>Recibido en el cuerpo de la petición {@code PUT /api/auth/usuario/{id}}.
 * Solo se aplican los campos no nulos y no vacíos, por lo que el cliente
 * puede enviar únicamente los que desea cambiar.</p>
 *
 * <p>La verificación de {@link #passwordActual} es siempre obligatoria
 * para confirmar la identidad del usuario antes de aplicar cualquier cambio.</p>
 */
@Data
public class ActualizarUsuarioRequest {

    /**
     * Nuevo nombre de usuario. Si es {@code null} o vacío, no se modifica.
     * Debe ser único en el sistema.
     */
    private String nuevoUsername;

    /**
     * Nuevo correo electrónico. Si es {@code null} o vacío, no se modifica.
     * Debe ser único en el sistema.
     */
    private String nuevoEmail;

    /**
     * Nueva contraseña en texto plano. Si es {@code null} o vacía, la contraseña
     * actual no cambia.
     */
    private String nuevaPassword;

    /**
     * Contraseña actual del usuario en texto plano. Obligatoria en toda
     * petición de actualización para verificar la identidad.
     */
    private String passwordActual;
}