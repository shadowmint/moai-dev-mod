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

project(glut)
cmake_minimum_required (VERSION 2.8)
string(TOUPPER ${PROJECT_NAME} _PROJECT_NAME)

# On OSX use the inbuilt glut
if(APPLE)

  include_directories(/System/Library/Frameworks)
  find_package(GLUT)
  find_package(OPENGL)
  find_library(COCOA_LIBRARY Cocoa)
  mark_as_advanced(COCOA_LIBRARY OPENGL_LIBRARIES GLUT_LIBRARIES)
  set(EXTRA_LIBS "${EXTRA_LIBS};${COCOA_LIBRARY};${OPENGL_LIBRARIES};${GLUT_LIBRARIES}")

  # Lib and includes
  set(PROJECT_INCLUDE_DIRS "${GLUT_INCLUDE_DIRS};${OPENGL_INCLUDE_DIRS}")
  set(PROJECT_LIBRARIES "${EXTRA_LIBS}")
  set(PROJECT_NAME "GLUT")

# Otherwise, use freeglut
else()

  # Import macros & setup
  file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
  foreach(ITEM ${PROJECT_MACROS})
    include(${ITEM})
  endforeach()

  # Config
  set(PROJECT_KEY "freeglut-2.8.0")

  # Source and includes
  set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
  get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
  file(GLOB PROJECT_SOURCES "${PROJECT_REAL_PATH}/src/*.c")
  set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include")
  #filter_list("${PROJECT_SOURCES}" "lua.c;luac.c" PROJECT_SOURCES)
  if (${DEBUG_MESSAGES})
    message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
  endif()

  # Build library (static)
  include_directories(${PROJECT_INCLUDE_DIRS})
  add_library(${PROJECT_NAME} STATIC ${PROJECT_SOURCES})

  # Opengl
  if(WIN32)
    find_package(OpenGL)
    set(EXTRA_LIBS "gdi32;opengl32;glu32;winmm")
  elseif(APPLE)
    find_package(OpenGL)
    set(EXTRA_LIBS "${OPENGL_LIBRARIES}")
    include_directories(/usr/X11R6/include/)
    link_directories(/usr/X11R6/lib)
  else()
    find_package(OpenGL)
    set(EXTRA_LIBS "${OPENGL_LIBRARIES};Xi")
  endif()

  # Lib and includes
  set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include/GL")
  set(PROJECT_LIBRARIES "${PROJECT_NAME};${EXTRA_LIBS}")

endif()
CONFIGURE_FILE(${PROJECT_NAME}Config.cmake.in "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")

