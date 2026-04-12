package com.uxia.uxilibris.dto;

import lombok.Data;

@Data
public class ActualizarUsuarioRequest {
    private String nuevoUsername;
    private String nuevoEmail;
    private String nuevaPassword;   // opcional: vacío = no cambiar
    private String passwordActual;  // obligatorio para verificar identidad
}