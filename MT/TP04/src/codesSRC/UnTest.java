package TP04.src.codesSRC;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Indique une méthode comme étant une méthode de test.
 *
 * Inclut les attributs pour gérer l'activation et les exceptions attendues.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface UnTest {

    // Étape 1.4: Attribut pour l'activation (enabled par défaut à vrai) [cite: 8, 9]
    boolean enabled() default true;

    // Étape 1.5: Attribut pour l'exception attendue (par défaut à la classe 'None') [cite: 12]
    // Utilisation d'une classe "factice" ou de Object.class si on ne veut pas d'exception par défaut.
    // L'usage le plus simple est une classe qui étend Throwable mais qui n'est jamais levée.
    class PasDException extends Throwable {}
    Class<? extends Throwable> expected() default PasDException.class;
}