package com.uxia.uxilibris.controller;

import com.uxia.uxilibris.entity.Libro;
import com.uxia.uxilibris.service.LibroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/libros")
@CrossOrigin(origins = "*") // Para permitir peticiones desde el emulador de Flutter
public class LibroController {
    @Autowired
    private LibroService libroService;

    @GetMapping
    public List<Libro> listarTodos() {
        return libroService.listarTodosLosLibros(); // Este debe devolver libroRepository.findAll()
    }

    @GetMapping("/sagas")
    public List<String> getSagas() {
        return libroService.listarSagasExistentes();
    }

    @GetMapping("/autores")
    public List<String> getAutores() {
        return libroService.listarAutoresExistentes();
    }

    @GetMapping("/sugerir-volumen")
    public Double getSugerencia(@RequestParam String saga) {
        return libroService.sugerirSiguienteVolumen(saga);
    }

    @PostMapping
    public ResponseEntity<Libro> crearLibro(@RequestBody Libro libro) {
        Libro guardado = libroService.guardarLibro(libro);
        return ResponseEntity.ok(guardado);
    }
}
