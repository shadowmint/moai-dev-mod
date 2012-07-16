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

cmake_minimum_required (VERSION 2.6)
project (MOAI)

# Debug mode?
set(CMAKE_BUILD_TYPE Debug)

# Flags
set(CMAKE_C_FLAGS "-Wall -pedantic -Wimplicit-function-declaration -Wreturn-type -Wstrict-prototypes -Wextra")
if(NOT WIN32)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror")
endif()
set (CMAKE_OSX_ARCHITECTURES "i386")

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
foreach(DEP ${PROJECT_DEPS}) 
  add_subdirectory(${DEP})
  get_filename_component_last(${DEP} ITEM_PATH)
  string(TOUPPER ${ITEM_PATH} DEP_ID)
  set(${ITEM_PATH}_DIR "${PROJECT_BINARY_DIR}/3rdparty/${ITEM_PATH}")
  find_package(${ITEM_PATH} REQUIRED)
  list(APPEND PROJECT_EXTRA_INCLUDES ${${DEP_ID}_INCLUDE_DIRS})
  list(APPEND PROJECT_EXTRA_LIBRARIES "${ITEM_PATH}")
  list(APPEND PROJECT_EXTRA_SHARED_LIBRARIES "${ITEM_PATH};${${DEP_ID}_LIBRARIES}")
endforeach()

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