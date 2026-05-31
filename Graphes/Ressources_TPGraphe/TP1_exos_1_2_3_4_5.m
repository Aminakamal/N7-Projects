%%%%% SET ENV %%%%%

addpath('matlab_bgl');      %load graph libraries
addpath('matlab_tpgraphe'); %load tp ressources

load TPgraphe.mat;          %load data

%%%%%% DISPLAY INPUT DATA ON TERMINAL %%%%%

cities %names of cities
D      %distance matrix bw cities
pos    %x-y pos of the cities

%%%%%%EXO 1 (modeliser et afficher le graphe) %%%%%

A=XXX A faire; %adj matrix
viz_adj(D,A,pos,cities);
viz_adj(D,XXX A faire,pos,cities);

%%%%%% EXO 2 %%%%%

%Q1 - existence d'un chemin de longueur 3
XXX A faire

%Q2 - nb de chemins de 3 sauts
XXX A faire

%Q3 - nb de chemins <=3
XXX A faire

%%%%%%%% EXO 3 %%%%%
c=[18 13 9]; %la chaine 18 13 9 est t dans le graphe?
possedechaine(A,c)
c=[18 6 3]; %la chaine 18 6 3 est t dans le graphe?
possedechaine(A,c)
c=[26 5 17]; %la chaine 26 5 17 est t dans le graphe?
possedechaine(A,c)

%%%%%%%% EXO 4%%%%%
isEulerien(A)

%%%%%%%% EXO 5%%%%%
porteeEulerien(D)
