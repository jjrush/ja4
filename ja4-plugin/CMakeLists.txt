cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(ZeekPluginJA4)

# When Zeek builds Broker with internal (static) CAF, the exported cmake
# files still reference CAF::core/io/net and the "broker" shared-lib target
# as dependencies.  Create stub IMPORTED targets so the import succeeds
# even when only the static library was installed.
foreach(_caf_target CAF::core CAF::io CAF::net)
    if(NOT TARGET ${_caf_target})
        add_library(${_caf_target} INTERFACE IMPORTED)
    endif()
endforeach()
if(NOT TARGET broker)
    add_library(broker SHARED IMPORTED)
    set_target_properties(broker PROPERTIES IMPORTED_LOCATION "${BRO_CONFIG_LIB_DIR}/libbroker.so")
endif()

include(ZeekPlugin)

# Zeek 7.x Broker headers require C++20 (concepts, requires).
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

zeek_plugin_begin(JA4 JA4 ${ZEEK_PLUGIN_BEGIN_OPTS})
zeek_plugin_cc(src/Plugin.cc src/ja4.cc src/common.cc src/ja4d.cc)
zeek_plugin_bif(src/ja4.bif)
zeek_plugin_dist_files(README CHANGES COPYING VERSION)
zeek_plugin_scripts(scripts/__load__.zeek) 
zeek_plugin_end()

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" VERSION LIMIT_COUNT 1)

if ("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    # Allows building rpm/deb packages via "make package" in build dir.
    include(ConfigurePackaging)
    ConfigurePackaging(${VERSION})

# ASan disabled for now — mixing sanitized plugin with non-sanitized Zeek
# binary causes false positives and interop issues.
# if (CMAKE_BUILD_TYPE MATCHES "Debug")
#     message(STATUS "Enabling AddressSanitizer (ASan)")
#     add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer -g)
#     add_link_options(-fsanitize=address,undefined)
# endif()

endif ()
