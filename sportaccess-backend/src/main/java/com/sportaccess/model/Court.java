package com.sportaccess.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
@Entity
@Table(name = "courts")
public class Court {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombre;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CourtType tipo;

    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal precioPorHora;

    @Column(nullable = false)
    private Boolean activa = true;

    private String descripcion;

    @Column(name = "imagen_url", length = 500)
    @JsonProperty("imagen_url")
    private String imagenUrl;

    @JsonIgnore
    @OneToMany(mappedBy = "court", cascade = CascadeType.ALL)
    private List<Reservation> reservas;

    public enum CourtType {
        PADEL, TENIS, FUTBOL_SALA, BALONCESTO
    }

    // --- CONSTRUCTORES ---
    public Court() {}

    public Court(Long id, String nombre, CourtType tipo, BigDecimal precioPorHora, Boolean activa, String descripcion, String imagenUrl) {
        this.id = id;
        this.nombre = nombre;
        this.tipo = tipo;
        this.precioPorHora = precioPorHora;
        this.activa = activa;
        this.descripcion = descripcion;
        this.imagenUrl = imagenUrl;
    }

    // --- GETTERS Y SETTERS MANUALES (Para evitar errores de Lombok) ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public CourtType getTipo() { return tipo; }
    public void setTipo(CourtType tipo) { this.tipo = tipo; }

    public BigDecimal getPrecioPorHora() { return precioPorHora; }
    public void setPrecioPorHora(BigDecimal precioPorHora) { this.precioPorHora = precioPorHora; }

    public Boolean getActiva() { return activa; }
    public void setActiva(Boolean activa) { this.activa = activa; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getImagenUrl() { return imagenUrl; }
    public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }

    public List<Reservation> getReservas() { return reservas; }
    public void setReservas(List<Reservation> reservas) { this.reservas = reservas; }
}

