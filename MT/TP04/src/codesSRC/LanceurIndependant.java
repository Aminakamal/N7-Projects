package TP04.src.codesSRC;
import java.lang.reflect.*;
import java.util.*;
import TP04.src.codesSRC.*;

/** L'objectif est de faire un lanceur simple sans utiliser toutes les clases
  * de notre architecture JUnit.   Il permet juste de valider la compréhension
  * de l'introspection en Java.
  */
public class LanceurIndependant {
	private int nbTestsLances;
	private int nbErreurs;
	private int nbEchecs;
	private List<Throwable> erreurs = new ArrayList<>();

	public LanceurIndependant(String... nomsClasses) {
	    System.out.println();

		// Lancer les tests pour chaque classe
		for (String nom : nomsClasses) {
			try {
				System.out.print(nom + " : ");
				this.testerUneClasse(nom);
				System.out.println();
			} catch (ClassNotFoundException e) {
				System.out.println(" Classe inconnue !");
			} catch (Exception e) {
				System.out.println(" Problème : " + e);
				e.printStackTrace();
			}
		}

		// Afficher les erreurs
		for (Throwable e : erreurs) {
			System.out.println();
			e.printStackTrace();
		}

		// Afficher un bilan
		System.out.println();
		System.out.printf("%d tests lancés dont %d échecs et %d erreurs.\n",
				nbTestsLances, nbEchecs, nbErreurs);
	}


	public int getNbTests() {
		return this.nbTestsLances;
	}


	public int getNbErreurs() {
		return this.nbErreurs;
	}


	public int getNbEchecs() {
		return this.nbEchecs;
	}
	// MÃ©thode utilitaire : trouve la mÃ©thode @Avant ou @Apres en utilisant isAnnotationPresent
    private Method findAnnotatedMethod(Class<?> testClass, Class annotationClass) {
        for (Method method : testClass.getDeclaredMethods()) {
            if (method.isAnnotationPresent(annotationClass)) {
                return method;
            }
        }
        return null;
    }

    // MÃ©thode utilitaire : trouve toutes les mÃ©thodes @UnTest
    private List<Method> findAnnotatedMethods(Class<?> testClass, Class annotationClass) {
        List<Method> methods = new ArrayList<>();
        for (Method method : testClass.getDeclaredMethods()) {
            if (method.isAnnotationPresent(annotationClass)) {
                methods.add(method);
            }
        }
        return methods;
    }

	private void testerUneClasse(String nomClasse)
		throws ClassNotFoundException, InstantiationException,
						  IllegalAccessException, IllegalArgumentException, InvocationTargetException, NoSuchMethodException, SecurityException
	{
		// Récupérer la classe
		Class<?> classe = Class.forName(nomClasse);
		Object objet = classe.getDeclaredConstructor().newInstance();
		// Récupérer les méthodes "preparer" et "nettoyer"
		/*Method preparer = null;
		Method nettoyer = null;*/
		Method avantMethod = findAnnotatedMethod(classe, Avant.class);
		Method apresMethod = findAnnotatedMethod(classe, Apres.class);

		
// 3. Identifier toutes les mÃ©thodes de test (@UnTest)
		List<Method> testMethods = new ArrayList<>();
		// RÃ©cupÃ©rer l'annotation pour les attributs (getAnnotation)
		for (Method testMethod : testMethods){	
		UnTest annotation =  testMethod.getAnnotation(UnTest.class);
		}
		// Exécuter les méthods de test
	}

	public static void main(String... args) {
		LanceurIndependant lanceur = new LanceurIndependant(args);
	}

}
