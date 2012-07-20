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
project(c-ares)

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "c-ares-1.7.5")

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Dependency target; skip build if it already exists
set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/.libs/libcares.a")
if (NOT EXISTS ${PROJECT_LIB_TARGET})

  # Platform config
  import_common_build_flags(BUILD_EXTRA_FLAGS)

  # Windows does not play nicely with others
  if (WIN32)
    apply_cr_fix("${PROJECT_REAL_PATH}")
  endif()

  # Create files for working with if they don't exist
  # Weird, not sure why we need to do this.
  if (NOT EXISTS "${PROJECT_REAL_PATH}/inet_ntop.c")
    configure_file("${PROJECT_REAL_PATH}/ares_inet_ntop.c" "${PROJECT_REAL_PATH}/inet_ntop.c" COPY_ONLY)
    configure_file("${PROJECT_REAL_PATH}/ares_inet_ntop.h" "${PROJECT_REAL_PATH}/inet_ntop.h" COPY_ONLY)
  endif()

  # Build
  invoke_autotools("${PROJECT_REAL_PATH}" "${BUILD_EXTRA_FLAGS}")

  # Error if the build using autotools failed
  if (NOT EXISTS ${PROJECT_LIB_TARGET})
   message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIB_TARGET}")
  endif()
endif()

# Lib and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}")
set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET}")
set(PROJECT_NAME "C-ARES")

# Export libraries
CONFIGURE_FILE(c-aresConfig.cmake.in "${PROJECT_BINARY_DIR}/c-aresConfig.cmake")
