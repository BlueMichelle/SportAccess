package com.sportaccess.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "reservations")
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "court_id", nullable = false)
    private Court court;

    @Column(nullable = false)
    private LocalDateTime fechaInicio;
    
    @Column(name = "resultado_partido")
    private String resultadoPartido;

    @Column(nullable = false)
    private LocalDateTime fechaFin;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReservationStatus estado = ReservationStatus.PENDIENTE;

    @Column(name = "qr_token")
    private String qrToken;
    
    @Column(name = "precio_material")
    private Double precioMaterial = 0.0;

    @Column(name = "detalles_material")
    private String detallesMaterial = "";

    @Column(name = "email_contacto")
    private String emailContacto;

    // Estados posibles de la reserva
    public enum ReservationStatus {
        PENDIENTE, CONFIRMADA, CANCELADA, COMPLETADA
    }

    // Constructor vacío requerido por JPA
    public Reservation() {}

    // --- GETTERS Y SETTERS ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    // Getter y setter
    public String getEmailContacto() { return emailContacto; }
    public void setEmailContacto(String emailContacto) { this.emailContacto = emailContacto; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Court getCourt() { return court; }
    public void setCourt(Court court) { this.court = court; }

    public LocalDateTime getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(LocalDateTime fechaInicio) { this.fechaInicio = fechaInicio; }

    public LocalDateTime getFechaFin() { return fechaFin; }
    public void setFechaFin(LocalDateTime fechaFin) { this.fechaFin = fechaFin; }

    public ReservationStatus getEstado() { return estado; }
    public void setEstado(ReservationStatus estado) { this.estado = estado; }

    public String getQrToken() { return qrToken; }
    public void setQrToken(String qrToken) { this.qrToken = qrToken; }
    public Double getPrecioMaterial() { return precioMaterial; }
    public void setPrecioMaterial(Double precioMaterial) { this.precioMaterial = precioMaterial; }

    public String getDetallesMaterial() { return detallesMaterial; }
    public void setDetallesMaterial(String detallesMaterial) { this.detallesMaterial = detallesMaterial; }
    
    public String getResultadoPartido() {
        return resultadoPartido;
    }

    public void setResultadoPartido(String resultadoPartido) {
        this.resultadoPartido = resultadoPartido;
    }
}