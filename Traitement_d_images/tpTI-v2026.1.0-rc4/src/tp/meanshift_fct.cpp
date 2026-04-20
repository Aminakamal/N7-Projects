#include "meanshift_fct.hpp"
#include <opencv2/core.hpp>
#include <iostream>
#include <vector>
#include <cmath>

using namespace cv;
using namespace std;

cv::Mat meanshift_fct(cv::Mat m, int hs, int hc, int eps, int kmax){
    
    Mat resultat = m.clone(); 
    
    int colonne = m.cols;
    int ligne = m.rows;

    //pour chaque pixel
    for (int i = 0; i < colonne * ligne; i++){
        //coordonnées du pixel initial
        int xi = i % colonne;
        int yi = i / colonne;
        //coordonnées du pixel modifié pendant l'algoritme suite au shift
        float x_act = (float)xi;
        float y_act = (float)yi;

        Vec3f couleur_act = m.at<Vec3f>(yi, xi);

        int k = 0;
        float shift = eps + 1.0;
        // on applique l'algorithme tant que les conditions d'arret ne sont pas respectées
        while (shift > eps && k < kmax){
            
            float somme_x = 0;
            float somme_y = 0;
            float somme_r = 0;
            float somme_g = 0;
            float somme_b = 0;
            float total_poids = 0;
            //Pour ne pas dépasser le cadre de l'image
            int min_x = std::max(0, (int)(x_act - hs));
            int max_x = std::min(colonne, (int)(x_act + hs + 1));
            int min_y = std::max(0, (int)(y_act - hs));
            int max_y = std::min(ligne, (int)(y_act + hs + 1));
            //parcours des voisins
            for (int y = min_y; y < max_y; y++){
                for (int x = min_x; x < max_x; x++){
                    
                    Vec3f pix = m.at<Vec3f>(y, x);
                    //pas de racine carrée pour diminuer les calculs
                    float dist_spatial = (x_act - x)*(x_act - x) + (y_act - y)*(y_act - y);
                    
                    if (dist_spatial <= hs*hs) {
                        float dist_color = (couleur_act[0] - pix[0])*(couleur_act[0] - pix[0]) +
                                           (couleur_act[1] - pix[1])*(couleur_act[1] - pix[1]) +
                                           (couleur_act[2] - pix[2])*(couleur_act[2] - pix[2]);

                        if (dist_color <= hc*hc) {
                            somme_x += x;
                            somme_y += y;
                            somme_r += pix[0];
                            somme_g += pix[1];
                            somme_b += pix[2];
                            total_poids += 1.0;
                        }
                    }
                }
            }
            // pour ne pas diviser par 0
            if (total_poids == 0) break;
            //on fait le mean
            float moy_x = somme_x / total_poids;
            float moy_y = somme_y / total_poids;
            Vec3f moy_couleur(somme_r / total_poids, somme_g / total_poids, somme_b / total_poids);

            float diff_spatial = (x_act - moy_x)*(x_act - moy_x) + (y_act - moy_y)*(y_act - moy_y);
            float diff_color = (couleur_act[0] - moy_couleur[0])*(couleur_act[0] - moy_couleur[0]) +
                               (couleur_act[1] - moy_couleur[1])*(couleur_act[1] - moy_couleur[1]) +
                               (couleur_act[2] - moy_couleur[2])*(couleur_act[2] - moy_couleur[2]);
            
            shift = diff_spatial + diff_color;
            //on fait le shift
            x_act = moy_x;
            y_act = moy_y;
            couleur_act = moy_couleur;

            k++;
        }
        //on met à jour le pixel
        resultat.at<Vec3f>(yi, xi) = couleur_act;
    }

    return resultat;
}