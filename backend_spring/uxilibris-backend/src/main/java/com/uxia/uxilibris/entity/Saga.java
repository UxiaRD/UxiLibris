package com.uxia.uxilibris.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "sagas")
@Data
public class Saga {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nombre;

    private Integer totalLibros;
}