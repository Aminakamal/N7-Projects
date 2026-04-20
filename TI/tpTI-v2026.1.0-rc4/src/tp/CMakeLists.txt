add_executable( kmeans kmeans.cpp ocv_utils.cpp ocv_utils.hpp kmeans_fct.cpp meanshift_fct.cpp estimation_modes.cpp)
target_link_libraries( kmeans ${OpenCV_LIBS} )
target_compile_options(kmeans PRIVATE ${MY_COMPILE_OPTIONS})
target_compile_definitions(kmeans PUBLIC ${MY_COMPILE_DEFINITIONS})

add_executable( meanshift meanshift.cpp meanshift_fct.cpp ocv_utils.cpp ocv_utils.hpp estimation_modes.cpp)
target_link_libraries( meanshift ${OpenCV_LIBS} )
target_compile_options(meanshift PRIVATE ${MY_COMPILE_OPTIONS})
target_compile_definitions(meanshift PUBLIC ${MY_COMPILE_DEFINITIONS})