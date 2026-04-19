package com.uxia.uxilibris.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Entity
@Table(name = "lecturas")
@Data
public class LecturaLibro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "libro_id", nullable = false)
    @JsonIgnore
    private Libro libro;

    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}