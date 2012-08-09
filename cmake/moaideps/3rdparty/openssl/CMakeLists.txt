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
set(PROJECT_SRC_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_SRC_PATH ${PROJECT_SRC_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_SRC_PATH}")
endif()
set(CMAKE_C_FLAGS "-std=gnu99")

# Build copy of openssl
set(PROJECT_REAL_PATH "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_KEY}")
if(NOT EXISTS ${PROJECT_REAL_PATH})

  # Copy to build dir; openssl is super special and needs its own
  # active build dir to work in. Just copy the whole lot.
  file(COPY ${PROJECT_SRC_PATH} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

  # Set of all symbolic links to headers
  file(GLOB_RECURSE PROJECT_SYMB_HEADERS "${PROJECT_REAL_PATH}/include/*.h")

  # Set of all actual headers (real files)
  set(PROJECT_REAL_HEADERS "")
  file(GLOB TMP "${PROJECT_SRC_PATH}/*.h")
  list(APPEND PROJECT_REAL_HEADERS ${TMP})
  file(GLOB_RECURSE TMP "${PROJECT_SRC_PATH}/ssl/*.h")
  list(APPEND PROJECT_REAL_HEADERS ${TMP})
  file(GLOB_RECURSE TMP_C "${PROJECT_SRC_PATH}/crypto/*.h")
  list(APPEND PROJECT_REAL_HEADERS ${TMP_C})

  # Rebuild all of the include files using actual values.
  foreach(SYMB ${PROJECT_SYMB_HEADERS})
    get_filename_component(SYMB_NAME ${SYMB} NAME)
    foreach(REAL ${PROJECT_REAL_HEADERS})
      get_filename_component(REAL_NAME ${REAL} NAME)
      if("${REAL_NAME}" STREQUAL "${SYMB_NAME}")
        configure_file(${REAL} ${SYMB} COPY_ONLY)
        break()
      endif()
    endforeach()
  endforeach()
  configure_file(${PROJECT_REAL_PATH}/crypto/opensslconf.h.in ${PROJECT_REAL_PATH}/include/openssl/opensslconf.h)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/buildinf.h.in ${PROJECT_REAL_PATH}/crypto/buildinf.h)
  list(APPEND TMP_C ${PROJECT_REAL_PATH}/include/openssl/opensslconf.h ${PROJECT_REAL_PATH}/crypto/buildinf.h)

  # Special includes for submodules
  # (Why? Why do these submodule use #include ""?)
  message("Updating headers for openssl. This might take a while...")
  file(GLOB TMP ${PROJECT_REAL_PATH}/crypto/*)
  foreach(TMP_PATH ${TMP})
    if(IS_DIRECTORY ${TMP_PATH})
      foreach(TMP_HI ${TMP_C})
        get_filename_component(TMP_HI_NAME ${TMP_HI} NAME)
        configure_file(${TMP_HI} ${TMP_PATH}/${TMP_HI_NAME} COPY_ONLY)
      endforeach()
    endif()
  endforeach()
endif()

# Config
add_definitions(-DOPENSSL_NO_KRB5)
add_definitions(-DOPENSSL_NO_SCTP)
add_definitions(-DOPENSSL_NO_DEPRECATED)
add_definitions(-DOPENSSL_NO_GMP)
add_definitions(-DOPENSSL_NO_JPAKE)
add_definitions(-DOPENSSL_NO_MD2)
add_definitions(-DOPENSSL_NO_ASM)
add_definitions(-DOPENSSL_NO_RC5)
add_definitions(-DOPENSSL_NO_RFC3779)
add_definitions(-DOPENSSL_NO_STORE)
add_definitions(-DOPENSSL_NO_DYNAMIC_ENGINE)
add_definitions(-DOPENSSL_NO_EC_NISTP_64_GCC_128)

# Includes
include_directories("${PROJECT_REAL_PATH}")
include_directories("${PROJECT_REAL_PATH}/include")
include_directories("${PROJECT_REAL_PATH}/crypto")
include_directories("${PROJECT_REAL_PATH}/ssl")
include_directories("${PROJECT_REAL_PATH}/include/openssl")

# libengine
set(LIB_EX 
)
file(GLOB_RECURSE PROJECT_SOURCES "${PROJECT_REAL_PATH}/engines/*.c")
filter_list("${PROJECT_SOURCES}" "${LIB_EX}" PROJECT_SOURCES)
#filter_list_ex("${PROJECT_SOURCES}" "pkcs7/.*" PROJECT_SOURCES)
add_library(${PROJECT_NAME}_libengine STATIC ${PROJECT_SOURCES})

# libcrypto
set(LIB_EX 
  aes_x86core.c armcap.c bf_opts.c bio_ber.c
  bss_rtcp.c cast_spd.c castopts.c des_opts.c
  v3conf.c LPdir_unix.c LPdir_vms.c read_pwd.c
  x86_64-gcc.c rc5_ecb.c rc5ofb64.c LPdir_win32.c
  e_dsa.c ecp_nistp224.c ecp_nistp256.c
  LPdir_nyi.c bf_cbc.c 

  # Tests
  exp.c bfspeed.c bnspeed.c cnf_save.c rc4.c dsagen.c 
  rc4speed.c pk7_enc.c v3prin.c rpw.c speed.c rc2speed.c
  idea_spd.c 
)
if(WIN32)
  list(APPEND LIB_EX 
    LPdir_wince.c LPdir_win.c ppccap.c s390xcap.c sparcv9cap.c
    th-lock.c
  )
else()
  list(APPEND LIB_EX 
    LPdir_wince.c LPdir_win.c
  )
endif()
file(GLOB_RECURSE PROJECT_SOURCES "${PROJECT_REAL_PATH}/crypto/*.c")
filter_list("${PROJECT_SOURCES}" "${LIB_EX}" PROJECT_SOURCES)
filter_list_ex("${PROJECT_SOURCES}" "test.c" PROJECT_SOURCES)
filter_list_ex("${PROJECT_SOURCES}" "rc5/.*" PROJECT_SOURCES)
filter_list_ex("${PROJECT_SOURCES}" "jpake/.*" PROJECT_SOURCES)
filter_list_ex("${PROJECT_SOURCES}" "md2/.*" PROJECT_SOURCES)
filter_list_ex("${PROJECT_SOURCES}" "store/.*" PROJECT_SOURCES)
add_library(${PROJECT_NAME}_libcrypto STATIC ${PROJECT_SOURCES})
target_link_libraries(${PROJECT_NAME}_libcrypto ${PROJECT_NAME}_libengine)

# libssl
set(LIB_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/build/src/all/ssl)
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
target_link_libraries(${PROJECT_NAME}_libssl ${PROJECT_NAME}_libcrypto ${PROJECT_NAME}_libengine)

# Export libraries
set(PROJECT_LIBRARIES ${PROJECT_NAME}_libssl ${PROJECT_NAME}_libcrypto)
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include")

# Win32 requires winsock
if(WIN32) 
  set(PROJECT_LIBRARIES ${PROJECT_LIBRARIES} ws2_32)
endif()

CONFIGURE_FILE(${PROJECT_NAME}Config.cmake.in "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
