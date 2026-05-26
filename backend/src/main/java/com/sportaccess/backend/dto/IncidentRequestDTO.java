package com.sportaccess.backend.dto;

import lombok.Data;

@Data
public class IncidentRequestDTO {
    private Long courtId;
    private Long reportedById;
    private Long reservationId; // Puede ser null si el usuario reporta algo sin tener reserva
    private String descripcion;
    private String imagenUrl;
}
