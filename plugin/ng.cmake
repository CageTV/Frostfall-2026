# Frostfall.dll on alandtse's CommonLibSSE-NG; included by E:/WorkSpace/ng-build/CMakeLists.txt (see ng_plugin there).
# Two targets, like the legacy build: the regular Frostfall.esp and the ESL one (FROSTFALL_ESL, compacted FormIDs).
foreach(variant Regular ESL)
    set(defs "")
    if(variant STREQUAL "ESL")
        set(defs FROSTFALL_ESL)
    endif()
    ng_plugin(TARGET Frostfall${variant} NAME Frostfall VERSION 4.1.0 ROOT "${CMAKE_CURRENT_LIST_DIR}"
        SOURCES src/main.cpp src/Settings.cpp src/Game.cpp src/Hud.cpp src/Menu.cpp src/NativeMcm.cpp src/Hotkeys.cpp
        INCLUDES "${CMAKE_CURRENT_LIST_DIR}/src" "${CMAKE_CURRENT_LIST_DIR}/include"
        PCH "${CMAKE_CURRENT_LIST_DIR}/src/PCH.h" DEFINES ${defs})
endforeach()
