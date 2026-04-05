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

@Service
public class GoogleBooksService {

    private static final String GOOGLE_BOOKS_URL =
            "https://www.googleapis.com/books/v1/volumes";

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${google.books.api.key:}")
    private String apiKey;

    /**
     * Busca un libro por ISBN en Google Books.
     * @return Optional vacío si no se encuentra resultado.
     * @throws ResponseStatusException 429 si se agotó la cuota de Google Books.
     */
    @SuppressWarnings("unchecked")
    public Optional<IsbnResultDto> buscarPorISBN(String isbn) {
        UriComponentsBuilder builder = UriComponentsBuilder
                .fromHttpUrl(GOOGLE_BOOKS_URL)
                .queryParam("q", "isbn:" + isbn);

        // Añadir API key si está configurada en application.properties
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
            // Cualquier otro error HTTP lo tratamos como "no encontrado"
            return Optional.empty();
        } catch (RestClientException e) {
            // Error de red o servidor Google no disponible
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
}
