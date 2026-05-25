package com.sportaccess.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
// 🔴 IMPORTANTE: Añadimos esta librería para el JSON
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.time.LocalDateTime;

@Entity
@Table(name = "incidents")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Incident {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reservation_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"}) // 🔴 MAGIA AQUÍ
    private Reservation reservation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "court_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"}) // 🔴 MAGIA AQUÍ
    private Court court;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reported_by", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"}) // 🔴 MAGIA AQUÍ
    private User reportadoPor;

    @Column(nullable = false, length = 500)
    private String descripcion;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String imagenBase64;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private IncidentStatus estado = IncidentStatus.ABIERTA;

    @Column(nullable = false, updatable = false)
    private LocalDateTime fechaReporte = LocalDateTime.now();

    private LocalDateTime fechaResolucion;

    private String notasResolucion;

    public enum IncidentStatus {
        ABIERTA, EN_PROCESO, RESUELTA
    }
}