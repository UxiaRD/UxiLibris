package com.uxia.uxilibris.service;

import com.uxia.uxilibris.dto.IsbnResultDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Servicio que actúa como cliente de la <a href="https://developers.google.com/books">Google Books API</a>.
 *
 * <p>Proporciona dos modos de búsqueda:</p>
 * <ul>
 *   <li><strong>Por ISBN:</strong> devuelve un único resultado o vacío.</li>
 *   <li><strong>Por texto libre:</strong> devuelve hasta 10 resultados.</li>
 * </ul>
 *
 * <p>Si se configura una clave de API propia en {@code google.books.api.key},
 * se dispone de 1 000 peticiones diarias propias. Sin clave, se comparte la
 * cuota anónima de Google, que se agota fácilmente.</p>
 *
 * <p>Los errores de cuota (HTTP 429) se propagan como {@code 429 Too Many Requests}
 * al cliente. Los errores de red se propagan como {@code 503 Service Unavailable}.</p>
 */
@Service
public class GoogleBooksService {

    /** URL base de la Google Books API para búsqueda de volúmenes. */
    private static final String GOOGLE_BOOKS_URL =
            "https://www.googleapis.com/books/v1/volumes";

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Clave de API de Google Books inyectada desde {@code application.properties}.
     * Si no está configurada, la propiedad toma el valor vacío {@code ""}.
     */
    @Value("${google.books.api.key:}")
    private String apiKey;

    /**
     * Busca un libro por su código ISBN en Google Books.
     *
     * <p>Añade la clave de API a la petición si está configurada. Devuelve
     * los datos del primer resultado que tenga título válido.</p>
     *
     * @param isbn código ISBN-10 o ISBN-13 del libro
     * @return {@code Optional} con los datos del libro si se encontró resultado;
     *         vacío si no hay coincidencias o el título es nulo
     * @throws ResponseStatusException con código 429 si se agotó la cuota de Google Books
     * @throws ResponseStatusException con código 503 si Google Books no está disponible
     */
    @SuppressWarnings("unchecked")
    public Optional<IsbnResultDto> buscarPorISBN(String isbn) {
        UriComponentsBuilder builder = UriComponentsBuilder
                .fromHttpUrl(GOOGLE_BOOKS_URL)
                .queryParam("q", "isbn:" + isbn);

        if (apiKey != null && !apiKey.isBlank()) {
            builder.queryParam("key", apiKey);
        }

        Map<String, Object> respuesta;
        try {
            respuesta = restTemplate.getForObject(builder.toUriString(), Map.class);
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.TOO_MANY_REQUESTS) {
                throw new ResponseStatusException(
                        HttpStatus.TOO_MANY_REQUESTS,
                        "Cuota de Google Books agotada. Espera unas horas o configura una API key propia."
                );
            }
            return Optional.empty();
        } catch (RestClientException e) {
            throw new ResponseStatusException(
                    HttpStatus.SERVICE_UNAVAILABLE,
                    "Google Books no está disponible en este momento."
            );
        }

        if (respuesta == null) return Optional.empty();

        Integer totalItems = (Integer) respuesta.get("totalItems");
        if (totalItems == null || totalItems == 0) return Optional.empty();

        List<Map<String, Object>> items =
                (List<Map<String, Object>>) respuesta.get("items");
        Map<String, Object> volumeInfo =
                (Map<String, Object>) items.get(0).get("volumeInfo");

        String titulo = (String) volumeInfo.get("title");
        if (titulo == null || titulo.isBlank()) return Optional.empty();

        List<String> autores = (List<String>) volumeInfo.get("authors");
        String autor = (autores != null && !autores.isEmpty()) ? autores.get(0) : "";

        Map<String, Object> imageLinks = (Map<String, Object>) volumeInfo.get("imageLinks");
        String portada = (imageLinks != null) ? (String) imageLinks.get("thumbnail") : null;

        Map<String, Object> seriesInfo = (Map<String, Object>) items.get(0).get("seriesInfo");
        String saga = null;
        Double numLibroSaga = null;
        if (seriesInfo != null) {
            saga = (String) seriesInfo.get("shortSeriesBookTitle");
            String numStr = (String) seriesInfo.get("bookDisplayNumber");
            if (numStr != null && !numStr.isBlank()) {
                try { numLibroSaga = Double.parseDouble(numStr); } catch (NumberFormatException ignored) {}
            }
        }

