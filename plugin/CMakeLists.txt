cmake_minimum_required(VERSION 3.21)

# Frostfall.dll — the SKSE plugin behind Frostfall's HUD bars, start-up logo and SKSE Menu Framework page.
project(Frostfall VERSION 4.1.0 LANGUAGES CXX)

find_package(CommonLibSSE CONFIG REQUIRED)

# The ESL build is for the ESL-flagged Frostfall.esp (compacted FormIDs): it looks the globals up by their new ids.
option(FROSTFALL_ESL "Build for the ESL (compacted FormID) Frostfall.esp" OFF)

add_commonlibsse_plugin(${PROJECT_NAME} NAME "Frostfall" AUTHOR "CageTV" SOURCES
    src/main.cpp
    src/Settings.cpp
    src/Game.cpp
    src/Hud.cpp
    src/Menu.cpp
    src/NativeMcm.cpp
    src/Hotkeys.cpp
)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)
target_include_directories(${PROJECT_NAME} PRIVATE src include)
target_precompile_headers(${PROJECT_NAME} PRIVATE src/PCH.h)
target_compile_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:/Z7>)
target_link_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:/DEBUG /OPT:REF /OPT:ICF>)
if(FROSTFALL_ESL)
    target_compile_definitions(${PROJECT_NAME} PRIVATE FROSTFALL_ESL)
endif()
