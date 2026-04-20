#pragma once
#include <opencv2/core.hpp>

void kmeans_fct(const cv::Mat& m, int k, int iter, cv::Mat& labels, cv::Mat& centres);