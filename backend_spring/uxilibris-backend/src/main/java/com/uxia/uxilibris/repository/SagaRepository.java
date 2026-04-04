package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Saga;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SagaRepository extends JpaRepository<Saga, Long> {
    boolean existsByNombre(String nombre);
    Optional<Saga> findByNombre(String nombre);
}