package com.uxia.uxilibris.service;

import com.uxia.uxilibris.entity.Saga;
import com.uxia.uxilibris.repository.LibroRepository;
import com.uxia.uxilibris.repository.SagaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class SagaService {

    @Autowired
    private SagaRepository sagaRepository;

    @Autowired
    private LibroRepository libroRepository;

    public List<Saga> listarTodas() {
        return sagaRepository.findAll();
    }

    @Transactional
    public Saga guardar(Saga saga) {
        if (saga.getNombre() != null) {
            saga.setNombre(saga.getNombre().trim());
        }
        return sagaRepository.save(saga);
    }

    @Transactional
    public void eliminar(Long id) {
        // Primero desasociamos todos los libros para no violar la FK
        libroRepository.clearSagaById(id);
        sagaRepository.deleteById(id);
    }
}