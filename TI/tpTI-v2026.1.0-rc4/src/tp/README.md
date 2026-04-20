Pour compiler:

make kmeans

paramètres possibles :

string      imageFilename               image d'entrée
int         k                           nombre de clusters pour le kmeans
string      groundTruthFilename         image véritée terrain
int         iterations                  nombre d'itération pour kmeans
bool        kmeans_cv                   pour utiliser le kmeans de open cv (true) ou celui codé à la main (false)
bool        meanshift                   pour utiliser (true) ou non (false) meanshift
int         hs                          seuil spatial
int         hc                          seuil colorimétrique
int         eps                         epsilon pour la condition d'arrêt de meanshift
int         kmax                        nombre d'itération max pour meanshift

exemples d'appel:

./bin/kmeans -i=../data/images/texture8.png -k=2 -gt=../data/images/texture8_VT.png --iterations=100 --kmeans_cv=false --meanshift=true --hs=15 --hc=3

./bin/kmeans -i=../data/images/cat.jpg -k=5  --iterations=100 --kmeans_cv=true --meanshift=true --hs=15 --hc=20