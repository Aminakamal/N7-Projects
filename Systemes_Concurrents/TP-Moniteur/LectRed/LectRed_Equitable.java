// Time-stamp: <11 oct 2024 08:19 Philippe Queinnec>

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import Synchro.Assert;

/** Lecteurs/rédacteurs
 * stratégie d'ordonnancement: equitable,
 * implantation: avec un moniteur. */
public class LectRed_Equitable implements LectRed
{
    private Lock mon;
    private  Condition peutLire;
    private Condition peutEcrire;
    private int nbLecteurs;
    private int nbEcrivainsEnAttente;
    private boolean tourLecteurs ;
    private boolean isWriting;
    
    public LectRed_Equitable() {
        this.mon = new ReentrantLock ();
        this.peutEcrire = mon.newCondition();
        this.peutLire = mon.newCondition();
        this.nbLecteurs= 0;
        this.nbEcrivainsEnAttente = 0;
        this.tourLecteurs = true; 
        this.isWriting = false;
    }

    public void demanderLecture() throws InterruptedException {
        mon.lock();
        while((nbEcrivainsEnAttente > 0 && !tourLecteurs) || isWriting )
            peutLire.await();
        nbLecteurs ++ ;
        mon.unlock();
        }

    public void terminerLecture() throws InterruptedException {
        mon.lock();
        nbLecteurs--;
        if (nbLecteurs == 0) {
            tourLecteurs = false;
          peutEcrire.signal();
        } 
      
        mon.unlock();
    }

    public void demanderEcriture() throws InterruptedException {
        mon.lock();
        nbEcrivainsEnAttente++;
            while (isWriting || nbLecteurs > 0 || (tourLecteurs && nbEcrivainsEnAttente > 1)) {
                peutEcrire.await();
            }
            nbEcrivainsEnAttente--;
            isWriting = true;
        mon.unlock();       
    }

    public void terminerEcriture() throws InterruptedException {
        mon.lock();
        isWriting = false;
        tourLecteurs = true;

        if (nbLecteurs > 0){
            peutEcrire.signal();
        }
        else
            peutLire.signalAll();

        mon.unlock();
    }

    public String nomStrategie() {
        return "Stratégie: Equitable.";
    }
}
