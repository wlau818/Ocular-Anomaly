cmake_minimum_required(VERSION 3.15)

# Name of C++ project, set language to C++
project(ocular_cpp LANGUAGES CXX)

# Tell the compiler to use modern C++17 standards, and don't allow Silent C++ Version Fallbacks
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find and load packages 
execute_process(
  COMMAND "${PYTHON_EXECUTABLE}" -m pybind11 --cmakedir
  OUTPUT_VARIABLE pybind11_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
find_package(pybind11 REQUIRED)# pybind11 library is needed to link C++ code to Python
find_package(OpenCV REQUIRED)

# Combine our src file into a compiled Python module named "ocular_cpp"
pybind11_add_module(ocular_cpp src/main.cpp)

# Link the external OpenCV graphics libraries to our custom module
target_link_libraries(ocular_cpp PRIVATE ${OpenCV_LIBS})

# Make this cross platform compatible 
if(WIN32)
    # Explicitly define the hidden OpenCV .dll files at runtime
    add_custom_command(TARGET ocular_cpp POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:OpenCV::OpenCV>
        $<TARGET_FILE_DIR:ocular_cpp>
    )
endif()