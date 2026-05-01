package com.uxia.uxilibris.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Configuración global de CORS para la API REST.
 *
 * <p>Permite peticiones desde cualquier origen ({@code *}) hacia todos los
 * endpoints bajo {@code /api/**}. Esto es necesario para que el cliente Flutter,
 * tanto en emulador Android como en navegador web, pueda comunicarse con el
 * servidor sin restricciones de política de mismo origen.</p>
 */
@Configuration
public class WebConfig {

    /**
     * Registra las reglas CORS globales de la aplicación.
     *
     * @return configurador de Spring MVC con las reglas CORS aplicadas
     */
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            /**
             * Permite todos los orígenes, cabeceras y métodos HTTP estándar
             * sobre cualquier ruta que empiece por {@code /api/}.
             *
             * @param registry registro de mapeos CORS de Spring MVC
             */
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOrigins("*")
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
                        .allowedHeaders("*");
            }
        };
    }
}