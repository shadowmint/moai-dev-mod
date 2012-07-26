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
set(PROJECT_KEY "openssl-1.0.1c")

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
set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/libssl.a;${PROJECT_REAL_PATH}/libcrypto.a")
set(LIB_MISSING 0)
foreach(I ${PROJECT_LIB_TARGET})
  if (NOT EXISTS ${I})
    set(LIB_MISSING 1)
  endif()
endforeach()
if (${LIB_MISSING})

  # <CR> breaks configure
  apply_cr_fix("${PROJECT_REAL_PATH}")

  # Dont build a shared lib
  set(BUILD_EXTRA_FLAGS "no-shared")
  if(APPLE)
    set(BUILD_EXTRA_FLAGS "no-asm no-krb5 ${BUILD_EXTRA_FLAGS}")
  endif()

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

# Pick up symbols from openssl that aren't being bound correctly
set(OPENSSL_CRYPTO "${PROJECT_BINARY_DIR}/libcrypto.a")
file(GLOB_RECURSE FILES "${PROJECT_REAL_PATH}/crypto/*.o")
create_lib_archive(${OPENSSL_CRYPTO} "${FILES}")

set(OPENSSL_SSL "${PROJECT_BINARY_DIR}/libssl.a")
file(GLOB_RECURSE FILES "${PROJECT_REAL_PATH}/ssl/*.o")
create_lib_archive(${OPENSSL_SSL} "${FILES}")

set(OPENSSL_ENGINES "${PROJECT_BINARY_DIR}/libengines.a")
file(GLOB_RECURSE FILES "${PROJECT_REAL_PATH}/engines/*.o")
create_lib_archive(${OPENSSL_ENGINES} "${FILES}")

set(OPENSSL_ENGINE_LIBS "${OPENSSL_CRYPTO};${OPENSSL_SSL};${OPENSSL_ENGINES}")

# Lib and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include")
set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET}")
set(PROJECT_PATH ${PROJECT_REAL_PATH})
if(WIN32)
  set(PROJECT_LIBRARIES "${OPENSSL_ENGINE_LIBS};ws2_32")
else()
  set(PROJECT_LIBRARIES "${OPENSSL_ENGINE_LIBS};dl")
endif()
set(PROJECT_NAME "OPENSSL")

# Export libraries
CONFIGURE_FILE(opensslConfig.cmake.in "${PROJECT_BINARY_DIR}/opensslConfig.cmake")
