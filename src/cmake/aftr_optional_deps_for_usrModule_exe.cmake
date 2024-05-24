include_guard()

macro( query_user_for_optional_deps_for_useModule_like_opencv_pcl_gtest_etc )

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "ENTERING Inside of Query for optional deps for usrModule..." )
MESSAGE( STATUS "" )
   #Let the user choose to use common module libraries like OpenCV, PCL, etc. These libraries are not part of the engine, so the user
   #opts in at the module level. In the future, if these libraries are migrated into the engine, then AftrConfig.h will have a defined
   #preprocessor directive that will CHECK_SYMBOL_EXISTS for the new library and the engine's script will include its headers and link
   #against it automatically.
   OPTION( AFTR_USE_GTEST  "Includes & links against Google Test. Enabled by default for your module's src/gtest unit tests." ON )
   OPTION( AFTR_USE_OPENCV "Includes & links against OpenCV. Requires Env var OpenCV_DIR to be set to CV build folder (ex C:/repos/libs/opencv-4.2.0/build/x64/vc16/lib)" OFF )
   OPTION( AFTR_USE_PCL    "Includes & links against Point Cloud Library (PCL). Requires Env var PCL_ROOT to point to PCL Folder in repos/libs/PCL* " OFF )

   MESSAGE( STATUS "Optional Library Query: AFTR_USE_GTEST is ${AFTR_USE_GTEST}...")
   MESSAGE( STATUS "Optional Library Query: AFTR_USE_OPENCV is ${AFTR_USE_OPENCV}...")
   MESSAGE( STATUS "Optional Library Query: AFTR_USE_PCL is ${AFTR_USE_PCL}...")

   #Here we search for other libraries that may be requested by this module.
   #For OpenCV to be found, create an environmental variable called OpenCV_DIR which points to  the root of the OpenCV build directory
   MESSAGE( STATUS "Now invoking include_and_link_optional_deps_for_usrModule_like_opencv_pcl_gtest_etc with target ${PROJECT_NAME}..." )
   include_and_link_optional_deps_for_usrModule_like_opencv_pcl_gtest_etc( "${PROJECT_NAME}")

   MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                   "LEAVING Query for optional deps for usrModule......" )
   MESSAGE( STATUS "" )
endmacro()




macro( include_and_link_optional_deps_for_usrModule_like_opencv_pcl_gtest_etc arg_target )

   MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                  "ENTERING Inside of aftr_optional_deps_for_usrModule_exe::include_and_link_optional_deps_for_usrModule_like_opencv_pcl_gtest_etc.cmake..." )

   MESSAGE( STATUS "arg_target is ${arg_target}" )
   MESSAGE( STATUS "Checking to see if gtest needs to include/link against optional libs like OpenCV -- AFTR_USE_OPENCV is ${AFTR_USE_OPENCV}" )

   if( AFTR_USE_OPENCV )
      MESSAGE( STATUS "User selected OpenCV, searching for OpenCV Library...")
      find_package(OpenCV REQUIRED)
      set_target_properties(${OpenCV_LIBS} PROPERTIES MAP_IMPORTED_CONFIG_MINSIZEREL RELEASE ) #Map release to MinSizeRel
      if( UNIX ) #Linux installs OpenCV via CONDA and doesn't get debug libs to link against, so we use release
         set_target_properties(${OpenCV_LIBS} PROPERTIES MAP_IMPORTED_CONFIG_DEBUG RELEASE )
      elseif( WIN32 )
         set_target_properties(${OpenCV_LIBS} PROPERTIES MAP_IMPORTED_CONFIG_DEBUG DEBUG )
      endif()

      MESSAGE( STATUS "PROJ NAME IS ${arg_target}...")
      TARGET_LINK_LIBRARIES( ${arg_target} PRIVATE
                  optimized "${OpenCV_LIBS}"
                     debug "${OpenCV_LIBS}"
                           )
                           
      MESSAGE( STATUS "*********" )
      MESSAGE( STATUS "OpenCV Information")
      MESSAGE( STATUS "OpenCV_LIBS            : ${OpenCV_LIBS}" )
      MESSAGE( STATUS "OpenCV_LINK_DIRECTORIES: ${OpenCV_LINK_DIRECTORIES}" )
      MESSAGE( STATUS "OpenCV_INCLUDE_DIRS    : ${OpenCV_INCLUDE_DIRS}" )
      MESSAGE( STATUS "OpenCV_VERSION         : ${OpenCV_VERSION}" )
      MESSAGE( STATUS "OpenCV_VERSION_STATUS  : ${OpenCV_VERSION_STATUS}" )
      MESSAGE( STATUS "OpenCV_SHARED          : ${OpenCV_SHARED}" )
      MESSAGE( STATUS "OpenCV_CONFIG_PATH     : ${OpenCV_CONFIG_PATH}" )
      MESSAGE( STATUS "OpenCV_INSTALL_PATH    : ${OpenCV_INSTALL_PATH}" )
      MESSAGE( STATUS "OpenCV_LIB_COMPONENTS  : ${OpenCV_LIB_COMPONENTS}" )
      MESSAGE( STATUS "OpenCV_MODULES_SUFFIX  : ${OpenCV_MODULES_SUFFIX}" )
      MESSAGE( STATUS "*********" )
   ELSE()
      MESSAGE( STATUS "NOT USING OPEN_CV" )
   ENDIF()

   IF( AFTR_USE_PCL )
      MESSAGE( STATUS "*********" )
      MESSAGE( STATUS "User selected PCL, trying to find PCL Library but ensuring its find is called only once... Before finding, {PCL_FOUND} is ${PCL_FOUND}" )
      #if( NOT "${PCL_FOUND}" ) #SLN -- PCL breaks itself if found more than once. This is also why THIS MACRO must be a macro and not a function
         find_package(PCL 1.12.1 REQUIRED )# COMPONENTS common flann)
      #endif()
      MESSAGE( STATUS "PCL_FOUND              : ${PCL_FOUND}" )
      MESSAGE( STATUS "PCL_INCLUDE_DIRS       : ${PCL_INCLUDE_DIRS}" )
      MESSAGE( STATUS "PCL_LIBRARIES          : ${PCL_LIBRARIES}" )
      MESSAGE( STATUS "PCL_LIBRARY_DIRS       : ${PCL_LIBRARY_DIRS}" )
      MESSAGE( STATUS "PCL_DEFINITIONS        : ${PCL_DEFINITIONS}" )
      MESSAGE( STATUS "PCL_VERSION            : ${PCL_VERSION}" )
      MESSAGE( STATUS "PCL_COMPONENTS         : ${PCL_COMPONENTS}" )
      MESSAGE( STATUS "*********" )
      include_directories( ${PCL_INCLUDE_DIRS} )
      add_definitions( ${PCL_DEFINITIONS} )
      link_directories( ${PCL_LIBRARY_DIRS} PRIVATE )
      target_link_libraries( ${arg_target} PRIVATE ${PCL_LIBRARIES} )
   ENDIF()

   MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                   "LEAVING aftr_optional_deps_for_usrModule_exe::include_and_link_optional_deps_for_usrModule_like_opencv_pcl_gtest_etc.cmake..." )

endmacro( include_and_link_optional_deps_for_usrModule_like_opencv_pcl_gtest_etc target )