# This is a placeholder CMakeLists.txt file.
# The tutorial doesn't provide the content of this file, so I will have to
# create a minimal one.

CMAKE_MINIMUM_REQUIRED(VERSION 3.23 FATAL_ERROR)
PROJECT(godot-cpp)

# Create the godot-cpp library
add_library(godot-cpp INTERFACE)

# Add the include directories
target_include_directories(godot-cpp INTERFACE
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/gen/include"
)
