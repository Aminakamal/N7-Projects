// Time-stamp: <06 jui 2023 11:58 Philippe Queinnec>

import CSP.*;

/** Réalisation de la voie unique avec des canaux JCSP. */
/* Version par automate d'états */
public class VoieUniqueAutomate implements VoieUnique {

    enum ChannelId { EntrerNS, EntrerSN, Sortir };
    
    private Channel<ChannelId> entrerNS;
    private Channel<ChannelId> entrerSN;
    private Channel<ChannelId> sortir;
    
    public VoieUniqueAutomate() {
        this.entrerNS = new Channel<>(ChannelId.EntrerNS);
        this.entrerSN = new Channel<>(ChannelId.EntrerSN);
        this.sortir = new Channel<>(ChannelId.Sortir);
        (new Thread(new Scheduler())).start();
    }

    public void entrer(Sens sens) {
        System.out.println("In  entrer " + sens);
        switch (sens) {
          case NS:
            entrerNS.write(true);
            break;
          case SN:
            entrerSN.write(true);
            break;
        }
        System.out.println("Out entrer " + sens);
    }

    public void sortir(Sens sens) {
        System.out.println("In  sortir " + sens);
        sortir.write(true);
        System.out.println("Out sortir " + sens);
    }

    public String nomStrategie() {
        return "Automate";
    }

    /****************************************************************/

    class Scheduler implements Runnable {
        private  Sens sens = null;
        private int   nbTrains = 0;
        public void run() {
                var alt = new Alternative<>(entrerNS,entrerSN, sortir);
                while(true){
                   if (sens == null){
                    switch(alt.select()){
                        case  EntrerNS:
                            nbTrains = 1;
                            entrerNS.read();
                            sens = Sens.NS;
                            break;
                        case EntrerSN :
                            nbTrains = 1;
                            entrerSN.read();
                            sens = Sens.SN;
                            break;
                    }
                    
                    }
                    else if ( sens == Sens.NS){
                        switch(alt.select()){
                            case EntrerNS:
                                nbTrains ++;
                                sens = Sens.NS;
                                break;
                            case Sortir :
                                nbTrains --;
                                if (nbTrains == 0) sens = null;
                                break;  
                        }
                    }
                    else if (sens == Sens.SN){
                        switch(alt.select()){
                            case EntrerSN :
                                nbTrains ++;
                                sens = Sens.SN;
                                break;
                            case Sortir :
                                if (nbTrains == 0) sens = null;
                        }
                    }
                }

        }
    } // class Scheduler
}

