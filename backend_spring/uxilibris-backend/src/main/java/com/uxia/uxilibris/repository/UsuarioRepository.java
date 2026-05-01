package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio JPA para la entidad {@link Usuario}.
 *
 * <p>Spring Data JPA genera automáticamente las implementaciones de los métodos
 * derivados ({@code findBy...}) a partir de sus nombres, sin necesidad de
 * escribir consultas JPQL o SQL.</p>
 */
@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    /**
     * Busca un usuario por su correo electrónico.
     *
     * <p>Utilizado para verificar unicidad durante el registro y para
     * la actualización de cuenta.</p>
     *
     * @param email correo electrónico a buscar
     * @return {@code Optional} con el usuario si existe, vacío en caso contrario
     */
    Optional<Usuario> findByEmail(String email);

    /**
     * Busca un usuario por su nombre de usuario.
     *
     * <p>Utilizado en el inicio de sesión y para verificar unicidad
     * durante el registro o la actualización de cuenta.</p>
     *
     * @param username nombre de usuario a buscar
     * @return {@code Optional} con el usuario si existe, vacío en caso contrario
     */
    Optional<Usuario> findByUsername(String username);
}