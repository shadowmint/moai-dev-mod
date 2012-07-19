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
project (MOAI)

# Debug mode?
set(CMAKE_BUILD_TYPE Debug)
option(DEBUG_MESSAGES "Show debug messages during build" ON)

# Flags
set(CMAKE_C_FLAGS "-Wall -pedantic -Wimplicit-function-declaration -Wreturn-type -Wstrict-prototypes -Wextra")
set(CMAKE_OSX_ARCHITECTURES "i386")

# Load cmake definitions
file(GLOB_RECURSE PROJECT_INCLUDES "${PROJECT_SOURCE_DIR}/utils/*.cmake")
foreach(PROJECT_INCLUDE ${PROJECT_INCLUDES})
  include(${PROJECT_INCLUDE})
endforeach(PROJECT_INCLUDE ${PROJECT_INCLUDES})

# Deps: self
set(PROJECT_EXTRA_LIBRARIES "")
set(PROJECT_EXTRA_INCLUDES "")
set(PROJECT_EXTRA_SOURCES "")

# Add dependencies
file(GLOB PROJECT_DEPS "${PROJECT_SOURCE_DIR}/3rdparty/*")
list(SORT PROJECT_DEPS)
foreach(PATH ${PROJECT_DEPS}) 

  add_subdirectory(${PATH})

  # Force cmake to look locally for the library instance
  get_filename_component_last(${PATH} ITEM_PATH)

  # Allow _blah, __blah, etc. so the import order is correct
  string(REGEX REPLACE "_+" "" DEP_LOWER ${ITEM_PATH})

  # Convert to dep id
  string(TOUPPER ${DEP_LOWER} DEP_ID)
  set(${ITEM_PATH}_DIR "${PROJECT_BINARY_DIR}/3rdparty/${ITEM_PATH}")

  # Now for cmake to load the local instance of the libraries
  include("${${ITEM_PATH}_DIR}/${DEP_LOWER}Config.cmake")
  list(APPEND PROJECT_EXTRA_INCLUDES "${${DEP_ID}_INCLUDE_DIRS}")
  list(APPEND PROJECT_EXTRA_LIBRARIES "${${DEP_ID}_LIBRARIES}")
endforeach()

# Debug
if(DEBUG_MESSAGES)
  message("Build debug:")
  foreach(INC ${PROJECT_EXTRA_INCLUDES})
    message("- Include: ${INC}")
  endforeach()
  foreach(LIB ${PROJECT_EXTRA_LIBRARIES})
    message("- Library: ${LIB}")
  endforeach()
endif()

# Include dirs
set(PROJECT_INCLUDE_DIRS "")

# Collect source files
file(GLOB_RECURSE SOURCES src/*.c)

# Add extra parts to build
set(SOURCES "${SOURCES};${PROJECT_EXTRA_SOURCES}")
set(PROJECT_INCLUDE_DIRS "${PROJECT_INCLUDE_DIRS};${PROJECT_EXTRA_INCLUDES}")

# libary headers
include_directories(${PROJECT_INCLUDE_DIRS})

# Build library (static)
add_executable(moai ${SOURCES})
target_link_libraries(moai ${PROJECT_EXTRA_LIBRARIES})
set(MOAI_LIBRARIES moai)

# Export libraries
get_property(PROJECT_LOC TARGET moai PROPERTY LOCATION)
set(PROJECT_LIBRARIES ${PROJECT_LOC})
list(APPEND PROJECT_LIBRARIES ${PROJECT_EXTRA_LIBRARIES})

CONFIGURE_FILE(moaiConfig.cmake.in "${PROJECT_BINARY_DIR}/moaiConfig.cmake")
