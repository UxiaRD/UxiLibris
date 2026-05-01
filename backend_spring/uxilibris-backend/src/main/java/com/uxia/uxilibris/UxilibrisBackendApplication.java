package com.uxia.uxilibris;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Punto de entrada de la aplicación UxiLibris.
 *
 * <p>Inicia el contexto de Spring Boot, que registra automáticamente
 * todos los componentes anotados con {@code @Service}, {@code @Repository},
 * {@code @RestController} y {@code @Configuration} del paquete base.</p>
 *
 * @author Uxía RD
 */
@SpringBootApplication
public class UxilibrisBackendApplication {

	/**
	 * Método principal de arranque de la aplicación.
	 *
	 * @param args argumentos de línea de comandos (no utilizados)
	 */
	public static void main(String[] args) {
		SpringApplication.run(UxilibrisBackendApplication.class, args);
	}
}