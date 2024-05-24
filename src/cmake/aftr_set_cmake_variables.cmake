include_guard()
include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_cmake_utils.cmake" ) #so we can call MakeAbsolute

#Sets these helpful variables used by other CMake functions when searching for includes, libraries, and other build
#related files:
###   CMAKE_LIBRARY_PATH
###   AFTR_USERLAND_ROOT_DIR
###   AFTR_ENGINE_ROOT_DIR
###   AFTR_ENGINE_SRC_DIR
###   CMAKE_MODULE_PATH
###   AFTR_USR_INCLUDE_DIR
###   AFTR_3RD_PARTY_INCLUDE_ROOT
###   AFTR_USERLAND_LIB_PATH
###   CMAKE_INSTALL_PREFIX #User can overwrite via cmake gui or command argument -DCMAKE_INSTALL_PREFIX=../path
MACRO( set_cmake_variables )

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                "Inside of function -- set_cmake_variables()..." )
   #Set common variables. Each variable is set relative to user land or the engine src based on if Cmake is run from a
   #Module or an engine build directory, respectively.

   #CMAKE TRUE/FALSE NOTE:  (https://cmake.org/cmake/help/v3.0/command/if.html)
   #          False is the constant is 0, OFF, NO, FALSE, N, IGNORE, NOTFOUND, the empty string, or ends in the suffix -NOTFOUND.
   #          True is the constant is 1, ON, YES, TRUE, Y, or a non-zero number.
   #Determine if this project is a 32 bit or 64 bit project. (on *NIX -m32 indicates 32 and -m64 indicates 64).
   MESSAGE( STATUS "CMAKE_SIZEOF_VOID_P is ${CMAKE_SIZEOF_VOID_P}" )
   IF( ${CMAKE_SIZEOF_VOID_P} EQUAL 8 )
      SET( AFTR_NBITS "64" )
      MESSAGE( STATUS "CMAKE_SIZEOF_VOID_P EQUAL 8" )
      MESSAGE( STATUS "Project is set to Build a 64-bit binary and requires Linking against 64-bit libs." )
   elseif( ${CMAKE_SIZEOF_VOID_P} EQUAL 4) 
      SET( AFTR_NBITS "32" )
      MESSAGE( STATUS "CMAKE_SIZEOF_VOID_P EQUAL 4" )
      MESSAGE( STATUS "Project is set to Build a 32-bit binary and requires Linking against 32-bit libs." )
   else()
      MESSAGE( FATAL_ERROR "CMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}... This script expected to detect either 4 or 8 (32 bit or 64 bit)." )
   endif()
   MESSAGE( STATUS "AFTR_NBITS is ${AFTR_NBITS}" )

   IF( AFTR_NBITS EQUAL "64" )
      set_property( GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS ON )
   ELSE()
      set_property( GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS OFF )
   ENDIF()



   IF( aftrFlagThatIndicatesCMakeListsIsBeingExecutingInsideTheEngineDirectorySoPathsShouldReflectEngineBuildAsRootOfCmake )
      SET( AFTR_USERLAND_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../../usr" )
      SET( AFTR_EXTERNAL_PROJECTS_ROOT "${CMAKE_SOURCE_DIR}/../external/" )
      SET( CMAKE_LIBRARY_PATH     "${CMAKE_SOURCE_DIR}/../../lib${AFTR_NBITS}" )
   ELSE()
      SET( AFTR_USERLAND_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../.." )
      SET( AFTR_EXTERNAL_PROJECTS_ROOT "${AFTR_USERLAND_ROOT_DIR}/include/external/" )
      SET( CMAKE_LIBRARY_PATH     "${CMAKE_SOURCE_DIR}/../../../lib${AFTR_NBITS}" )
   ENDIF()
   SET( AFTR_ENGINE_SRC_DIR         "${CMAKE_SOURCE_DIR}" )
   SET( AFTR_ENGINE_ROOT_DIR        "${CMAKE_SOURCE_DIR}/../../" )
   LIST( APPEND CMAKE_MODULE_PATH   "${AFTR_ENGINE_ROOT_DIR}/src/cmake" )
   LIST( APPEND CMAKE_MODULE_PATH   "${AFTR_USERLAND_ROOT_DIR}/include/cmake" )
   
   SET( AFTR_USR_INCLUDE_DIR "${AFTR_USERLAND_ROOT_DIR}/include/aftr" )
   if( aftrFlagThatIndicatesCMakeListsIsBeingExecutingInsideTheEngineDirectorySoPathsShouldReflectEngineBuildAsRootOfCmake )
      SET( AFTR_3RD_PARTY_INCLUDE_ROOT "${AFTR_ENGINE_ROOT_DIR}/src/" )
   else()
      SET( AFTR_3RD_PARTY_INCLUDE_ROOT "${AFTR_USERLAND_ROOT_DIR}/include" )
   endif()
   SET( AFTR_USERLAND_LIB_PATH "${AFTR_USERLAND_ROOT_DIR}/lib${AFTR_NBITS}" )

   if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT ) #https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT.html#variable:CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT
      #Let's us set the default install prefix, but still let the user specify their own that will be used.
      MakeAbsolute( AFTR_USERLAND_ROOT_DIR )
      MESSAGE( STATUS "AFTR_USERLAND_ROOT_DIR is ${AFTR_USERLAND_ROOT_DIR}" )
      MESSAGE( STATUS "CMAKE_INSTALL_PREFIX   is ${CMAKE_INSTALL_PREFIX}" )
      SET( CMAKE_INSTALL_PREFIX "${AFTR_USERLAND_ROOT_DIR}" )
      MakeAbsolute( "${CMAKE_INSTALL_PREFIX}" )
      SET( CMAKE_INSTALL_PREFIX "${AFTR_USERLAND_ROOT_DIR}" CACHE PATH "Default Install Location is in User land so modules can automatically find, include, and link" FORCE )
   endif()

   MakeAbsolute( CMAKE_LIBRARY_PATH )
   MakeAbsolute( AFTR_USERLAND_ROOT_DIR )
   MakeAbsolute( AFTR_ENGINE_ROOT_DIR )
   MakeAbsolute( AFTR_ENGINE_SRC_DIR )
   MakeAbsolute( CMAKE_MODULE_PATH )
   MakeAbsolute( AFTR_USR_INCLUDE_DIR )
   MakeAbsolute( AFTR_3RD_PARTY_INCLUDE_ROOT )
   MakeAbsolute( AFTR_USERLAND_LIB_PATH )
   MakeAbsolute( AFTR_EXTERNAL_PROJECTS_ROOT )
   MakeAbsolute( CMAKE_INSTALL_PREFIX )

   MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                   "Leaving function -- set_cmake_variables()..." )
