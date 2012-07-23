# Copyright 2012 Douglas Linder
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required (VERSION 2.8)
project(freeglut)

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "freeglut-2.8.0")

# Copy to build directory
set(PROJECT_SRC_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
set(PROJECT_REAL_PATH "${PROJECT_BINARY_DIR}/${PROJECT_KEY}")
file(COPY ${PROJECT_SRC_PATH} DESTINATION ${PROJECT_BINARY_DIR})

# Source and includes
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Dependency target; skip build if it already magically exists
set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/src/.libs/libglut.a;")
if (NOT EXISTS ${PROJECT_LIB_TARGET})

  # Platform config
  if(APPLE)
    import_common_build_flags(BUILD_EXTRA_FLAGS EXTRA_C_FLAGS "-I/usr/X11R6/include")
  else()
    import_common_build_flags(BUILD_EXTRA_FLAGS)
  endif()
  set(BUILD_EXTRA_FLAGS "${BUILD_EXTRA_FLAGS} --enable-shared=no")

  # <CR> breaks configure
  apply_cr_fix("${PROJECT_REAL_PATH}")

  # Build
  invoke_autotools("${PROJECT_REAL_PATH}" "${BUILD_EXTRA_FLAGS}")

endif()

# Error if the build using autotools failed
if (NOT EXISTS ${PROJECT_LIB_TARGET})
 message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIB_TARGET}")
endif()

# Opengl
if(APPLE)
  include_directories(/System/Library/Frameworks)
  find_library(COCOA_LIBRARY Cocoa)
  find_library(OpenGL_LIBRARY OpenGL)
  mark_as_advanced(COCOA_LIBRARY OpenGL_LIBRARY)
  set(EXTRA_LIBS "${EXTRA_LIBS};${COCOA_LIBRARY};${OpenGL_LIBRARY}")
elseif(WIN32)
  find_package(OpenGL)
  set(EXTRA_LIBS "${EXTRA_LIBS};gdi32;opengl32;glu32")
else()
  find_package(OpenGL)
  set(EXTRA_LIBS "${EXTRA_LIBS};${OPENGL_LIBRARIES}")
endif()

# Lib and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include/GL")
set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET};${EXTRA_LIBS}")
set(PROJECT_NAME "GLUT")

# Export libraries
CONFIGURE_FILE(glutConfig.cmake.in "${PROJECT_BINARY_DIR}/glutConfig.cmake")
