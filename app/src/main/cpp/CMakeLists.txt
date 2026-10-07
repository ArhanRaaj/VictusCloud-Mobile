cmake_minimum_required(VERSION 3.22)
project(mjl_native C CXX)

set(CMAKE_CXX_STANDARD 17)

add_library(mjl_native SHARED
    mjl_native.cpp
    jvm_launcher.cpp
)

find_library(log-lib log)
find_library(android-lib android)
find_library(egl-lib EGL)
find_library(glesv2-lib GLESv2)

target_link_libraries(mjl_native
    ${log-lib}
    ${android-lib}
    ${egl-lib}
    ${glesv2-lib}
)

# Placeholder for the Pojav-style prebuilt components. Drop the following
# .so files into src/main/cpp/libs/<abi>/ and they will be packaged:
#   libjvm.so            (openjdk / mobile port)
#   libopenal.so         (audio)
#   libgl4es_114.so      (GL 2.x translation)
#   libvirglrenderer.so  (virgl renderer option)
set(PREBUILT_DIR ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI})
if(EXISTS ${PREBUILT_DIR})
    file(GLOB PREBUILT_LIBS ${PREBUILT_DIR}/*.so)
    foreach(lib ${PREBUILT_LIBS})
        get_filename_component(libname ${lib} NAME_WE)
        add_library(${libname} SHARED IMPORTED)
        set_target_properties(${libname} PROPERTIES IMPORTED_LOCATION ${lib})
    endforeach()
endif()
