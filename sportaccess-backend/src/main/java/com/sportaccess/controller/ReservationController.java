package com.sportaccess.controller;

import com.sportaccess.model.*;
import com.sportaccess.repository.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "*") // Permite peticiones desde Flutter
public class ReservationController {

    private final ReservationRepository reservationRepository;
    private final UserRepository userRepository;
    private final CourtRepository courtRepository;
    private final com.sportaccess.service.EmailService emailService;

    public ReservationController(ReservationRepository rr, UserRepository ur, CourtRepository cr, com.sportaccess.service.EmailService emailService) {
        this.reservationRepository = rr;
        this.userRepository = ur;
        this.courtRepository = cr;
        this.emailService = emailService;
    }

    // --- 1. OBTENER TODAS LAS RESERVAS ---
    @GetMapping
    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    // --- 2. OBTENER HORARIOS OCUPADOS POR PISTA Y DÍA ---
    @GetMapping("/court/{courtId}/horarios")
    public ResponseEntity<List<Reservation>> getReservasPorPistaYDia(
            @PathVariable Long courtId,
            @RequestParam String fecha) {
        try {
            LocalDate dia = LocalDate.parse(fecha);
            LocalDateTime inicioDelDia = dia.atStartOfDay();
            LocalDateTime finDelDia = dia.atTime(LocalTime.MAX);

            List<Reservation> reservasActivas = reservationRepository.findReservasActivasPorPistaYRango(
                    courtId, inicioDelDia, finDelDia
            );

            return ResponseEntity.ok(reservasActivas);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // --- OBTENER TODAS LAS RESERVAS DE UN DÍA (Para el calendario general de Admin) ---
    @GetMapping("/date/{fecha}")
    public ResponseEntity<List<Reservation>> getReservationsByDate(@PathVariable String fecha) {
        try {
            LocalDate date = LocalDate.parse(fecha);
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.atTime(23, 59, 59);

            List<Reservation> reservasDelDia = reservationRepository.findByFechaInicioBetween(startOfDay, endOfDay);
            return ResponseEntity.ok(reservasDelDia);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // --- 3. CREAR NUEVA RESERVA (Adaptado para Invitados, Pagos y Recurrentes) ---
    @PostMapping
    public ResponseEntity<?> createReservation(
            @RequestBody Reservation res,
            @RequestParam(defaultValue = "1") int semanasRepeticion) {
        try {
            Long courtId = res.getCourt().getId();

            // C) BUSCAR PISTA
            Court court = courtRepository.findById(courtId)
                    .orElseThrow(() -> new RuntimeException("Pista no encontrada"));

            if (!court.getActiva()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Lo sentimos, esta pista está inactiva y no se puede reservar.");
            }

            // B) VALIDAR SI ES USUARIO APP O INVITADO
            User finalUser = null;
            boolean esInvitado = false;

            if (res.getUser() != null && res.getUser().getFirebaseUid() != null) {
                // Es un usuario de la App
                String uid = res.getUser().getFirebaseUid();
                String email = res.getUser().getEmail();

                finalUser = userRepository.findByFirebaseUid(uid)
                        .orElseGet(() -> userRepository.findByEmail(email).orElseGet(() -> {
                            User u = new User();
                            u.setFirebaseUid(uid);
                            u.setEmail(email != null ? email : uid + "@firebase.com");
                            u.setNombre(res.getUser().getNombre() != null ? res.getUser().getNombre() : "Usuario");
                            u.setTelefono("000000000");
                            u.setRol(User.Role.USER);
                            return userRepository.save(u);
                        }));
            } else if (res.getNombreInvitado() != null && !res.getNombreInvitado().isEmpty()) {
                // Es un Invitado creado por el Admin
                esInvitado = true;
            } else {
                return ResponseEntity.badRequest().body("Error: Faltan credenciales de usuario o nombre de invitado.");
            }

            // BUCLE PARA RESERVAS RECURRENTES
            Reservation ultimaReservaGuardada = null;

            for (int i = 0; i < semanasRepeticion; i++) {
                LocalDateTime inicioCalculado = res.getFechaInicio().plusWeeks(i);
                LocalDateTime finCalculado = res.getFechaFin().plusWeeks(i);

                boolean pistaOcupada = reservationRepository.existeSolape(courtId, inicioCalculado, finCalculado);
                if (pistaOcupada) {
                    return ResponseEntity.status(HttpStatus.CONFLICT)
                            .body("La pista ya está ocupada en el horario de la semana " + (i + 1));
                }

                Reservation nuevaReserva = new Reservation();
                nuevaReserva.setCourt(court);
                nuevaReserva.setUser(finalUser);
                nuevaReserva.setNombreInvitado(res.getNombreInvitado());
                nuevaReserva.setMetodoPago(res.getMetodoPago() != null ? res.getMetodoPago() : "TARJETA");
                nuevaReserva.setEstadoPago(res.getEstadoPago() != null ? res.getEstadoPago() : "PAGADO");

                nuevaReserva.setFechaInicio(inicioCalculado);
                nuevaReserva.setFechaFin(finCalculado);
                nuevaReserva.setQrToken(res.getQrToken() != null ? res.getQrToken() : "QR_" + System.currentTimeMillis() + "_" + i);
                nuevaReserva.setEstado(Reservation.ReservationStatus.CONFIRMADA);

                nuevaReserva.setPrecioMaterial(res.getPrecioMaterial());
                nuevaReserva.setDetallesMaterial(res.getDetallesMaterial());
                nuevaReserva.setEmailContacto(res.getEmailContacto());

                ultimaReservaGuardada = reservationRepository.save(nuevaReserva);

                if (i == 0 && !esInvitado) {
                    try {
                        emailService.sendReservationConfirmation(ultimaReservaGuardada);
                    } catch (Exception e) {
                        System.out.println("No se pudo enviar el correo: " + e.getMessage());
                    }
                }
            }

            return ResponseEntity.ok(ultimaReservaGuardada);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error interno: " + e.getMessage());
        }
    }

    // ✨ NUEVO: ACTUALIZAR RESERVA EXISTENTE (Para que no se duplique al editar)
    @PutMapping("/{id}")
    public ResponseEntity<?> updateReservation(@PathVariable Long id, @RequestBody Reservation resModificada) {
        try {
            Reservation reservaExistente = reservationRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

            reservaExistente.setMetodoPago(resModificada.getMetodoPago());
            reservaExistente.setEstadoPago(resModificada.getEstadoPago());
            reservaExistente.setFechaInicio(resModificada.getFechaInicio());
            reservaExistente.setFechaFin(resModificada.getFechaFin());

            // Si cambiamos la pista al editar
            if (resModificada.getCourt() != null) {
                reservaExistente.setCourt(courtRepository.findById(resModificada.getCourt().getId()).orElse(reservaExistente.getCourt()));
            }

            // Cambiar de App User a Invitado o viceversa
            if (resModificada.getNombreInvitado() != null && !resModificada.getNombreInvitado().isEmpty()) {
                reservaExistente.setNombreInvitado(resModificada.getNombreInvitado());
                reservaExistente.setUser(null);
            } else if (resModificada.getUser() != null && resModificada.getUser().getId() != null) {
                reservaExistente.setUser(userRepository.findById(resModificada.getUser().getId()).orElse(null));
                reservaExistente.setNombreInvitado(null);
            }

            reservationRepository.save(reservaExistente);
            return ResponseEntity.ok(reservaExistente);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al actualizar la reserva: " + e.getMessage());
        }
    }

    @PutMapping("/{id}/resultado")
    public ResponseEntity<?> updateResultado(@PathVariable Long id, @RequestBody String resultado) {
        return reservationRepository.findById(id).map(res -> {
            res.setResultadoPartido(resultado);
            reservationRepository.save(res);
            return ResponseEntity.ok(res);
        }).orElse(ResponseEntity.notFound().build());
    }

    // --- 4. CANCELAR RESERVA (Borrado Lógico) ---
    @PutMapping("/{id}/cancel")
    public ResponseEntity<?> cancelarReserva(@PathVariable Long id) {
        try {
            Optional<Reservation> reservaOpt = reservationRepository.findById(id);
            if (reservaOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            Reservation reserva = reservaOpt.get();
            reserva.setEstado(Reservation.ReservationStatus.CANCELADA);
            reservationRepository.save(reserva);

            return ResponseEntity.ok("Reserva cancelada correctamente");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al cancelar");
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReservation(@PathVariable Long id) {
        if (!reservationRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        reservationRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}