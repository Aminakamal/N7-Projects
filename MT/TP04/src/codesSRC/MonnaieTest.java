package TP04.src.codesSRC;

import TP04.src.codesSRC.Apres;
import TP04.src.codesSRC.UnTest;
/** Classe regroupant les tests unitaires de la classe Monnaie.  */
public class MonnaieTest {

	protected Monnaie m1;
	protected Monnaie m2;

	public void setup() {
		this.m1 = new Monnaie(5, "euro");
		this.m2 = new Monnaie(7, "euro");
	}

	public void ajouterValeur() throws DeviseInvalideException {
		m1.ajouter(m2);
		Assert.assertTrue(m1.getValeur() == 12);
	}

	public void RetrancherValeur() throws DeviseInvalideException {
		m1.retrancher(m2);
		Assert.assertTrue(m1.getValeur() == -2);
	}

}
