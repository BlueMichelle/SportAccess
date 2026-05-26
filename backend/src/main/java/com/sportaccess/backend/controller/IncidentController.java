package com.sportaccess.backend.controller;

import com.sportaccess.backend.model.Court;
import com.sportaccess.backend.model.Incident;
import com.sportaccess.backend.model.Reservation;
import com.sportaccess.backend.model.User;
import com.sportaccess.backend.dto.IncidentRequestDTO;
import com.sportaccess.backend.repository.CourtRepository;
import com.sportaccess.backend.repository.IncidentRepository;
import com.sportaccess.backend.repository.ReservationRepository;
import com.sportaccess.backend.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/incidents")
@CrossOrigin(origins = "*") // 🔴
public class IncidentController {

    @Autowired
    private IncidentRepository incidentRepository;

    @Autowired
    private CourtRepository courtRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ReservationRepository reservationRepository;

    // ==========================================
    // 📱 ENDPOINTS PARA LA APP MÓVIL (FLUTTER)
    // ==========================================

    // 1. Crear una incidencia
    @PostMapping
    public ResponseEntity<?> createIncident(@RequestBody IncidentRequestDTO request) {

        // 1.1 Buscar los datos reales en la BD usando los IDs
        Court court = courtRepository.findById(request.getCourtId()).orElse(null);
        User user = userRepository.findById(request.getReportedById()).orElse(null);

        if (court == null || user == null) {
            return ResponseEntity.badRequest().body("Error: Pista o Usuario no encontrados.");
        }

        // 1.2 Crear la incidencia y rellenar los datos
        Incident newIncident = new Incident();
        newIncident.setCourt(court);
        newIncident.setReportadoPor(user);
        newIncident.setDescripcion(request.getDescripcion());
        newIncident.setEstado(Incident.IncidentStatus.ABIERTA); // Por defecto
        newIncident.setFechaReporte(LocalDateTime.now());
        newIncident.setImagenUrl(request.getImagenUrl());

        // 1.3 Si nos mandan una reserva, la añadimos
        if (request.getReservationId() != null) {
            Reservation reservation = reservationRepository.findById(request.getReservationId()).orElse(null);
            newIncident.setReservation(reservation);
        }

        // 1.4 Guardar y devolver
        Incident savedIncident = incidentRepository.save(newIncident);
        return ResponseEntity.ok(savedIncident);
    }

    // 2. Ver las incidencias de un usuario concreto
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Incident>> getIncidentsByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(incidentRepository.findByReportadoPorId(userId));
    }


    // ==========================================
    // 💻 ENDPOINTS PARA EL PANEL ADMIN WEB
    // ==========================================

    // 3. Ver TODAS las incidencias (Para el panel de control)
    @GetMapping
    public ResponseEntity<List<Incident>> getAllIncidents() {
        return ResponseEntity.ok(incidentRepository.findAll());
    }

    // 4. Cambiar el estado de una incidencia (Ej: de ABIERTA a RESUELTA)
    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateIncidentStatus(
            @PathVariable Long id,
            @RequestParam Incident.IncidentStatus newStatus,
            @RequestParam(required = false) String notas) {

        Incident incident = incidentRepository.findById(id).orElse(null);

        if (incident == null) {
            return ResponseEntity.notFound().build();
        }

        incident.setEstado(newStatus);

        if (newStatus == Incident.IncidentStatus.RESUELTA) {
            incident.setFechaResolucion(LocalDateTime.now());
            incident.setNotasResolucion(notas);
        }

        incidentRepository.save(incident);
        return ResponseEntity.ok(incident);
    }
}
