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
project (MOAI_ALL)

# Only build 32-bit, and do that for everything
set(CMAKE_OSX_ARCHITECTURES "i386")

# Add dependencies
add_subdirectory("${PROJECT_SOURCE_DIR}/moaideps")

# Add projects
file(GLOB PROJECT_DEPS "${PROJECT_SOURCE_DIR}/src/*")
list(SORT PROJECT_DEPS)
foreach(PATH ${PROJECT_DEPS}) 
  add_subdirectory("${PATH}")
endforeach()

# Add moai binary
set(PROJECT_PATH "${PROJECT_SOURCE_DIR}/../src/moai")
file(GLOB PROJECT_SOURCES "${PROJECT_PATH}/*.cpp")
add_executable(moai ${PROJECT_SOURCES})

# Deps
include("${PROJECT_BINARY_DIR}/src/moaicore/moaicoreConfig.cmake")
target_link_libraries(moai ${MOAICORE_LIBRARIES})
include_directories(${MOAICORE_INCLUDE_DIRS})

# Host
include("${PROJECT_BINARY_DIR}/src/aku/akuConfig.cmake")
target_link_libraries(moai ${AKU_LIBRARIES})
include_directories(${AKU_INCLUDE_DIRS})
