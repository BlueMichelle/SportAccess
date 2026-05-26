package com.sportaccess.backend.repository;

import com.sportaccess.backend.model.Court;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CourtRepository extends JpaRepository<Court, Long> {

    List<Court> findByActivaTrue();

    List<Court> findByTipo(Court.CourtType tipo);
}
