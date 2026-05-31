package TP04.src.codesSRC;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Indique une méthode à exécuter avant chaque méthode de test.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Avant {
    // Aucune information supplémentaire n'est nécessaire pour le moment
}