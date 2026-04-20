package TP04.src.codesSRC;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Indique une méthode à exécuter après chaque méthode de test.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Apres {
    // Aucune information supplémentaire n'est nécessaire pour le moment
}