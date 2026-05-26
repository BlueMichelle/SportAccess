package com.sportaccess.backend.controller;

import com.sportaccess.backend.model.Court;
import com.sportaccess.backend.repository.CourtRepository;
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
}

