package com.uxia.uxilibris.dto;

/**
 * DTO inmutable con los datos de un libro obtenidos desde Google Books API.
 *
 * <p>Devuelto por los endpoints de búsqueda por ISBN
 * ({@code GET /api/libros/isbn/{isbn}}) y por texto libre
 * ({@code GET /api/libros/buscar?q=...}). El cliente utiliza estos datos
 * para prerellenar el formulario de alta de libro.</p>
 *
 * @param titulo       título principal del libro según Google Books
 * @param autor        nombre del primer autor listado; cadena vacía si no está disponible
 * @param portada      URL de la miniatura de la portada; puede ser {@code null}
 * @param saga         nombre corto de la serie si Google Books lo proporciona; puede ser {@code null}
 * @param numLibroSaga número de volumen dentro de la saga; puede ser {@code null}
 */
public record IsbnResultDto(
        String titulo,
        String autor,
        String portada,
        String saga,
        Double numLibroSaga
) {}