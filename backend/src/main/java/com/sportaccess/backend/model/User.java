package com.sportaccess.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "firebase_uid", unique = true, nullable = false)
    private String firebaseUid;

    @Column(name = "email", unique = true, nullable = false)
    private String email;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "telefono", nullable = true)
    private String telefono;

    @Enumerated(EnumType.STRING)
    @Column(name = "rol", length = 20, nullable = false)
    private Role rol = Role.USER;

    @Column(name = "fecha_registro", nullable = false, updatable = false)
    private LocalDateTime fechaRegistro = LocalDateTime.now();

    @Column(name = "activo", nullable = false)
    private Boolean activo = true;

    public enum Role {
        USER, ADMIN
    }

    public User() {}

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getFirebaseUid() { return firebaseUid; }
    public void setFirebaseUid(String firebaseUid) { this.firebaseUid = firebaseUid; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    public Role getRol() { return rol; }
    public void setRol(Role rol) { this.rol = rol; }
    public LocalDateTime getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(LocalDateTime fechaRegistro) { this.fechaRegistro = fechaRegistro; }
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
}
