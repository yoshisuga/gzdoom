# Install script for directory: /Users/yoshi/Code/personal/gzdoom

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/objdump")
endif()

set(CMAKE_BINARY_DIR "/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan")

if(NOT PLATFORM_NAME)
  if(NOT "$ENV{PLATFORM_NAME}" STREQUAL "")
    set(PLATFORM_NAME "$ENV{PLATFORM_NAME}")
  endif()
  if(NOT PLATFORM_NAME)
    set(PLATFORM_NAME iphoneos)
  endif()
endif()

if(NOT EFFECTIVE_PLATFORM_NAME)
  if(NOT "$ENV{EFFECTIVE_PLATFORM_NAME}" STREQUAL "")
    set(EFFECTIVE_PLATFORM_NAME "$ENV{EFFECTIVE_PLATFORM_NAME}")
  endif()
  if(NOT EFFECTIVE_PLATFORM_NAME)
    set(EFFECTIVE_PLATFORM_NAME -iphoneos)
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xDocumentationx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/doc/gzdoom" TYPE DIRECTORY FILES "/Users/yoshi/Code/personal/gzdoom/docs/")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/libraries/glslang/glslang/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/libraries/glslang/spirv/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/libraries/glslang/OGLCompilersDLL/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/libraries/zlib/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/libraries/jpeg/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/libraries/bzip2/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/libraries/lzma/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/tools/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/libraries/gdtoa/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/wadsrc/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/wadsrc_bm/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/wadsrc_lights/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/wadsrc_extra/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/wadsrc_widescreen/cmake_install.cmake")
  include("/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/src/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/Users/yoshi/Code/personal/gzdoom/build-ios.vulkan/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
