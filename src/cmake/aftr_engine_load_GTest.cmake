include_guard()

#New Module CMake Template written by Scott Nykl. This requires the engine is already built, compiled, and INSTALL'd to user land (.../repos/aburn/usr/).

#This simply includes the module-wide Google Test cmake script that all modules use
#to create a Test Project so Google Test can be used within a module.
#This CMake script is located in "..../usr/include/cmake/aftrModule_GTest_Proj.cmake"

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "ENTERING Inside of Google Test Setup for Engine..."          )
MESSAGE( STATUS "" )


#Compiler settings must be set *before* the add_library / add_execuatable call.
include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_set_compiler_settings.cmake" )
set_compiler_settings( GTest )

set( test_sources "" )
FILE( GLOB test_sources "./*.cpp" )

#Google Test cannot have a main.cpp or the entry point gets hijacked,
#so we must remove main.cpp from the list of sources to consider for GTest*
message( STATUS "Engine GTEST source files are: ${test_sources}" )

add_executable( GTest "" ) #Source files added in target_sources command
target_sources( GTest PRIVATE ${test_sources} )
MESSAGE( STATUS "GTest.exe depends on already INSTALL'd AftrBurnerEngine to link against AftrBurnerEngine::AftrBurnerEngine")
add_dependencies( GTest ${PROJECT_NAME} ) #GTest_lib must be built before GTest
target_link_libraries( GTest PRIVATE AftrBurnerEngine::AftrBurnerEngine )


#Need to call a function to include and link all AftrBurnerEngine dependencies
include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_include_and_link_deps_for_usrModule_exe.cmake" )

set( old_path "${AFTR_PATH_TO_CMAKE_SCRIPTS}" )
set( AFTR_PATH_TO_CMAKE_SCRIPTS "${AFTR_USERLAND_ROOT_DIR}/include/cmake" )
include_and_link_aburn_deps( GTest )

if( AFTR_USE_GTEST OR AFTR_CONFIG_USE_GTEST_LIB )
   target_link_libraries( GTest PRIVATE GTest::GTest GTest::Main ) #only link in the exact project that *is* the gtest exe, otherwise your entry point is hijacked
endif()

set( AFTR_PATH_TO_CMAKE_SCRIPTS "${old_path}" )
MESSAGE( STATUS "After Engine GTest config, AFTR_PATH_TO_CMAKE_SCRIPTS is ${AFTR_PATH_TO_CMAKE_SCRIPTS}")


add_test( 
   NAME GTest
   COMMAND $<TARGET_FILE:GTest>
   )

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "LEAVING Google Test Project Setup for Engine..." )                 
MESSAGE( STATUS "" )
