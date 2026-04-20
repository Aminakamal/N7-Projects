#include "ocv_utils.hpp"

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <iostream>
#include <string>

using namespace cv;
using namespace std;


void kmeans_fct(const Mat& m, int k, int iter, Mat& labels, Mat& centres)
{
    int colonne = m.cols;
    int ligne = m.rows;
    //coordonnées du centre
    float x_mean;
    float y_mean;
    int x_mean_int;
    int y_mean_int;
    int nb;
    //pondération pour la couleur
    float lambda = 30.6;
    RNG rng;

    std::vector<Vec2b> centres_coordonnees;

    //Initialisation
    for (int i=0; i<k; i++){
        int random_colonne = rng.uniform(0,colonne);
        int random_ligne = rng.uniform(0,ligne);
        //choix de centres aléatoire
        centres.push_back(m.at<Vec3f>(random_ligne, random_colonne));
        centres_coordonnees.push_back(Vec2b((uchar)random_ligne, (uchar)random_colonne));
    }
    // on initialise les labels par des 0
    for (int i=0; i<colonne*ligne ; i++){
        labels.push_back(0);
    }
    // début algoritme kmeans
    for (int iteration = 0; iteration < iter; iteration ++){
        // pour normaliser les distances
        float diag2 = static_cast<float>(ligne*ligne + colonne*colonne); // 
        const float color_scale = 255.0*255.0;
        float distance;
        // on parcours les pixels
        for (int i=0; i<colonne * ligne; i++){
            float distance_min = sqrt(pow(ligne,2)+pow(colonne,2));
            int x = i % colonne;
            int y = i / colonne;
            // on parcours les clusters
            for (int j =0; j<k; j++){
                int r = m.at<Vec3f>(y, x)(0);
                int g = m.at<Vec3f>(y, x)(1);
                int b = m.at<Vec3f>(y, x)(2);
                int cx = centres_coordonnees[j][1];
                int cy = centres_coordonnees[j][0];
                int cr = centres.at<Vec3f>(j)(0);
                int cg = centres.at<Vec3f>(j)(1);
                int cb = centres.at<Vec3f>(j)(2);
                distance = (std::pow(x - cx, 2) + std::pow(y - cy, 2))/diag2 + lambda*(std::pow(r-cr, 2) + std::pow(g-cg, 2) + std::pow(b-cb, 2))/color_scale;
                // si le nouveau centre est plus proche on met a jour
                if (distance<=distance_min) {
                    distance_min = distance;
                    labels.at<int>(i) = j;
                }
            }
            
        }
        // mise a jour des centres
        for (int i=0; i<k; i++){
            x_mean = 0.0;
            y_mean = 0.0;
            nb = 0;
            // trouver les pixels appartenant au centre actuel
            for (int j=0; j<colonne*ligne; j++){
                if (labels.at<int>(j) == i){
                    int x = j % colonne;
                    int y = j / colonne;
                    x_mean += static_cast<float>(x);
                    y_mean += static_cast<float>(y);
                    nb ++;
                }
            }
            //si pixels trouvés alors on recalcul le centre
            if (nb > 0) {
                x_mean /= nb;
                y_mean /= nb;
                x_mean_int = static_cast<int>(std::round(x_mean));
                y_mean_int = static_cast<int>(std::round(y_mean));
                centres.at<Vec3f>(i) = m.at<Vec3f>(y_mean_int, x_mean_int);
                centres_coordonnees[i] = Vec2b((uchar)y_mean_int, (uchar)x_mean_int);
            }
        }
    }
}