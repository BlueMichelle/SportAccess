package com.sportaccess.config;

import com.sportaccess.model.Court;
import com.sportaccess.model.Court.CourtType;
import com.sportaccess.repository.CourtRepository;
import com.sportaccess.repository.ReservationRepository;
import com.sportaccess.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

@Configuration
public class DataInitializer {

    @Component
    public class Initializer implements CommandLineRunner {

        private final CourtRepository courtRepository;
        private final UserRepository userRepository;
        private final ReservationRepository reservationRepository;

        public Initializer(CourtRepository cr, UserRepository ur, ReservationRepository rr) {
            this.courtRepository = cr;
            this.userRepository = ur;
            this.reservationRepository = rr;
        }

        @Override
        public void run(String... args) throws Exception {
            System.out.println("=== CATALOGO: INICIANDO CREACION ===");
           /* try {
                reservationRepository.deleteAll();
                System.out.println(">>> Base de datos reseteada.");
            } catch (Exception e) {}
            */

            if (courtRepository.count() == 0) {
                seedCourts();
                System.out.println("=== CATALOGO LISTO PARA USAR (6 PISTAS) ===");
            }
        }

        private void seedCourts() {
            Court p1 = new Court(null, "Pádel Premium - Club Tenis Murcia", CourtType.PADEL, new BigDecimal("18.00"), true, "Pista de cristal.", "https://images.unsplash.com/photo-1626224484214-4051773c51a9?q=80&w=800");
            Court p2 = new Court(null, "Pádel Indoor - Cartagena", CourtType.PADEL, new BigDecimal("20.00"), true, "Indoor.", "https://images.unsplash.com/photo-1598135753163-6167c1a1ad65?q=80&w=800");
            Court t1 = new Court(null, "Tenis Tierra Batida - Murcia", CourtType.TENIS, new BigDecimal("12.00"), true, "Tierra batida.", "https://images.unsplash.com/photo-1595435064215-492976d03704?q=80&w=800");
            Court t2 = new Court(null, "Tenis Rápida - Cartagena", CourtType.TENIS, new BigDecimal("10.00"), true, "Rápida.", "https://images.unsplash.com/photo-1521533845262-3864326448c7?q=80&w=800");
            Court f1 = new Court(null, "Fútbol 7 Césped - Jose Barnés", CourtType.FUTBOL_SALA, new BigDecimal("35.00"), true, "Césped artificial.", "https://images.unsplash.com/photo-1529900948632-58674ba19308?q=80&w=800");
            Court f2 = new Court(null, "Fútbol Sala - Pabellón Murcia", CourtType.FUTBOL_SALA, new BigDecimal("25.00"), true, "Cubierta.", "https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800");
            courtRepository.saveAll(Arrays.asList(p1, p2, t1, t2, f1, f2));
        }
    }
}


