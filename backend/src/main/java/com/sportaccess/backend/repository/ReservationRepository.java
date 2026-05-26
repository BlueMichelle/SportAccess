package com.sportaccess.backend.repository;

import com.sportaccess.backend.model.Reservation;
import com.sportaccess.backend.model.Reservation.ReservationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    List<Reservation> findByUserId(Long userId);

    List<Reservation> findByCourtId(Long courtId);

    Optional<Reservation> findByQrToken(String qrToken);

    List<Reservation> findByEstado(ReservationStatus estado);

    List<Reservation> findByFechaInicioBetween(LocalDateTime inicio, LocalDateTime fin);

    @Query("SELECT COUNT(r) > 0 FROM Reservation r " +
            "WHERE r.court.id = :courtId " +
            "AND r.estado NOT IN ('CANCELADA', 'COMPLETADA') " +
            "AND r.fechaInicio < :fin " +
            "AND r.fechaFin > :inicio")
    boolean existeSolape(@Param("courtId") Long courtId,
                         @Param("inicio") LocalDateTime inicio,
                         @Param("fin") LocalDateTime fin);

    @Query("SELECT COUNT(r) > 0 FROM Reservation r " +
            "WHERE r.id <> :reservationId " +
            "AND r.court.id = :courtId " +
            "AND r.estado NOT IN ('CANCELADA', 'COMPLETADA') " +
            "AND r.fechaInicio < :fin " +
            "AND r.fechaFin > :inicio")
    boolean existeSolapeExcluyendoReserva(@Param("reservationId") Long reservationId,
                                          @Param("courtId") Long courtId,
                                          @Param("inicio") LocalDateTime inicio,
                                          @Param("fin") LocalDateTime fin);

    @Query("SELECT r FROM Reservation r " +
            "WHERE r.court.id = :courtId " +
            "AND r.estado != 'CANCELADA' " +
            "AND r.fechaInicio < :hasta " +
            "AND r.fechaFin > :desde")
    List<Reservation> findReservasActivasPorPistaYRango(
            @Param("courtId") Long courtId,
            @Param("desde") LocalDateTime desde,
            @Param("hasta") LocalDateTime hasta);
}
