#pragma once
#include <opencv2/core.hpp>

cv::Mat meanshift_fct(cv::Mat m, int hs, int hc, int eps, int kmax);