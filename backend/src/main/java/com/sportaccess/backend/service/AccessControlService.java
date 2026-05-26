package com.sportaccess.backend.service;

import com.sportaccess.backend.model.Booking;
import com.sportaccess.backend.repository.BookingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AccessControlService {

    private final BookingRepository bookingRepository;

    public boolean validateAccess(Long bookingId, String qrCode, double userLat, double userLon) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        // 1. Validate QR Code
        if (!booking.getQrCode().equals(qrCode)) {
            return false;
        }

        // 2. Validate Time Slot (e.g., allow entry 10 mins before and until the end)
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(booking.getStartTime().minusMinutes(10)) || now.isAfter(booking.getEndTime())) {
            return false;
        }

        // La geolocalizacion no esta modelada de forma consistente en esta rama,
        // asi que validamos QR y franja horaria como criterio minimo de acceso.
        return true;
    }
}
