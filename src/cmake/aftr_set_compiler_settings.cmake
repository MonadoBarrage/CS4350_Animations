include_guard()


##########
#Specify CMake Policies to avoid red warnings in the configurations as cmake's behavior changes with new versions
if( POLICY CMP0074 ) #SLN Added 14 Oct 2018
#In CMake 3.12 and above the ``find_package(<PackageName>)`` command now searches prefixes specified by the ``<PackageName>_ROOT`` CMake variable and the ``<PackageName>_ROOT`` environment variable.
   cmake_policy( SET CMP0074 NEW )
endif()
##########                 
                 
SET( CMAKE_VERBOSE_MAKEFILE ON )
SET( CMAKE_EXPORT_COMPILE_COMMANDS ON ) #This will produce a compile_commands.json (for Ninja and Make) that tools such as VS Code can use to populate its intellisense.

###########
function( set_compiler_settings arg_target )
MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "ENTERING Inside of aftr_set_compiler_settings::set_compiler_settings.cmake... Setting Up Variables..." )

#Now we define some global compiler flags that we would like to have specified to BOTH the engine and all modules.
#This is nice in that adding a compiler flag here affects ALL modules that include this file as well as the engine
#making this a convenient place to manage repo-wide build settings
#set_property( TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)

if( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR
    "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" )
   add_compile_options( -Wall -Wextra -Wno-overloaded-virtual -Wno-unused-parameter -Wno-unknown-pragmas -Wfatal-errors )
   add_compile_options( -fpermissive -std=c++20 -fconcepts -fdiagnostics-color=always )
   add_compile_definitions( AFTR_LINUX )
   #SET( warnings "${warnings} -Wall -Wextra -Wno-overloaded-virtual -Wno-unused-parameter -Wno-unknown-pragmas -Wfatal-errors" ) #not using -Werror
   #SET( cppFlags "${cppFlags} -fpermissive -std=c++20 -fconcepts" ) #GNU/Clang specific CPP compiler flags
   #SET( cppFlags "${cppFlags} -DBOOST_ASIO_DISABLE_CONCEPTS ") #See the COMMENT below about Boost 1.72 and asio concept errors... This flag will go away in a future boost version
elseif( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC" )
   #SET( CMAKE_CXX_FLAGS "" )
   add_compile_options( /we4703 /we4701 )  #Within the Engine, we treat warnings as compiler errors /WX. In a module, we let warnings just be warnings.
   if( "${aftrFlagThatIndicatesCMakeListsIsBeingExecutingInsideTheEngineDirectorySoPathsShouldReflectEngineBuildAsRootOfCmake}" STREQUAL "1" )
      #MESSAGE( WARNING "Compiler warnings will be treated as errors" )
      add_compile_options( /WX )  #Within the Engine, we treat warnings as compiler errors /WX. In a module, we let warnings just be warnings.
   endif()
   add_compile_options( /std:c++latest /MP /EHsc )
   add_compile_definitions( AFTR_MSVC WIN32 _WINDOWS _WIN32_WINNT=0x0601 _SILENCE_CXX17_ITERATOR_BASE_CLASS_DEPRECATION_WARNING _SILENCE_CXX23_ALIGNED_STORAGE_DEPRECATION_WARNING )
   #SET( warnings "${warnings} /DWIN32 /D_WINDOWS" )   
   #SET( warnings "${warnings} /D_WIN32_WINNT=0x0601" ) #disable warning: Informs compiler that Windows 7 is explicitly the minimum required
   #SET( warnings "${warnings} /D_SILENCE_CXX17_ITERATOR_BASE_CLASS_DEPRECATION_WARNING" ) #Disable MSVC complaints about C++17 allocator warnings. Added with Boost 1.75
   #SET( warnings "${warnings} /we4703 /we4701" ) #treat potentially uninitialized local variable or pointer as an error
   #SET( cppFlags "${cppFlags} /GR /EHsc" )
   #SET( cppFlags "${cppFlags} /MP" ) #MSVC Specific CPP compiler flags, MP=Multi Processor compilations
   #SET( cppFlags "${cppFlags} /std:c++latest" ) #MSVC Specific CPP compiler flags, MP=Multi Processor compilations
   #ADD_DEFINITIONS( -DAFTR_MSVC )
endif()


MESSAGE( STATUS "Using Compiler ${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}.")

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ]" )
#                 "   set warnings to: ${warnings}\n"
#                 "   set cppFlags to: ${cppFlags}\n" )
MESSAGE( STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}" )
MESSAGE( STATUS "CMAKE_C_FLAGS  : ${CMAKE_C_FLAGS}" )

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "LEAVING aftr_set_compiler_settings::set_compiler_settings.cmake..." )

endfunction()
###########