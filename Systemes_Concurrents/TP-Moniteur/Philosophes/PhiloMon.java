import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;

/* Squelette d'une solution avec un moniteur.
 * Il manque le moniteur (verrou + variables conditions).
 */
public class PhiloMon implements StrategiePhilo {

    // État d'un philosophe : pense, mange, demande ?
    private EtatPhilosophe[] etat;
    private int nbFourchettes;
    private EtatFourchette[] etatFourchettes; 
    private Lock moniteur;
    private Condition[] peutManger; 
    private boolean[] isFourchetteLibre;

    /****************************************************************/

    public PhiloMon (int nbPhilosophes) {
        this.moniteur = new ReentrantLock ();
        this.etat = new EtatPhilosophe[nbPhilosophes];
        for (int i = 0; i < nbPhilosophes; i++) {
            etat[i] = EtatPhilosophe.Pense;
        }
        this.etatFourchettes = new EtatFourchette[nbFourchettes];
        for ( int i = 0; i<nbFourchettes; i++){
            etatFourchettes[i] = EtatFourchette.Table;
        }
        this.peutManger = new Condition[nbPhilosophes];
        this.isFourchetteLibre= new boolean[nbPhilosophes]; 
    }

    public void demanderFourchettes (int no) throws InterruptedException
    {
        etat[no] = EtatPhilosophe.Demande;
        /* XXXX */
        etat[no] = EtatPhilosophe.Mange;
        // j'ai les fourchette G et D
        IHMPhilo.poser (Main.FourchetteGauche(no), EtatFourchette.AssietteDroite);
        IHMPhilo.poser (Main.FourchetteDroite(no), EtatFourchette.AssietteGauche);
    }

    public void libererFourchettes (int no)
    {
        IHMPhilo.poser (Main.FourchetteGauche(no), EtatFourchette.Table);
        IHMPhilo.poser (Main.FourchetteDroite(no), EtatFourchette.Table);
        etat[no] = EtatPhilosophe.Pense;
        /* XXXX */
    }

    public String nom() {
        return "Moniteur";
    }

}

