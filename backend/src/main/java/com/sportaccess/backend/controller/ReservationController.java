package com.sportaccess.backend.controller;

import com.sportaccess.backend.model.Court;
import com.sportaccess.backend.model.Reservation;
import com.sportaccess.backend.model.User;
import com.sportaccess.backend.repository.CourtRepository;
import com.sportaccess.backend.repository.ReservationRepository;
import com.sportaccess.backend.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/reservations")
public class ReservationController {

    private static final int MAX_SEMANAS_REPETICION = 52;

    private final ReservationRepository reservationRepository;
    private final UserRepository userRepository;
    private final CourtRepository courtRepository;

    public ReservationController(ReservationRepository rr, UserRepository ur, CourtRepository cr) {
        this.reservationRepository = rr;
        this.userRepository = ur;
        this.courtRepository = cr;
    }

    @GetMapping
    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    @GetMapping("/court/{courtId}/horarios")
    public ResponseEntity<List<Reservation>> getReservasPorPistaYDia(
            @PathVariable Long courtId,
            @RequestParam String fecha) {
        try {
            LocalDate dia = LocalDate.parse(fecha);
            LocalDateTime inicioDelDia = dia.atStartOfDay();
            LocalDateTime finDelDia = dia.atTime(LocalTime.MAX);

            return ResponseEntity.ok(reservationRepository.findReservasActivasPorPistaYRango(
                    courtId, inicioDelDia, finDelDia
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/date/{fecha}")
    public ResponseEntity<List<Reservation>> getReservationsByDate(@PathVariable String fecha) {
        try {
            LocalDate dia = LocalDate.parse(fecha);
            return ResponseEntity.ok(reservationRepository.findByFechaInicioBetween(
                    dia.atStartOfDay(),
                    dia.atTime(LocalTime.MAX)
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping
    @Transactional
    public ResponseEntity<?> createReservation(
            @RequestBody Reservation res,
            @RequestParam(defaultValue = "1") int semanasRepeticion) {
        try {
            int semanas = normalizarSemanas(semanasRepeticion);
            Court court = getReservableCourt(res);
            validarFechas(res.getFechaInicio(), res.getFechaFin());

            User user = resolverUsuario(res);
            String nombreInvitado = normalizarTexto(res.getNombreInvitado());
            if (user == null && nombreInvitado == null) {
                return ResponseEntity.badRequest().body("Faltan credenciales de usuario o nombre de invitado.");
            }

            for (int i = 0; i < semanas; i++) {
                LocalDateTime inicio = res.getFechaInicio().plusWeeks(i);
                LocalDateTime fin = res.getFechaFin().plusWeeks(i);
                if (reservationRepository.existeSolape(court.getId(), inicio, fin)) {
                    return ResponseEntity.status(HttpStatus.CONFLICT)
                            .body("La pista ya esta ocupada en el horario de la semana " + (i + 1) + ".");
                }
            }

            Reservation ultimaReservaGuardada = null;
            for (int i = 0; i < semanas; i++) {
                Reservation nuevaReserva = new Reservation();
                nuevaReserva.setCourt(court);
                nuevaReserva.setUser(user);
                nuevaReserva.setNombreInvitado(user == null ? nombreInvitado : null);
                nuevaReserva.setFechaInicio(res.getFechaInicio().plusWeeks(i));
                nuevaReserva.setFechaFin(res.getFechaFin().plusWeeks(i));
                nuevaReserva.setEstado(Reservation.ReservationStatus.CONFIRMADA);
                nuevaReserva.setQrToken(crearQrToken(res.getQrToken(), i));
                copiarCamposOpcionales(res, nuevaReserva);

                ultimaReservaGuardada = reservationRepository.save(nuevaReserva);
            }

            return ResponseEntity.ok(ultimaReservaGuardada);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error interno: " + e.getMessage());
        }
    }

    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> updateReservation(@PathVariable Long id, @RequestBody Reservation resModificada) {
        try {
            Reservation reservaExistente = reservationRepository.findById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Reserva no encontrada."));

            Court court = getReservableCourt(resModificada);
            validarFechas(resModificada.getFechaInicio(), resModificada.getFechaFin());

            if (reservationRepository.existeSolapeExcluyendoReserva(
                    id, court.getId(), resModificada.getFechaInicio(), resModificada.getFechaFin())) {
                return ResponseEntity.status(HttpStatus.CONFLICT)
                        .body("La pista ya esta ocupada en ese horario.");
            }

            User user = resolverUsuario(resModificada);
            String nombreInvitado = normalizarTexto(resModificada.getNombreInvitado());
            if (user == null && nombreInvitado == null) {
                return ResponseEntity.badRequest().body("Faltan credenciales de usuario o nombre de invitado.");
            }

            reservaExistente.setCourt(court);
            reservaExistente.setUser(user);
            reservaExistente.setNombreInvitado(user == null ? nombreInvitado : null);
            reservaExistente.setFechaInicio(resModificada.getFechaInicio());
            reservaExistente.setFechaFin(resModificada.getFechaFin());
            if (resModificada.getEstado() != null) {
                reservaExistente.setEstado(resModificada.getEstado());
            }
            copiarCamposOpcionales(resModificada, reservaExistente);

            return ResponseEntity.ok(reservationRepository.save(reservaExistente));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al actualizar la reserva: " + e.getMessage());
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

    @PutMapping("/{id}/cancel")
    public ResponseEntity<?> cancelarReserva(@PathVariable Long id) {
        Optional<Reservation> reservaOpt = reservationRepository.findById(id);
        if (reservaOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Reservation reserva = reservaOpt.get();
        reserva.setEstado(Reservation.ReservationStatus.CANCELADA);
        return ResponseEntity.ok(reservationRepository.save(reserva));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReservation(@PathVariable Long id) {
        if (!reservationRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        reservationRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    private Court getReservableCourt(Reservation reservation) {
        if (reservation.getCourt() == null || reservation.getCourt().getId() == null) {
            throw new IllegalArgumentException("La pista es obligatoria.");
        }

        Court court = courtRepository.findById(reservation.getCourt().getId())
                .orElseThrow(() -> new IllegalArgumentException("Pista no encontrada."));

        if (Boolean.FALSE.equals(court.getActiva())) {
            throw new IllegalArgumentException("La pista esta inactiva y no se puede reservar.");
        }
        return court;
    }

    private User resolverUsuario(Reservation reservation) {
        if (reservation.getUser() == null) {
            return null;
        }

        User incomingUser = reservation.getUser();
        if (incomingUser.getId() != null) {
            return userRepository.findById(incomingUser.getId())
                    .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));
        }

        String firebaseUid = normalizarTexto(incomingUser.getFirebaseUid());
        String email = normalizarTexto(incomingUser.getEmail());
        if (firebaseUid == null && email == null) {
            return null;
        }

        Optional<User> existingUser = firebaseUid != null
                ? userRepository.findByFirebaseUid(firebaseUid)
                : Optional.empty();
        if (existingUser.isEmpty() && email != null) {
            existingUser = userRepository.findByEmail(email);
        }

        return existingUser.orElseGet(() -> {
            User user = new User();
            user.setFirebaseUid(firebaseUid != null ? firebaseUid : crearUidDesdeEmail(email));
            user.setEmail(email != null ? email : firebaseUid + "@firebase.local");
            user.setNombre(normalizarTexto(incomingUser.getNombre()) != null ? incomingUser.getNombre() : "Usuario");
            user.setTelefono("000000000");
            user.setRol(User.Role.USER);
            return userRepository.save(user);
        });
    }

    private void validarFechas(LocalDateTime inicio, LocalDateTime fin) {
        if (inicio == null || fin == null) {
            throw new IllegalArgumentException("Las fechas de inicio y fin son obligatorias.");
        }
        if (!fin.isAfter(inicio)) {
            throw new IllegalArgumentException("La fecha de fin debe ser posterior a la de inicio.");
        }
    }

    private int normalizarSemanas(int semanasRepeticion) {
        if (semanasRepeticion < 1) {
            return 1;
        }
        return Math.min(semanasRepeticion, MAX_SEMANAS_REPETICION);
    }

    private String normalizarTexto(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private String crearQrToken(String tokenBase, int indice) {
        if (normalizarTexto(tokenBase) != null) {
            return indice == 0 ? tokenBase : tokenBase + "_" + indice;
        }
        return "QR_" + System.currentTimeMillis() + "_" + indice;
    }

    private String crearUidDesdeEmail(String email) {
        return "email_" + email.toLowerCase().replaceAll("[^a-z0-9]", "_");
    }

    private void copiarCamposOpcionales(Reservation origen, Reservation destino) {
        destino.setMetodoPago(normalizarTexto(origen.getMetodoPago()) != null ? origen.getMetodoPago() : "TARJETA");
        destino.setEstadoPago(normalizarTexto(origen.getEstadoPago()) != null ? origen.getEstadoPago() : "PAGADO");
        destino.setPrecioMaterial(origen.getPrecioMaterial() != null ? origen.getPrecioMaterial() : 0.0);
        destino.setDetallesMaterial(normalizarTexto(origen.getDetallesMaterial()) != null ? origen.getDetallesMaterial() : "");
        destino.setEmailContacto(normalizarTexto(origen.getEmailContacto()));
        destino.setResultadoPartido(normalizarTexto(origen.getResultadoPartido()));
    }
}
