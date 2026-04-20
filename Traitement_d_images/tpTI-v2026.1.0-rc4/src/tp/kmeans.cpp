#include "ocv_utils.hpp"

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <iostream>
#include <string>
#include "kmeans_fct.hpp"
#include "meanshift_fct.hpp"
#include "estimation_modes.hpp"

using namespace cv;
using namespace std;


int main(int argc, char** argv)
{
    // ============================================================================
    // CommandLineParser: How to handle command-line arguments
    // ============================================================================
    // When you run a program from the terminal, you can pass arguments to it.
    // For example: ./kmeans -i=cat.jpg -k=5 --gt=ground_truth.jpg
    //
    // The CommandLineParser helps us extract and validate these arguments.
    //
    // HOW THE "keys" STRING WORKS:
    // Each line in curly braces {} defines one parameter with this format:
    // "{name aliases | default_value | description}"
    //
    // - name: The primary name for the parameter (e.g., "input", "k")
    // - aliases: Short versions you can use instead (e.g., "i" for "input")
    // - default_value: What value to use if the user doesn't provide this parameter
    //   * <none> means the parameter is REQUIRED (program will fail without it)
    //   * Empty string means the parameter is OPTIONAL
    //   * Any other value is used as the default
    // - description: Help text shown when user runs the program with --help
    //
    // IMPORTANT: SYNTAX FOR PASSING VALUES
    // OpenCV's CommandLineParser requires an EQUALS SIGN (=) to pass values:
    // ✓ CORRECT:   -i=cat.jpg  or  --input=cat.jpg
    // ✗ WRONG:     -i cat.jpg  (this treats -i as a boolean flag, "cat.jpg" ignored)
    //
    // EXAMPLES OF HOW TO USE THIS PROGRAM:
    // ./kmeans -i=cat.jpg -k=5                          (required parameters only)
    // ./kmeans --input=cat.jpg -k=5 --gt=truth.jpg      (with optional groundtruth)
    // ./kmeans --help                                   (shows help message)
    //
    // RETRIEVING THE VALUES:
    // After defining the parameters, use parser.get<Type>("name") to retrieve them:
    // - parser.get<String>("input") gets the filename as a string
    // - parser.get<int>("k") gets the number of clusters as an integer
    //
    // HOW TO ADD A NEW PARAMETER (Example: number of iterations):
    // 1. Add a new line in the "keys" string:
    //    "{iterations iter  |100    | maximum number of iterations }"
    //    This creates an optional parameter with default value 100
    //
    // 2. Retrieve it after parser.check():
    //    const int iterations = parser.get<int>("iterations");
    //
    // 3. Use it in your program, for example when calling kmeans:
    //    kmeans(data, k, labels, TermCriteria(..., iterations, ...), ...);
    //
    // 4. Users can now run: ./kmeans -i=cat.jpg -k=5 --iterations=200
    //    Remember: use = to pass the value!
    //
    // Complete documentation can be found here
    // https://docs.opencv.org/4.6.0/d0/d2e/classcv_1_1CommandLineParser.html
    // ============================================================================

    const std::string keys =
        "{help h usage ?            |           | print this message   }"
        "{input i                   |<none>     | input image file     }"
        "{k                         |<none>     | number of clusters   }"
        "{groundtruth gt            |           | ground truth segmentation image (optional) }"
        "{iterations iter           |10         | maximum number of iterations }"
        "{kmeans_cv                 |true       | what kmeans function to use }"
        "{meanshift                 |false      | using meanshift or not }"
        "{seuil spatial hs          |15         | seuil spatial }"
        "{seuil colorimetrique hc   |3          | seuil colorimetrique }"
        "{espsilon eps              |0.1        | epsilon }"
        "{kmax                      |20         | nb max d'itérations pour meanshift }";

    CommandLineParser parser(argc, argv, keys);
    parser.about("K-means clustering application");

    if (parser.has("help"))
    {
        parser.printMessage();
        return EXIT_SUCCESS;
    }

    const string imageFilename = parser.get<string>("input");
    const int k = parser.get<int>("k");
    const string groundTruthFilename = parser.get<string>("groundtruth");
    const int iterations = parser.get<int>("iterations");
    const bool kmeans_cv = parser.get<bool>("kmeans_cv");
    const bool meanshift = parser.get<bool>("meanshift");
    const int hs = parser.get<int>("hs");
    const int hc = parser.get<int>("hc");
    const int eps = parser.get<int>("eps");
    const int kmax = parser.get<int>("kmax");

    if (!parser.check())
    {
        parser.printErrors();
        return EXIT_FAILURE;
    }

    // just for debugging, show the parsed arguments
    {
        cout << " Program called with the following arguments:" << endl;
        cout << " \timage file: " << imageFilename << endl;
        cout << " \tk: " << k << endl;
        if(!groundTruthFilename.empty()) cout << " \tground truth segmentation: " << groundTruthFilename << endl;
    }

    // load the color image to process from file
    Mat m = imread(imageFilename, cv::IMREAD_COLOR);

    // Check for invalid input
    if(imageFilename.empty())
    {
        cout << "Could not open or find the image" << std::endl;
        return EXIT_FAILURE;
    }

    // for debugging use the macro PRINT_MAT_INFO to print the info about the matrix, like size and type
    PRINT_MAT_INFO(m);

    // 1) to call kmeans we need to first convert the image into floats (CV_32F)
    // see the method Mat.convertTo()
    m.convertTo(m, CV_32F);

    // 2) kmeans asks for a mono-dimensional list of "points". Our "points" are the pixels of the image that can be seen as 3D points
    // where each coordinate is one of the color channels (e.g. R, G, B). But they are organized as a 2D table, we need
    // to re-arrange them into a single vector.
    // see the method Mat.reshape(), it is similar to matlab's reshape function.

    // now we can call kmeans(...)

    // mean shift
    if (meanshift == true){
        m = meanshift_fct(m, hs, hc, eps, kmax);

    int nb_modes = estimation_modes(m, hc);

    printf("Nombre de modes: %d\n", nb_modes);
    }


    Mat labels;
    Mat centres;
    int colonne = m.cols;
    int ligne = m.rows;
    if (kmeans_cv == true){
        int value = cv::kmeans(m.reshape(1, ligne * colonne), k, labels,
                       cv::TermCriteria(cv::TermCriteria::EPS+cv::TermCriteria::COUNT, iterations, 1.0),
                       iterations, cv::KMEANS_PP_CENTERS,centres);
    } else {
        kmeans_fct(m, k, iterations, labels, centres);
    }


    Mat m2(ligne, colonne, CV_32FC3);
    centres = centres.reshape(3, centres.rows);
    for (int i=0, j=0; i<ligne; i++) {
        for (j=0; j<colonne; j++) {
            if (k==2){
                if (labels.at<int>(i*colonne + j) == 0) {
                    m2.at<Vec3f>(i, j) = Vec3f(0,0,0);
                } else {
                    m2.at<Vec3f>(i, j) = Vec3f(255,255,255);
                }
            } else {
            m2.at<Vec3f>(i, j) = centres.at<Vec3f>(labels.at<int>(i*colonne + j));
            }
        }
    }

    if (k==2 && !groundTruthFilename.empty()) {
        Mat mref = imread(groundTruthFilename, cv::IMREAD_COLOR);
        mref.convertTo(mref, CV_32F);
        int TP = 0;
        int TF = 0;
        int FP = 0;
        int FN = 0;
        for (int i=0, j=0; i<ligne; i++) {
            for (j=0; j<colonne; j++) {
                bool m_noir = (m2.at<Vec3f>(i, j)[0] < 128);
                Vec3f refPixel = mref.at<Vec3f>(i, j);
                bool mref_noir = ((refPixel[0] + refPixel[1] + refPixel[2]) / 3 < 128);

                if (m_noir && mref_noir) {
                    TP++;
                } else if (!m_noir && !mref_noir) {
                    TF++;
                } else if (!m_noir && mref_noir) {
                    FN++;
                } else if (m_noir && !mref_noir) {
                    FP++;
                }
            }
        }
    float P = (float)TP / (TP + FP);
    float S = (float)TP / (TP + FN);
    float DSC = (float)2 * TP / (2 * TP + FP + FN);
    if (DSC < 0.3){
        int TP_temp = TP;
        TP = TF;
        TF = TP_temp;

        int FP_temp = FP;
        FP = FN;
        FN = FP_temp;

        P = (float)TP / (TP + FP);
        S = (float)TP / (TP + FN);
        DSC = (float)2 * TP / (2 * TP + FP + FN);
    } 
    printf("Precision: %f\n", P);
    printf("Sensitivity: %f\n", S);
    printf("Dice Similarity Coefficient: %f\n", DSC);
    }

    //m2.convertTo(m2, CV_8UC3);
    imwrite("Image_segmented.jpg", m2);

    m2.convertTo(m2, CV_8UC3);

    // Create a window for display.
    namedWindow("Display window", cv::WINDOW_AUTOSIZE);
    // Show our image inside it.
    imshow("Display window", m2);

    // Wait for a keystroke in the window
    waitKey(0);

    //return EXIT_SUCCESS;

    
}
