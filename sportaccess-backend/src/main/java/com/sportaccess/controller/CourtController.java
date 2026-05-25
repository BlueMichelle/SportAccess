package com.sportaccess.controller;

import com.sportaccess.model.Court;
import com.sportaccess.repository.CourtRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/courts")
@CrossOrigin(origins = "*")
public class CourtController {

    private final CourtRepository courtRepository;

    // CONSTRUCTOR MANUAL (Para que Spring inyecte el repositorio sin necesidad de Lombok)
    public CourtController(CourtRepository courtRepository) {
        this.courtRepository = courtRepository;
    }

    @GetMapping
    public List<Court> getAllCourts() {
        return courtRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Court> getCourtById(@PathVariable Long id) {
        return courtRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Court> createCourt(@RequestBody Court court) {
        Court savedCourt = courtRepository.save(court);
        return new ResponseEntity<>(savedCourt, HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCourt(@PathVariable Long id) {
        // 1. Comprobamos si la pista existe en la base de datos
        if (!courtRepository.existsById(id)) {
            return ResponseEntity.notFound().build(); // Devuelve un 404 si no existe
        }

        // 2. Si existe, la borramos
        courtRepository.deleteById(id);

        // 3. Devolvemos un 204 (No Content) que significa "Todo OK y ya no está"
        return ResponseEntity.noContent().build();
    }

}