ENDMACRO()

####################################
function( print_aftr_cmake_vars )
   MESSAGE( STATUS "*********" )
   MESSAGE( STATUS "**********************" )
   MESSAGE( STATUS "*******************************" )
   MESSAGE( STATUS "*******************************" )
   MESSAGE( STATUS "PROJECT_NAME               : ${PROJECT_NAME}" )
   MESSAGE( STATUS "CMAKE_PROJECT_NAME         : ${CMAKE_PROJECT_NAME}" )
   MESSAGE( STATUS "CMAKE_INSTALL_PREFIX       : ${CMAKE_INSTALL_PREFIX}" )
   MESSAGE( STATUS "CMAKE_SOURCE_DIR           : ${CMAKE_SOURCE_DIR}")
   MESSAGE( STATUS "CMAKE_BINARY_DIR           : ${CMAKE_BINARY_DIR}" )
   MESSAGE( STATUS "CMAKE_CURRENT_BINARY_DIR   : ${CMAKE_CURRENT_BINARY_DIR}" )
   MESSAGE( STATUS "CMAKE_ROOT                 : ${CMAKE_ROOT}" )
   MESSAGE( STATUS "CMAKE_MODULE_PATH          : ${CMAKE_MODULE_PATH}" )
   MESSAGE( STATUS "CMAKE_BUILD_TYPE           : ${CMAKE_BUILD_TYPE}" )
   MESSAGE( STATUS "AFTR_USERLAND_ROOT_DIR     : ${AFTR_USERLAND_ROOT_DIR}" )
   MESSAGE( STATUS "AFTR_ENGINE_ROOT_DIR       : ${AFTR_ENGINE_ROOT_DIR}" )
   MESSAGE( STATUS "AFTR_ENGINE_SRC_DIR        : ${AFTR_ENGINE_SRC_DIR}" )
   MESSAGE( STATUS "AFTR_USR_INCLUDE_DIR       : ${AFTR_USR_INCLUDE_DIR}" )
   MESSAGE( STATUS "AFTR_PATH_TO_CMAKE_SCRIPTS : ${AFTR_PATH_TO_CMAKE_SCRIPTS}" )
   MESSAGE( STATUS "AFTR_EXTERNAL_PROJECTS_ROOT: ${AFTR_EXTERNAL_PROJECTS_ROOT}" )
   MESSAGE( STATUS "AFTR_USERLAND_LIB_PATH     : ${AFTR_USERLAND_LIB_PATH}" )
   MESSAGE( STATUS "ENV{AFTR_3RD_PARTY_ROOT}   : $ENV{AFTR_3RD_PARTY_ROOT}" )
   MESSAGE( STATUS "CMAKE_STATIC_LIBRARY_PREFIX: '${CMAKE_STATIC_LIBRARY_PREFIX}'" )
   MESSAGE( STATUS "CMAKE_STATIC_LIBRARY_SUFFIX: '${CMAKE_STATIC_LIBRARY_SUFFIX}'" )
   MESSAGE( STATUS "*******************************" )
   MESSAGE( STATUS "*******************************" )
   MESSAGE( STATUS "**********************" )
   MESSAGE( STATUS "*********" )
   MESSAGE( STATUS "" )
endfunction()
####################################