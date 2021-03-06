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
add_subdirectory("${PROJECT_SOURCE_DIR}/src")

# Path
set(PROJECT_PATH "${PROJECT_SOURCE_DIR}/../src/moai")

# HAX!
configure_file("${PROJECT_PATH}/../hosts/GlutHostMain.cpp" "${PROJECT_BINARY_DIR}/main.cpp")

# Moai binary
set(PROJECT_SOURCES "${PROJECT_BINARY_DIR}/main.cpp")
add_executable(moai ${PROJECT_SOURCES})

# Host
include("${PROJECT_BINARY_DIR}/src/aku/akuConfig.cmake")
include_directories(${AKU_INCLUDE_DIRS})
set(EXTRA_LIBS "${EXTRA_LIBS};${AKU_LIBRARIES}")

# Deps
include("${PROJECT_BINARY_DIR}/src/moaicore/moaicoreConfig.cmake")
include_directories(${MOAICORE_INCLUDE_DIRS})
set(EXTRA_LIBS "${EXTRA_LIBS};${MOAICORE_LIBRARIES}")

# Link
target_link_libraries(moai ${EXTRA_LIBS})
