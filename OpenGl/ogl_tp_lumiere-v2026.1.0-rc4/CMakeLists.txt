cmake_minimum_required(VERSION 3.10)
project(tp3 VERSION 2026.1.0 LANGUAGES CXX)

option(BUILD_TEAPOT "Build teapot sample" ON)
option(ENABLE_WARNINGS_AS_ERRORS "Treat warnings as errors" OFF)
option(BUILD_SHARED_LIBS "Build shared libraries" ON)

# set library suffix
set(CMAKE_DEBUG_POSTFIX "d")

if(BUILD_SHARED_LIBS)
    if(WIN32)
        # export all symbols on a windows build of dynamic libs
        set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS  ON)
    endif()
endif()

set(CMAKE_CXX_STANDARD 17)

include(CheckIPOSupported)
check_ipo_supported(RESULT result)
message(STATUS "IPO supported: ${result}")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ${result})

##############################################################
# Find dependencies
##############################################################

set(OpenGL_GL_PREFERENCE "GLVND")
find_package(OpenGL REQUIRED)
message(STATUS "OPENGL_gl_LIBRARY: ${OPENGL_gl_LIBRARY}")

if(MSVC)
    set(GLUT_ROOT_PATH "${CMAKE_SOURCE_DIR}/freeglut")
    message(STATUS "GLUT_ROOT_PATH: ${GLUT_ROOT_PATH}")
endif()
find_package(GLUT REQUIRED)
message(STATUS "GLUT_FOUND: ${GLUT_FOUND}")
message(STATUS "GLUT_INCLUDE_DIR: ${GLUT_INCLUDE_DIR}")
message(STATUS "GLUT_LIBRARIES: ${GLUT_LIBRARIES}")

##############################################################
# Flags
##############################################################

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    set(MY_COMPILE_OPTIONS "-Wall;-Wextra;-pedantic;-Wno-comment;-Wshadow;-Wnon-virtual-dtor;-Wpedantic;-Wconversion;-Wmisleading-indentation;-Wsign-conversion")
    if(ENABLE_WARNINGS_AS_ERRORS)
        list(APPEND MY_COMPILE_OPTIONS "-Werror")
    endif()
elseif(MSVC)
    set(MY_COMPILE_OPTIONS "/W4;/permissive-")
    if(ENABLE_WARNINGS_AS_ERRORS)
        list(APPEND MY_COMPILE_OPTIONS "/WX")
    endif()
endif()

if(APPLE)
    list(APPEND MY_COMPILE_OPTIONS "-Wno-deprecated-declarations")
endif()

##############################################################
# Imgui
##############################################################
set(IMGUI_DIR ${PROJECT_SOURCE_DIR}/imgui)
set(IMGUI_SOURCES 
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/misc/cpp/imgui_stdlib.cpp
    ${IMGUI_DIR}/backends/imgui_impl_glut.cpp
    ${IMGUI_DIR}/backends/imgui_impl_opengl2.cpp
)

add_library(imgui ${IMGUI_SOURCES})

target_include_directories(
    imgui
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>/imgui
        $<INSTALL_INTERFACE:include>
)
target_compile_definitions(imgui PUBLIC IMGUI_DISABLE_DEMO_WINDOWS)
target_link_libraries(imgui PUBLIC OpenGL::GL OpenGL::GLU GLUT::GLUT)

# set library version
set_target_properties(imgui PROPERTIES VERSION ${PROJECT_VERSION} SOVERSION ${PROJECT_VERSION_MAJOR})

##############################################################
# Main applications
##############################################################

add_executable(lumiere lumiere.cpp lumiere.hpp)
#target_include_directories(lumiere PUBLIC ${OPENGL_INCLUDE_DIR} ${GLUT_INCLUDE_DIR})
#target_link_libraries(lumiere PUBLIC ${OPENGL_opengl_LIBRARY} ${OPENGL_glu_LIBRARY} ${GLUT_LIBRARIES})
target_link_libraries(lumiere OpenGL::GL OpenGL::GLU GLUT::GLUT imgui)

target_compile_options(lumiere PRIVATE ${MY_COMPILE_OPTIONS})

if(MSVC)
    target_compile_definitions(lumiere PUBLIC -DNOMINMAX)
endif()

if(BUILD_TEAPOT)
    add_executable(teapot teapotLight.cpp)
    #target_include_directories(teapot PUBLIC ${OPENGL_INCLUDE_DIR} ${GLUT_INCLUDE_DIR})
    #target_link_libraries(teapot PUBLIC ${OPENGL_opengl_LIBRARY} ${OPENGL_glu_LIBRARY} ${GLUT_LIBRARIES})
    target_link_libraries(teapot OpenGL::GL OpenGL::GLU GLUT::GLUT)

    target_compile_options(teapot PRIVATE ${MY_COMPILE_OPTIONS})

    if(MSVC)
        target_compile_definitions(teapot PUBLIC -DNOMINMAX)
    endif()
endif()