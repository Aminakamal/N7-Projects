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


int estimation_modes(Mat m, int hc){
    std::vector<Vec3f> modes_uniques;

    for (int y = 0; y < m.rows; y++){
        for (int x = 0; x < m.cols; x++){
            Vec3f couleur_pixel = m.at<Vec3f>(y, x);
            bool existe = false;

            for (Vec3f& mode : modes_uniques){
                if (cv::norm(couleur_pixel - mode) < hc){
                    existe = true;
                    break;
                } 
            } 

            if (!existe){
                modes_uniques.push_back(couleur_pixel);
            } 
        }
    }

    return modes_uniques.size();
}