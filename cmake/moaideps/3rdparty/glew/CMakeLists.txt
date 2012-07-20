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
project(expat)

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "glew-1.5.6")

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Dependency target; skip build if it already magically exists
if(WIN32)
  set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/lib/libglew32.a")
else()
  set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/lib/libGLEW.a")
endif()
if (NOT EXISTS ${PROJECT_LIB_TARGET})

  # Window doesn't play well with others
  if (WIN32)
    apply_cr_fix("${PROJECT_REAL_PATH}")
  endif()

  # Platform config
  if(APPLE)
    set(BUILD_EXTRA_FLAGS "CFLAGS.EXTRA=\"-arch i386\" LDFLAGS.EXTRA=\"-arch i386\"")
  endif()

  # Generate build script
  set(MAKE_CPATH "${PROJECT_REAL_PATH}/cmake.configure")
  set(MAKE_COMMAND "make ${BUILD_EXTRA_FLAGS}")
  file(WRITE ${MAKE_CPATH} ${MAKE_COMMAND})

  # glew is a strange one, it doesn't setup any of its own stuff.
  execute_process(COMMAND chmod 755 config/config.guess WORKING_DIRECTORY ${PROJECT_REAL_PATH})
  configure_file("${PROJECT_REAL_PATH}/Makefile.default" "${PROJECT_REAL_PATH}/Makefile")
  file(MAKE_DIRECTORY "${PROJECT_REAL_PATH}/bin")
  file(MAKE_DIRECTORY "${PROJECT_REAL_PATH}/lib")

  # Build
  execute_process(COMMAND chmod 755 "${MAKE_CPATH}" WORKING_DIRECTORY ${PROJECT_REAL_PATH})
  execute_process(COMMAND sh ${MAKE_CPATH} WORKING_DIRECTORY ${PROJECT_REAL_PATH})

  # ? Magic to generate symbols
  execute_process(COMMAND ranlib ${PROJECT_LIB_TARGET} WORKING_DIRECTORY ${PROJECT_REAL_PATH})

endif()

# Error if the build using autotools failed
if (NOT EXISTS ${PROJECT_LIB_TARGET})
 message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIB_TARGET}")
endif()

# Lib and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include")
set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET}")
set(PROJECT_NAME "GLEW")

# Export libraries
CONFIGURE_FILE(glewConfig.cmake.in "${PROJECT_BINARY_DIR}/glewConfig.cmake")
