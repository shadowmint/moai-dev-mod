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
project(openssl)

# Import macros & setup
string(TOUPPER ${PROJECT_NAME} _PROJECT_NAME)
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "openssl-1.0.1c")

# Setup
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()
set(CMAKE_C_FLAGS "-std=c99")

# Config
add_definitions(-DOPENSSL_NO_KRB5)
add_definitions(-DOPENSSL_NO_DEPRECATED)

# Openssl config uses symlinks that dont work on windwos
set(PROJECT_CUSTOM_INC_SET "")
set(PROJECT_CUSTOM_INCLUDES "${CMAKE_CURRENT_BINARY_DIR}/include")
file(COPY ${PROJECT_REAL_PATH}/include DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
file(GLOB_RECURSE PROJECT_CUSTOM_INC "${PROJECT_REAL_PATH}/*.h")
foreach(ITEM ${PROJECT_CUSTOM_INC}) 
  get_filename_component(ITEM_PATH ${ITEM} PATH)
  get_filename_component_last(${ITEM_PATH} ITEM_LAST_PATH)
  if(NOT ITEM_LAST_PATH STREQUAL "openssl")
    string(REPLACE "${ITEM_PATH}" "" ITEM_PATH ${ITEM})
    configure_file(${ITEM} ${PROJECT_CUSTOM_INCLUDES}/openssl/${ITEM_PATH} COPY_ONLY)
    list(APPEND PROJECT_CUSTOM_INC_SET ${PROJECT_CUSTOM_INCLUDES}/openssl/${ITEM_PATH})
  endif()  
endforeach()
configure_file(${PROJECT_REAL_PATH}/crypto/opensslconf.h.in ${PROJECT_CUSTOM_INCLUDES}/openssl/opensslconf.h)

# Includes
include_directories("${PROJECT_CUSTOM_INCLUDES}")
include_directories("${PROJECT_CUSTOM_INCLUDES}/openssl")
set(PROJECT_INCLUDE_DIRS "${PROJECT_CUSTOM_INCLUDES}")

# Special libcrypto config
configure_file(${PROJECT_REAL_PATH}/crypto/ec/ec_lcl.h ${CMAKE_CURRENT_BINARY_DIR}/crypto/ec/ec_lcl.h)

# libcrypto
#set(LIB_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/crypto)
#file(GLOB_RECURSE PROJECT_SOURCES "${PROJECT_REAL_PATH}/crypto/*.c")
#filter_list("${PROJECT_SOURCES}" "aes_x86core.c" PROJECT_SOURCES)
#file(MAKE_DIRECTORY ${LIB_BUILD_DIR})
#foreach(ITEM ${PROJECT_SOURCES}) 
  #file(COPY ${ITEM} DESTINATION ${LIB_BUILD_DIR})
#endforeach()
#foreach(ITEM ${PROJECT_CUSTOM_INC_SET}) 
  #file(COPY ${ITEM} DESTINATION ${LIB_BUILD_DIR})
#endforeach()
#file(GLOB PROJECT_SOURCES "${LIB_BUILD_DIR}/*.c")
#add_library(${PROJECT_NAME}_libcrypto STATIC ${PROJECT_SOURCES})

# libssl
set(LIB_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/ssl)
set(PROJECT_SOURCES 
  s2_meth.c s2_srvr.c s2_clnt.c s2_lib.c s2_enc.c s2_pkt.c 
  s3_meth.c s3_srvr.c s3_clnt.c s3_lib.c s3_enc.c s3_pkt.c s3_both.c 
  s23_meth.c s23_srvr.c s23_clnt.c s23_lib.c s23_pkt.c 
  t1_meth.c t1_srvr.c t1_clnt.c t1_lib.c t1_enc.c 
  d1_meth.c d1_srvr.c d1_clnt.c d1_lib.c d1_pkt.c 
  d1_both.c d1_enc.c d1_srtp.c 
  ssl_lib.c ssl_err2.c ssl_cert.c ssl_sess.c 
  ssl_ciph.c ssl_stat.c ssl_rsa.c 
  ssl_asn1.c ssl_txt.c ssl_algs.c 
  bio_ssl.c ssl_err.c kssl.c tls_srp.c t1_reneg.c
)
file(MAKE_DIRECTORY ${LIB_BUILD_DIR})
foreach(ITEM ${PROJECT_SOURCES}) 
  file(COPY ${PROJECT_REAL_PATH}/ssl/${ITEM} DESTINATION ${LIB_BUILD_DIR})
endforeach()
foreach(ITEM ${PROJECT_CUSTOM_INC_SET}) 
  file(COPY ${ITEM} DESTINATION ${LIB_BUILD_DIR})
endforeach()
file(GLOB PROJECT_SOURCES "${LIB_BUILD_DIR}/*.c")
add_library(${PROJECT_NAME}_libssl STATIC ${PROJECT_SOURCES})

# Export libraries
#set(PROJECT_LIBRARIES ${PROJECT_NAME}_libssl ${PROJECT_NAME}_libcrypto)
set(PROJECT_LIBRARIES ${PROJECT_NAME}_libssl)

CONFIGURE_FILE(${PROJECT_NAME}Config.cmake.in "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
