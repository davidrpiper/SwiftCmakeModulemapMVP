cmake_minimum_required(VERSION 3.29)

# Must at least specify Swift as a language here, otherwise CMake won't be able to determine
# the linker languauge in target_link_libraries later on.
#
# The CXX is not necessary yet (there are no files in the Swift-SDL3-Boilerplate project that are C++)
# but will be necessary later if we want to write C++ interop code with Swift.
#
project(SwiftCMakeModulemapMVP LANGUAGES CXX Swift)

# Force CMake to output compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Verify that we have a new enough compiler
if("${CMAKE_Swift_COMPILER_VERSION}" VERSION_LESS 5.10)
  message(FATAL_ERROR "Bidirectional C++ Interop requires Swift 5.10 or greater. Have ${CMAKE_Swift_COMPILER_VERSION}")
endif()

if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" AND
   NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
  message(FATAL_ERROR "Project requires building with Clang.
  Have ${CMAKE_CXX_COMPILER_ID}")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")

add_subdirectory(dependencies/SwiftCmakeModulemapMVP-dependency)

add_executable(mvp src/main.swift src/another.swift)

# Generate code index for SourceKit
target_compile_options(mvp PUBLIC -index-store-path "${CMAKE_BINARY_DIR}/$<CONFIGURATION>")

# At the moment, this is needed purely for the modulemap file. Just adding it as a source file to the executable doesn't work.
# The modulemap is essentially a header file, and needs to be included (in the sense of "-I") so that Swift can correctly find
# the module to compile against.
#
# For a more modular setup, you might want to create a third outer directory called modules/, and then make a subdirectory
# for each dependency in dependencies/ (so just one called SDL/ for now) then place the modulemap inside that directory,
# pointed to the correct header location(s) in the appropriate dependency. One modulemap directory/file for each dependency.
#
target_include_directories(mvp PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)

target_link_libraries(mvp PRIVATE Swift-CMake-ModuleMap-MVP-Dependency)
