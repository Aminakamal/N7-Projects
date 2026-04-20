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
        "{help h usage ?            |       | print this message   }"
        "{input i                   |<none> | input image file     }"
        "{seuil spatial hs          |20     | seuil spatial     }"
        "{seuil colorimetrique hc   |20     | seuil colorimetrique    }"
        "{espsilon eps              |0.1      | epsilon    }"
        "{kmax                      |20      | nb max d'itérations    }";

    CommandLineParser parser(argc, argv, keys);
    parser.about("K-means clustering application");

    if (parser.has("help"))
    {
        parser.printMessage();
        return EXIT_SUCCESS;
    }

    const string imageFilename = parser.get<string>("input");
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

    // 1) to call meanshift we need to first convert the image into floats (CV_32F)
    // see the method Mat.convertTo()
    m.convertTo(m, CV_32FC3);

    // mean shift
    Mat resultat = meanshift_fct(m, hs, hc, eps, kmax);

    int nb_modes = estimation_modes(resultat, hc);

    printf("Nombre de modes: %d\n", nb_modes);


    resultat.convertTo(resultat, CV_8UC3);

    //resultat.convertTo(m2, CV_8UC3);
    imwrite("Image_segmented.jpg", resultat);

    // Create a window for display.
    namedWindow("Display window", cv::WINDOW_AUTOSIZE);
    // Show our image inside it.
    imshow("Display window", resultat);

    // Wait for a keystroke in the window
    waitKey(0);

    //return EXIT_SUCCESS;

    
}
