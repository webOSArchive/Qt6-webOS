cmake_minimum_required(VERSION 3.16)
project(qt6-hello-world VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Find Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

# Application sources
set(SOURCES
    src/main.cpp
    src/resources.qrc
)

# Create executable
qt_add_executable(qt6-hello-world ${SOURCES})

target_link_libraries(qt6-hello-world PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

# Installation
install(TARGETS qt6-hello-world DESTINATION bin)
