#include <pybind11/pybind11.h> // Library to connect C++ and Python
#include <pybind11/numpy.h>    // Allows C++ to talk directly to Python NumPy arrays
#include <opencv2/opencv.hpp>   // C++ OpenCV library for images

namespace py = pybind11;

py::array_t<float> prepare_input_data(std::string path) {
    
    cv::Mat frame = cv::imread(path); // Load the image from the hard drive into C++ memory
    
    // Safety Check: if the image doesn't exist throw an error
    if (frame.empty()) {
        throw std::runtime_error("Failed to load image. Check the path!");
    }

    cv::Mat processedimg; // Create a blank matrix to hold our final image

    // Convert colors from Blue Green Red (BGR) to Red Green Blue (RGB) and dump the result into processedimg
    cv::cvtColor(frame, processedimg, cv::COLOR_BGR2RGB);

    // Resize processed image to 224x224
    cv::resize(processedimg, processedimg, cv::Size(224, 224));

    // Adjust pixel math scale for ResNet50 CNN to process with ease
    processedimg.convertTo(processedimg, CV_32FC3, 1.0 / 255.0);

    // Copy pixel data into a NumPy array with shape (224, 224, 3)
    py::array_t<float> result({224, 224, 3});
    auto buf = result.request();
    std::memcpy(buf.ptr, processedimg.data, 224 * 224 * 3 * sizeof(float));

    return result;
}

// Register the function so Python can see it
PYBIND11_MODULE(ocular_cpp, m) {
    m.doc() = "Ocular image preprocessing module";
    m.def("prepare_input_data", &prepare_input_data,
          "Load, resize, and normalize a retinal image to a (224, 224, 3) float32 array",
          py::arg("path"));
}