include_guard()


MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "ENTERING Inside of aftrModuleCMakeHelper.cmake... Setting Up Variables..." )

if( NOT AFTR_PATH_TO_CMAKE_SCRIPTS )
   MESSAGE( STATUS "Assuming building a Module and setting AFTR_PATH_TO_CMAKE_SCRIPTS to ${CMAKE_SOURCE_DIR}/../../../include/cmake" )
   # cmake_path( SET AFTR_PATH_TO_CMAKE_SCRIPTS NORMALIZE "${CMAKE_SOURCE_DIR}/../../../include/cmake" ) #User-land modules will set to this path!
   cmake_path( SET AFTR_PATH_TO_CMAKE_SCRIPTS NORMALIZE "${CMAKE_SOURCE_DIR}/cmake" )
endif()

#Set common variables. Each variable is set relative to user land or the engine src based on if Cmake is run from a
#Module or an engine build directory, respectively.
MESSAGE( STATUS "CMAKE_SOURCE_DIR is ${CMAKE_SOURCE_DIR}")
MESSAGE( STATUS "AFTR_PATH_TO_CMAKE_SCRIPTS is ${AFTR_PATH_TO_CMAKE_SCRIPTS}" )


include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_set_cmake_variables.cmake" ) #Use AFTR_PATH_TO_CMAKE_SCRIPTS to support the same cmake file being included from either the engine or a module - neato, huh?
set_cmake_variables()

include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_set_compiler_settings.cmake" )
set_compiler_settings( ${PROJECT_NAME} )



MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "LEAVING aftrModuleCMakeHelper.cmake..." )