        return Optional.of(new IsbnResultDto(titulo, autor, portada, saga, numLibroSaga));
    }

    /**
     * Busca libros por texto libre en Google Books combinando una búsqueda
     * específica por autor ({@code inauthor:query}) y una búsqueda general.
     *
     * <p>Los resultados de {@code inauthor:} van <strong>primero</strong> porque son
     * los más relevantes cuando el usuario escribe un nombre de autor. La búsqueda
     * general complementa con libros que no aparecieron en la anterior (útil cuando
     * el usuario escribe un título). Ambas búsquedas fallan silenciosamente de forma
     * independiente: si una falla pero la otra tiene resultados, estos se devuelven
     * igualmente. Solo se propaga error si ambas fallan.</p>
     *
     * @param query texto de búsqueda introducido por el usuario
     * @return lista de hasta 40 resultados únicos ordenados por relevancia;
     *         lista vacía si no hay coincidencias
     * @throws ResponseStatusException con código 429 si se agotó la cuota de Google Books
     * @throws ResponseStatusException con código 503 si Google Books no está disponible
     */
    public List<IsbnResultDto> buscarPorTexto(String query) {
        // Búsqueda por autor primero: resultados más precisos cuando se escribe un nombre de autor.
        // Comillas en nombres compuestos para que Google trate el nombre como frase exacta en el campo autor
        // (sin comillas, "Jay Kristoff" se interpretaría como inauthor:Jay AND Kristoff_en_cualquier_campo).
        String inauthorQuery = query.contains(" ")
                ? "inauthor:\"" + query + "\""
                : "inauthor:" + query;
        List<IsbnResultDto> porAutor = List.of();
        try {
            porAutor = buscarItems(inauthorQuery, 20);
        } catch (Exception ignored) {}

        // Búsqueda general: complementa con resultados por título, descripción, etc.
        List<IsbnResultDto> generales = List.of();
        try {
            generales = buscarItems(query, 20);
        } catch (Exception e) {
            // Si la búsqueda general falla pero ya tenemos resultados de autor, los devolvemos.
            // Solo propagamos el error si ambas búsquedas fallaron.
            if (porAutor.isEmpty()) throw e;
        }

        // Mezclar deduplicando por título: inauthor va primero (más relevante)
        java.util.Set<String> vistos = new java.util.HashSet<>();
        List<IsbnResultDto> combinados = new java.util.ArrayList<>();
        for (IsbnResultDto dto : porAutor) {
            if (vistos.add(dto.titulo().toLowerCase())) combinados.add(dto);
        }
        for (IsbnResultDto dto : generales) {
            if (vistos.add(dto.titulo().toLowerCase())) combinados.add(dto);
        }
        return combinados;
    }

    /**
     * Ejecuta una petición a Google Books con el parámetro {@code q} y
     * {@code maxResults} indicados. Extrae y devuelve los ítems válidos.
     */
    @SuppressWarnings("unchecked")
    private List<IsbnResultDto> buscarItems(String q, int maxResults) {
        UriComponentsBuilder builder = UriComponentsBuilder
                .fromHttpUrl(GOOGLE_BOOKS_URL)
                .queryParam("q", q)
                .queryParam("maxResults", maxResults);

        if (apiKey != null && !apiKey.isBlank()) {
            builder.queryParam("key", apiKey);
        }

        Map<String, Object> respuesta;
        try {
            respuesta = restTemplate.getForObject(builder.toUriString(), Map.class);
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.TOO_MANY_REQUESTS) {
                throw new ResponseStatusException(
                        HttpStatus.TOO_MANY_REQUESTS,
                        "Cuota de Google Books agotada. Espera unas horas o configura una API key propia.");
            }
            return List.of();
        } catch (RestClientException e) {
            throw new ResponseStatusException(
                    HttpStatus.SERVICE_UNAVAILABLE,
                    "Google Books no está disponible en este momento.");
        }

        if (respuesta == null) return List.of();

        Integer totalItems = (Integer) respuesta.get("totalItems");
        if (totalItems == null || totalItems == 0) return List.of();

        List<Map<String, Object>> items = (List<Map<String, Object>>) respuesta.get("items");
        if (items == null) return List.of();

        List<IsbnResultDto> resultados = new java.util.ArrayList<>();
        for (Map<String, Object> item : items) {
            IsbnResultDto dto = parsearItem(item);
            if (dto != null) resultados.add(dto);
        }
        return resultados;
    }

    /**
     * Extrae los datos relevantes de un elemento de la respuesta JSON de Google Books.
     *
     * <p>Descarta el elemento si no tiene título válido, ya que el título es
     * el único campo imprescindible para el formulario de alta de libro.</p>
     *
     * @param item mapa JSON que representa un volumen de Google Books
     * @return {@link IsbnResultDto} con los datos extraídos, o {@code null}
     *         si el elemento no tiene título o {@code volumeInfo}
     */
    private IsbnResultDto parsearItem(Map<String, Object> item) {
        @SuppressWarnings("unchecked")
        Map<String, Object> volumeInfo = (Map<String, Object>) item.get("volumeInfo");
        if (volumeInfo == null) return null;

        String titulo = (String) volumeInfo.get("title");
        if (titulo == null || titulo.isBlank()) return null;

        @SuppressWarnings("unchecked")
        List<String> autores = (List<String>) volumeInfo.get("authors");
        String autor = (autores != null && !autores.isEmpty()) ? autores.get(0) : "";

        @SuppressWarnings("unchecked")
        Map<String, Object> imageLinks = (Map<String, Object>) volumeInfo.get("imageLinks");
        String portada = (imageLinks != null) ? (String) imageLinks.get("thumbnail") : null;

        @SuppressWarnings("unchecked")
        Map<String, Object> seriesInfo = (Map<String, Object>) item.get("seriesInfo");
        String saga = null;
        Double numLibroSaga = null;
        if (seriesInfo != null) {
            saga = (String) seriesInfo.get("shortSeriesBookTitle");
            String numStr = (String) seriesInfo.get("bookDisplayNumber");
            if (numStr != null && !numStr.isBlank()) {
                try { numLibroSaga = Double.parseDouble(numStr); } catch (NumberFormatException ignored) {}
            }
        }
        return new IsbnResultDto(titulo, autor, portada, saga, numLibroSaga);
    }
}