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
set(PROJECT_KEY "openssl-1.0.0d")

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
set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/crypto/engine/eng_all.o;${PROJECT_REAL_PATH}/libssl.a;${PROJECT_REAL_PATH}/libcrypto.a")
set(LIB_MISSING 0)
foreach(I ${PROJECT_LIB_TARGET})
  if (NOT EXISTS ${I})
    set(LIB_MISSING 1)
  endif()
endforeach()
if (${LIB_MISSING})

  # Platform config
  import_common_build_flags(BUILD_EXTRA_FLAGS)
  if(APPLE) # Special case for openssl
    set(BUILD_EXTRA_FLAGS "-Larch=i386 -Darch=i386")
  endif()

  # <CR> breaks configure
  apply_cr_fix("${PROJECT_REAL_PATH}")

  # Dont build a shared lib
  set(BUILD_EXTRA_FLAGS "no-shared ${BUILD_EXTRA_FLAGS}")

  # Build
  invoke_autotools("${PROJECT_REAL_PATH}" "${BUILD_EXTRA_FLAGS}" CONFIG_KEY "config" FORCE_CLEAN)

endif()

# Error if the build using autotools failed
set(LIB_MISSING 0)
foreach(I ${PROJECT_LIB_TARGET})
  if (NOT EXISTS ${I})
    set(LIB_MISSING 1)
  endif()
endforeach()
if (${LIB_MISSING})
 message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIB_TARGET}")
endif()

# Lib and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include")
set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET}")
if(WIN32)
  set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET};ws2_32")
endif()
set(PROJECT_NAME "OPENSSL")

# Export libraries
CONFIGURE_FILE(opensslConfig.cmake.in "${PROJECT_BINARY_DIR}/opensslConfig.cmake")
