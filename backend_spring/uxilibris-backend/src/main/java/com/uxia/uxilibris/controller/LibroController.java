package com.uxia.uxilibris.controller;

import com.uxia.uxilibris.dto.IsbnResultDto;
import com.uxia.uxilibris.entity.Libro;
import com.uxia.uxilibris.service.GoogleBooksService;
import com.uxia.uxilibris.service.LibroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST que gestiona las operaciones sobre los libros de la biblioteca,
 * incluyendo CRUD, asignación de sagas, favoritos y búsqueda en Google Books.
 *
 * <p>Base URL: {@code /api/libros}</p>
 */
@RestController
@RequestMapping("/api/libros")
@CrossOrigin(origins = "*")
public class LibroController {

    @Autowired
    private LibroService libroService;

    @Autowired
    private GoogleBooksService googleBooksService;

    /**
     * Devuelve todos los libros pertenecientes al usuario indicado.
     *
     * <p>{@code GET /api/libros?usuarioId=X}</p>
     *
     * @param usuarioId identificador del usuario propietario
     * @return lista de libros del usuario
     */
    @GetMapping
    public List<Libro> listarTodos(@RequestParam Long usuarioId) {
        return libroService.listarTodosLosLibros(usuarioId);
    }

    /**
     * Crea un nuevo libro.
     *
     * <p>{@code POST /api/libros}</p>
     *
     * <p>Si el JSON incluye un {@code id}, el servicio intenta hacer UPDATE;
     * si no, INSERT. Se auto-crea la saga si es necesario.</p>
     *
     * @param libro datos del libro a crear
     * @return {@code 200 OK} con el libro creado, incluyendo el {@code id} generado
     */
    @PostMapping
    public ResponseEntity<Libro> guardar(@RequestBody Libro libro) {
        return ResponseEntity.ok(libroService.guardarLibro(libro));
    }

    /**
     * Actualiza completamente un libro existente.
     *
     * <p>{@code PUT /api/libros/{id}}</p>
     *
     * @param id    identificador del libro a actualizar
     * @param libro datos actualizados del libro
     * @return {@code 200 OK} con el libro actualizado
     */
    @PutMapping("/{id}")
    public ResponseEntity<Libro> actualizar(@PathVariable Long id, @RequestBody Libro libro) {
        libro.setId(id);
        return ResponseEntity.ok(libroService.guardarLibro(libro));
    }

    /**
     * Elimina un libro por su identificador.
     *
     * <p>{@code DELETE /api/libros/{id}}</p>
     *
     * @param id identificador del libro a eliminar
     * @return {@code 204 No Content}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        libroService.eliminarLibro(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Devuelve los números de volumen ya registrados para una saga.
     *
     * <p>{@code GET /api/libros/volumenes?saga=NombreSaga}</p>
     *
     * @param saga nombre de la saga
     * @return {@code 200 OK} con la lista de volúmenes registrados
     */
    @GetMapping("/volumenes")
    public ResponseEntity<List<Double>> getVolumenesPorSaga(@RequestParam String saga) {
        return ResponseEntity.ok(libroService.obtenerVolumenesDeSaga(saga));
    }

    /**
     * Devuelve los nombres de saga únicos para el autocompletado del formulario.
     *
     * <p>{@code GET /api/libros/sagas}</p>
     *
     * @return lista de nombres de saga ordenada alfabéticamente
     */
    @GetMapping("/sagas")
    public List<String> getSagas() {
        return libroService.listarSagasExistentes();
    }

    /**
     * Devuelve los nombres de autor únicos para el autocompletado del formulario.
     *
     * <p>{@code GET /api/libros/autores}</p>
     *
     * @return lista de nombres de autor ordenada alfabéticamente
     */
    @GetMapping("/autores")
    public List<String> getAutores() {
        return libroService.listarAutoresExistentes();
    }

    /**
     * Sugiere el siguiente número de volumen disponible para una saga.
     *
     * <p>{@code GET /api/libros/sugerir-volumen?saga=NombreSaga}</p>
     *
     * @param saga nombre de la saga
     * @return número de volumen sugerido (máximo actual + 1, o 1.0 si no hay volúmenes)
     */
    @GetMapping("/sugerir-volumen")
    public Double getSugerencia(@RequestParam String saga) {
        return libroService.sugerirSiguienteVolumen(saga);
    }

    /**
     * Asigna o reasigna una saga a un libro existente sin modificar el resto de sus datos.
     *
     * <p>{@code PATCH /api/libros/{id}/saga?saga=NombreSaga&numLibroSaga=N}</p>
     *
     * @param id           identificador del libro
     * @param saga         nombre de la nueva saga
     * @param numLibroSaga número de volumen dentro de la saga (opcional)
     * @return {@code 200 OK} con el libro actualizado
     */
    @PatchMapping("/{id}/saga")
    public ResponseEntity<Libro> asignarSaga(
            @PathVariable Long id,
            @RequestParam String saga,
            @RequestParam(required = false) Double numLibroSaga) {
        return ResponseEntity.ok(libroService.asignarSaga(id, saga, numLibroSaga));
    }

    /**
     * Marca o desmarca un libro como favorito.
     *
     * <p>{@code PATCH /api/libros/{id}/favorito?valor=true|false}</p>
     *
     * @param id    identificador del libro
     * @param valor {@code true} para marcar como favorito; {@code false} para desmarcarlo
     * @return {@code 200 OK} con el libro actualizado
     */
    @PatchMapping("/{id}/favorito")
    public ResponseEntity<Libro> toggleFavorito(
            @PathVariable Long id,
            @RequestParam boolean valor) {
        return ResponseEntity.ok(libroService.toggleFavorito(id, valor));
    }

    /**
     * Actualiza la imagen de fondo de la pantalla de detalle de un libro.
     *
     * <p>{@code PATCH /api/libros/{id}/fondo}</p>
     *
     * @param id   identificador del libro
     * @param body mapa JSON con la clave {@code rutaFondo} (puede ser null)
     * @return {@code 200 OK} si se actualizó, {@code 404} si no existe el libro
     */
    @PatchMapping("/{id}/fondo")
    public ResponseEntity<Void> actualizarFondo(
            @PathVariable Long id,
            @RequestBody java.util.Map<String, Object> body) {
        String rutaFondo = body != null ? (String) body.get("rutaFondo") : null;
        boolean ok = libroService.actualizarFondo(id, rutaFondo);
        return ok ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }

    /**
     * Busca libros por texto libre en Google Books y devuelve hasta 10 resultados.
     *
     * <p>{@code GET /api/libros/buscar?q=texto}</p>
     *
     * @param q texto de búsqueda (título, autor, etc.)
     * @return {@code 200 OK} con lista de resultados; lista vacía si no hay coincidencias
     */
    @GetMapping("/buscar")
    public ResponseEntity<List<IsbnResultDto>> buscarPorTexto(@RequestParam String q) {
        return ResponseEntity.ok(googleBooksService.buscarPorTexto(q));
    }

    /**
     * Busca un libro por su código ISBN en Google Books.
     *
     * <p>{@code GET /api/libros/isbn/{isbn}}</p>
     *
     * @param isbn código ISBN-10 o ISBN-13
     * @return {@code 200 OK} con los datos del libro si se encontró;
     *         {@code 404 Not Found} si no hay resultados
     */
    @GetMapping("/isbn/{isbn}")
    public ResponseEntity<IsbnResultDto> buscarPorISBN(@PathVariable String isbn) {
        return googleBooksService.buscarPorISBN(isbn)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}