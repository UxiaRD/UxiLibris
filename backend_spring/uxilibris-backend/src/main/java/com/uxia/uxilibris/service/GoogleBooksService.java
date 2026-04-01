package com.uxia.uxilibris.service;

import com.uxia.uxilibris.dto.IsbnResultDto;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class GoogleBooksService {

    private static final String GOOGLE_BOOKS_URL =
            "https://www.googleapis.com/books/v1/volumes";

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Busca un libro por ISBN en Google Books.
     * @return Optional vacío si no se encuentra resultado.
     */
    @SuppressWarnings("unchecked")
    public Optional<IsbnResultDto> buscarPorISBN(String isbn) {
        String url = UriComponentsBuilder.fromHttpUrl(GOOGLE_BOOKS_URL)
                .queryParam("q", "isbn:" + isbn)
                .toUriString();

        Map<String, Object> respuesta = restTemplate.getForObject(url, Map.class);

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
