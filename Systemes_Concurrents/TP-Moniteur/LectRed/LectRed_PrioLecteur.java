// Time-stamp: <11 oct 2024 08:19 Philippe Queinnec>

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import Synchro.Assert;

/** Lecteurs/rédacteurs
 * stratégie d'ordonnancement: priorité aux lecteurs,
 * implantation: avec un moniteur. */
public class LectRed_PrioLecteur implements LectRed
{
    private Lock mon;
    private  Condition peutLire;
    private Condition peutEcrire;
    private int nbLecteurs;
    private int nbEcrivains;

    
    public LectRed_PrioLecteur() {
        this.mon = new ReentrantLock ();
        this.peutEcrire = mon.newCondition();
        this.peutLire = mon.newCondition();
        this.nbLecteurs= 0;
        this.nbEcrivains = 0;
    }

    public void demanderLecture() throws InterruptedException {
        mon.lock();
        while(nbEcrivains > 0 )
            peutLire.await();
        nbLecteurs ++;
        mon.unlock();
        }

    public void terminerLecture() throws InterruptedException {
        mon.lock();
        nbLecteurs --;
        if (nbLecteurs == 0){
            peutEcrire.signal();
        }
        mon.unlock();
    }

    public void demanderEcriture() throws InterruptedException {
        mon.lock();
        while( nbLecteurs > 0 || nbEcrivains == 1 )
            peutEcrire.await();
        nbEcrivains ++;
        peutEcrire.signal();
        mon.unlock();       
    }

    public void terminerEcriture() throws InterruptedException {
        mon.lock();
        nbEcrivains --;
        if (nbEcrivains == 0){
            peutLire.signalAll();
        }
        mon.unlock();
    }

    public String nomStrategie() {
        return "Stratégie: Priorité Lecteurs.";
    }
}
