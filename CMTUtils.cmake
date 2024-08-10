# Top level CMake helper file that provides a single include option.

# Top level project command that passes standard arguements to config, and does
# basic setup.

# Require fairly updated cmake, easiest way to get is via:
# pip install cmake
cmake_minimum_required(VERSION 3.24)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/InternalHelpers.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/ExternalBuild.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/BuildTypes.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/CoverageHelper.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/VersionHelper.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/DoxygenHelper.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/ResourceDownloader.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/PackagingHelper.cmake)
#
# Configure a project with CMAKE tools.
#
# * Overridable from commandline:
# * Sets up standard platform specific install directories.
# * Uses a staging directory to compile artifacts to before installing.
# * adds a doc directory under doc for staged and install artifacts.
# * If this is the top level project:
# * Adds additional build types (see BuildTypes.cmake).
# * Sets up test coverage generation if we are building in coverage mode.
# * Turns on Color Terminal output.
# * exports a compile command database by default
# * Adds flags for different builds:
# * BUILD_TESTS
# * BUILD_DOCS
# * BUILD_EXAMPLES
#
# Input args:
# None
#
macro(cmt_project_setup)
  message(DEBUG "Configuring project ${CMT_PROJECT_UNPARSED_ARGUMENTS}")

  # see profesional CMake 15th edition, page 578:
  # https://crascit.com/professional-cmake/
  set(stageDir ${CMAKE_BINARY_DIR}/stage)
  include(GNUInstallDirs)

  if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_BINDIR})
  endif()

  if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_LIBDIR})
  endif()

  if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_LIBDIR})
  endif()

  # Explicitly set DOCDIR location each time, see profesional CMake 15th
  # edition, page 411:
  set(CMAKE_INSTALL_DOCDIR ${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME})

  if("${PROJECT_NAME}" STREQUAL "${CMAKE_PROJECT_NAME}")
    # cross compilation only looks for libraries from within the toolchain directory.
    # Also look in the install prefix:
    list(APPEND CMAKE_FIND_ROOT_PATH ${CMAKE_INSTALL_PREFIX})

    set(CMAKE_COLOR_DIAGNOSTICS
      ON
      CACHE BOOL "Use color in compiler diagnostics")

    cmt_configure_build_types()
    cmt_build_coverage_setup()

    # set option to build documentation.
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

    option(BUILD_DOCUMENTATION "Build documentation" ON)
    option(BUILD_TESTS "Build tests" ON)

    if(${BUILD_TESTS})
      enable_testing()
    endif()

    option(BUILD_EXAMPLES "Build examples" ON)



  endif()
endmacro()

#
# Subdirectory commands: uses standardized CMT build flags
#

# Add a source directory
#
# This is redundant, but the other modes exist...
# Input args:
# Positional: Directory relative to call site, use like add_subdirectory
function(cmt_add_src_subdirectory directory)
  _cmt_directory_exists(${directory})
  add_subdirectory(${directory})
endfunction()

# Add a doc directory
#
# This is protected by BUILD_DOCUMENTATION
# Input args:
# Positional: Directory relative to call site, use like add_subdirectory
function(cmt_add_doc_subdirectory directory)
  _cmt_directory_exists(${directory})

  if(BUILD_DOCUMENTATION)
    add_subdirectory(${directory})
  endif()
endfunction()

# Add a test directory
#
# This is protected by BUILD_TESTS
# Input args:
# Positional: Directory relative to call site, use like add_subdirectory
function(cmt_add_test_subdirectory directory)
  _cmt_directory_exists(${directory})

  if(BUILD_TESTS)
    add_subdirectory(${directory})
  endif()
endfunction()

# Add a examples directory
#
# This is protected by BUILD_EXAMPLES
# Input args:
# Positional: Directory relative to call site, use like add_subdirectory
function(cmt_add_examples_subdirectory directory)
  _cmt_directory_exists(${directory})

  if(BUILD_EXAMPLES)
    add_subdirectory(${directory})
  endif()
endfunction()

# Configures a target and adds properties so later CMT functions can parse them
# in a standard manner, used internally by cmt_add_library and cmt_add_executable.
#
# Specifically it gives every CMake target a namespace and export name
# parameter. These are concepts normally used by consumers of cmake projects:
#
# target_link_libraries(mytarget PRIVATE OtherCMakeProject::LibInProject)
#
# When "OtherCMakeProject" creates its cmake install artifacts it creates import
# targets that have namespace "OtherCMakeProject" and ExportName "LibInProject"
#
# CMakeTools makes a effort to standardize this. First by creating aliases to
# namespace::exportname, which allows consumers to call your project as a
# subdirectory using the same syntax they would use if they were pulling in a
# third party project. (this is done in cmt_add_<library,executable>)
# 
# It also attaches these names to the target themselves so 
# that later stages (install and packaging) can reference the same names.
#
# This also turns on all warnings (but not warnings as errors), because why are 
# you building without all the warnings? 
#
# Input args:
#   Positional:
#     (Required) : target name
#   Single Value:
#     (Required) NAMESPACE YourNameSpace -- see above
#     (Required) EXPORT_NAME YourExportName -- see above
#   Flags:
#     NO_COVERAGE   -- disable coverage on this target (ie a test exe)
#                      This only has an affect if doing a coverage build type.
#     NO_SOVERSION  -- Disable creation of .so version. ie libDSP.so.2.1.0 will 
#                      just be libDSP.so (normally there is a symlink chain) 
#   
function(cmt_target_setup target_name)
  cmake_parse_arguments("CMTFCN" "NO_SOVERSION;NO_COVERAGE"
    "NAMESPACE;EXPORT_NAME" "" "${ARGN}")

  if(NOT DEFINED CMTFCN_NAMESPACE)
    message(FATAL_ERROR "cmt_target_setup requires a namespace")
  endif()

  if(NOT DEFINED CMTFCN_EXPORT_NAME)
    message(FATAL_ERROR "cmt_target_setup requires an export name")
  endif()

  message(DEBUG "Creating target ${target_name} with SO versioning")

  set_target_properties(
    ${target_name}
    PROPERTIES CMT_EXPORT_NAME ${CMTFCN_EXPORT_NAME}
    CMT_NAMESPACE ${CMTFCN_NAMESPACE}
    CMT_STANDARD_NAME "${CMTFCN_NAMESPACE}_${CMTFCN_EXPORT_NAME}")

  cmt_target_set_version(${target_name})

  if(NOT PROJECT_VERSION)
    message(FATAL_ERROR "Project ${PROJECT_NAME} has no version. CMakeTools Requires all projects to have a version specified.")
  endif()

  if(NOT ${CMTFCN_NO_SOVERSION})
    message(DEBUG "Setting up target ${target_name} with SO versioning: Enabled")
    set_target_properties(${target_name} PROPERTIES 
                          VERSION ${PROJECT_VERSION}
                          SOVERSION ${PROJECT_VERSION_MAJOR})
    else()
      message(DEBUG "Setting up target ${target_name} with SO versioning: Disabled")
  endif()

  # enable verbose warnings on targets
  target_compile_options(
    ${target_name}
    PRIVATE $<$<CXX_COMPILER_ID:GNU>:-Wall
    -Wextra
    -Wpedantic>
    $<$<CXX_COMPILER_ID:Clang>:-Wall
    -Wextra
    -Wpedantic>
    $<$<CXX_COMPILER_ID:MSVC>:/W4>)

  if(NOT ${CMTFCN_NO_COVERAGE})
    # only add the coverage options on Coverage build type:
    message(DEBUG "Setting up target ${target_name} with coverage Enabled")
    target_compile_options(
      ${target_name}
      PRIVATE $<$<CONFIG:Coverage>: $<$<CXX_COMPILER_ID:GNU>:--coverage>
      $<$<CXX_COMPILER_ID:Clang>:--coverage>
      $<$<CXX_COMPILER_ID:MSVC>:/PROFILE> >)

    target_link_options(
      ${target_name}
      PRIVATE
      $<$<CONFIG:Coverage>:
      $<$<CXX_COMPILER_ID:GNU>:--coverage>
      $<$<CXX_COMPILER_ID:Clang>:--coverage>
      $<$<CXX_COMPILER_ID:MSVC>:/PROFILE>
      >)
  else()
    message(DEBUG "Setting up target ${target_name} with coverage Disabled")
  endif()
endfunction()


# CMakeTools version of add_library, with a few arguments and defaults added.
#
# Specifically:
#   * it uses the PROJECT_NAME as the namespace. (see cmt_target_setup)
#   * by default it turns off symbol visability 
#     (This hides symbols in your library unless you specifically export them.)
#   * it generates a visability file for the library.
#
# Gotchas: 
#   * Missing symbol errors b/c symbol not explictly exported, 
#     try VISIBLE_SYMBOLS to see if this is the issue.
#   * NAMESPACED - Causes behavior to differ from add_library, specifically the 
#     target name will not be ${target} but is instead ${PROJECTNAME}{target}. 
#     This should only really be used in unit tests, and solves the colliding 
#     executable problem where you have a toplevel cmake project build a bunch 
#     of lower level projects, and each of them has a target named unittest.
#     It returns CMT_LAST_TARGET so you can then reference that.
#   
#
# Input args:
#   Positional:
#     (Required) : target name
#   Single Value:
#     (Optional) EXPORT_NAME YourExportName -- By default is the target name.
#   Flags:
#     NAMESPACED      -- This is a bit funky, see gotchas.
#     VISABLE_SYMBOLS -- makes symbols visable by default (for debugging).
#     NO_COVERAGE     -- Disables coverage (see cmt_target_setup).
# Returns:
#   CMT_LAST_TARGET - Can be used to reference the last target mad by 
#                     cmt_add_<library,executable>.
# 
function(cmt_add_library target_name)
  cmake_parse_arguments("CMTFCN" "NAMESPACED;VISIBLE_SYMBOLS;NO_COVERAGE"
    "EXPORT_NAME" "" "${ARGN}")

  set(CMT_NAMESPACE ${PROJECT_NAME})

  if(DEFINED CMTFCN_EXPORT_NAME)
    set(CMT_TARGET_EXPORT_NAME ${CMTFCN_EXPORT_NAME})
  else()
    set(CMT_TARGET_EXPORT_NAME ${target_name})
  endif()

  if(NOT "${CMT_NAMESPACE}" STREQUAL "${target_name}")
    set(CMT_DEDUPED_NAMESPACED_NAME "${CMT_NAMESPACE}${target_name}")
  else()
    set(CMT_DEDUPED_NAMESPACED_NAME "${target_name}")
  endif()

  if(${CMTFCN_NAMESPACED})
    set(CMT_TARGET_NAME "${CMT_DEDUPED_NAMESPACED_NAME}")
    message(DEBUG "Creating namespaced library: ${CMT_TARGET_NAME}")
  else()
    set(CMT_TARGET_NAME "${target_name}")
    message(DEBUG "Creating non-namespaced library: ${CMT_TARGET_NAME}")
  endif()

  message(DEBUG "Using export name: ${CMT_TARGET_EXPORT_NAME}")
  message(DEBUG "Using namespace: ${CMT_NAMESPACE}")
  message(
    DEBUG
    "Adding library '${CMT_TARGET_NAME}' with args ${CMTFCN_UNPARSED_ARGUMENTS}"
  )
  add_library(${CMT_TARGET_NAME} ${CMTFCN_UNPARSED_ARGUMENTS})
  add_library(${CMT_NAMESPACE}::${CMT_TARGET_EXPORT_NAME} ALIAS
    ${CMT_TARGET_NAME})

  # check if target is not a header only library:
  get_target_property(CMT_TARGET_TYPE ${CMT_TARGET_NAME} TYPE)

  if(NOT ${CMT_TARGET_TYPE} STREQUAL "INTERFACE_LIBRARY")
    include(GenerateExportHeader)

    if(NOT CMTFCN_VISIBLE_SYMBOLS)
      set_target_properties(
        ${CMT_TARGET_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN 1)
    endif()

    # do we really want a export file per library? or would a shared export 
    # file for the project be better? maybe a single export file per shared 
    # export set?
    generate_export_header(
      ${CMT_TARGET_NAME}
      EXPORT_FILE_NAME
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${CMT_NAMESPACE}/${CMT_TARGET_NAME}_export.h
      EXPORT_MACRO_NAME
      ${CMT_DEDUPED_NAMESPACED_NAME}_EXPORT)

    set_target_properties(
      ${CMT_TARGET_NAME}
      PROPERTIES CMT_VISIBILITY_GENERATED True
      CMT_VISIBILITY_EXPORT_MACRO
      "${CMT_DEDUPED_NAMESPACED_NAME}_EXPORT"
      CMT_VISIBILITY_EXPORT_FILE "${CMT_TARGET_NAME}_export.h")

    target_sources(
      ${CMT_TARGET_NAME}
      PUBLIC
      FILE_SET
      cmt_public_headers
      TYPE
      HEADERS
      BASE_DIRS
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}
      FILES
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${CMT_NAMESPACE}/${CMT_TARGET_NAME}_export.h
    )
  else()
    set_target_properties(${CMT_TARGET_NAME} PROPERTIES CMT_VISIBILITY_GENERATED
      False)
  endif()

  cmt_target_setup(${CMT_TARGET_NAME} NAMESPACE ${CMT_NAMESPACE} EXPORT_NAME
    ${CMT_TARGET_EXPORT_NAME})
  set(CMT_LAST_TARGET
    ${CMT_TARGET_NAME}
    PARENT_SCOPE)
endfunction()

# CMakeTools version of add_executable, with a few arguments and defaults added.
#
# Specifically:
#   * it uses the PROJECT_NAME as the namespace. (see cmt_target_setup)
#   * by default it turns off symbol visability 
#     (This hides symbols in your library unless you specifically export them.)
#   * it generates a visability file for the library.
#
# Gotchas: 
#   * Missing symbol errors b/c symbol not explictly exported, 
#     try VISIBLE_SYMBOLS to see if this is the issue.
#   * NAMESPACED - Causes behavior to differ from add_library, specifically the 
#     target name will not be ${target} but is instead ${PROJECTNAME}{target}. 
#     This should only really be used in unit tests, and solves the colliding 
#     executable problem where you have a toplevel cmake project build a bunch 
#     of lower level projects, and each of them has a target named unittest.
#     It returns CMT_LAST_TARGET so you can then reference that.
#   
#
# Input args:
#   Positional:
#     (Required) : target name
#   Single Value:
#     (Optional) EXPORT_NAME YourExportName -- By default is the target name.
#   Flags:
#     NAMESPACED      -- This is a bit funky, see gotchas.
#     VISABLE_SYMBOLS -- makes symbols visable by default (for debugging).
#     NO_COVERAGE     -- Disables coverage (see cmt_target_setup).
# Returns:
#   CMT_LAST_TARGET - Can be used to reference the last target mad by 
#                     cmt_add_<library,executable>.
# 
function(cmt_add_executable target_name)
  cmake_parse_arguments("CMTFCN" "NAMESPACED;NO_COVERAGE" "EXPORT_NAME" ""
    "${ARGN}")

  set(CMT_NAMESPACE ${PROJECT_NAME})

  if(DEFINED CMTFCN_EXPORT_NAME)
    set(CMT_TARGET_EXPORT_NAME ${CMTFCN_EXPORT_NAME})
  else()
    set(CMT_TARGET_EXPORT_NAME ${target_name})
  endif()

  if(${CMTFCN_NAMESPACED})
    # check if target_name is equal to namespace, if so, don't add namespace
    # twice.
    if(NOT "${CMT_NAMESPACE}" STREQUAL "${target_name}")
      set(CMT_TARGET_NAME "${CMT_NAMESPACE}${target_name}")
    else()
      set(CMT_TARGET_NAME "${target_name}")
    endif()

    message(DEBUG "Creating namespaced executable: ${CMT_TARGET_NAME}")
  else()
    set(CMT_TARGET_NAME "${target_name}")
    message(DEBUG "Creating non-namespaced executable: ${CMT_TARGET_NAME}")
  endif()

  message(DEBUG "Using export name: ${CMT_TARGET_EXPORT_NAME}")
  message(DEBUG "Using namespace: ${CMT_NAMESPACE}")
  message(
    DEBUG
    "Adding executable '${CMT_TARGET_NAME}' with args ${CMTFCN_UNPARSED_ARGUMENTS}"
  )
  add_executable(${CMT_TARGET_NAME} ${CMTFCN_UNPARSED_ARGUMENTS})
  add_executable(${CMT_NAMESPACE}::${CMT_TARGET_EXPORT_NAME} ALIAS
    ${CMT_TARGET_NAME})

  set_target_properties(${CMT_TARGET_NAME} PROPERTIES CMT_VISIBILITY_GENERATED
    False)

  cmt_target_setup(${CMT_TARGET_NAME} NO_SOVERSION NAMESPACE ${CMT_NAMESPACE}
    EXPORT_NAME ${CMT_TARGET_EXPORT_NAME})

  set(CMT_LAST_TARGET
    ${CMT_TARGET_NAME}
    PARENT_SCOPE)
endfunction()

# Add headers to a target, similar in usage to the other Target_<commands>
# 
# Often you want to be able to access targets header files from dependent 
# projects (either within a single project or after install). This is often done 
# via Target_include_directories, but this does not really associate individual 
# files with a target, not rerunning build when headers change, and not 
# providing installation direction.
# 
# In cmake 3.24 and up there is a different option: FILE_SETS, and allow the 
# addition of non source files to a target. However these are very open ended, 
# CMakeTools wraps this command to associate public/private/interface headers
# To a library, which will automatically exported and installed to 
# ${prefix}/${CMAKE_INSTALL_INCLUDEDIR} (for Public/Interface)
#
# Input args:
#   Positional:
#     (Required) : target name
#     (Required) : Scope -> PRIVATE PUBLIC or INTERFACE
#   Multi Value:
#     (Required) BASE_DIRS : How much of the directory tree to install. If you 
#                            have a file located at: Root/A/B/C/file.h and your 
#                            BASEDIR is Root/A/B then your file (on std linux)
#                            will be installed to include/C/file.h
#                            (See filesets for more info)
#     (Required) FILES : list of header files to add.
function(cmt_target_headers target)
  cmake_parse_arguments("CMTFCN" "PUBLIC;INTERFACE;PRIVATE" ""
    "BASE_DIRS;FILES" "${ARGN}")

  # only one of PUBLIC, INTERFACE, or PRIVATE can be set:
  if((CMTFCN_PUBLIC AND CMTFCN_INTERFACE)
    OR(CMTFCN_PUBLIC AND CMTFCN_PRIVATE)
    OR(CMTFCN_INTERFACE AND CMTFCN_PRIVATE))
    message(FATAL_ERROR "Only one of PUBLIC, INTERFACE, or PRIVATE can be set")
  endif()

  if(NOT CMTFCN_PUBLIC
    AND NOT CMTFCN_INTERFACE
    AND NOT CMTFCN_PRIVATE)
    message(FATAL_ERROR "One of PUBLIC, INTERFACE, or PRIVATE must be set")
  else()
    if(CMTFCN_PUBLIC)
      set(CMT_TARGET_HEADERS_SCOPE PUBLIC)
      set(CMT_TARGET_HEADERS_NAME cmt_public_headers)
    elseif(CMTFCN_INTERFACE)
      set(CMT_TARGET_HEADERS_SCOPE INTERFACE)
      set(CMT_TARGET_HEADERS_NAME cmt_interface_headers)
    elseif(CMTFCN_PRIVATE)
      set(CMT_TARGET_HEADERS_SCOPE PRIVATE)
      set(CMT_TARGET_HEADERS_NAME cmt_private_headers)
    endif()
  endif()

  if(NOT CMTFCN_BASE_DIRS)
    # default basedir is the current dir:
    set(CMTFCN_BASE_DIRS "${CMAKE_CURRENT_LIST_DIR}")
    message(
      FATAL_ERROR
      "CMT_TARGET_HEADERS BASE_DIRS Required - No base dirs specified."
    )
  endif()

  if(NOT CMTFCN_FILES)
    message(FATAL_ERROR "No files specified for cmt_target_headers")
  endif()

  message(DEBUG "cmt_target_headers associating headers with target: ${target} using scope ${CMT_TARGET_HEADERS_SCOPE}")
  message(DEBUG "cmt_target_headers ${target} using base dirs: \n     ${CMTFCN_BASE_DIRS}")
  message(DEBUG "cmt_target_headers ${target} using files: \n     ${CMTFCN_FILES}")

  target_sources(
    ${target}
    ${CMT_TARGET_HEADERS_SCOPE}
    FILE_SET
    ${CMT_TARGET_HEADERS_NAME}
    TYPE
    HEADERS
    BASE_DIRS
    ${CMTFCN_BASE_DIRS}
    FILES
    ${CMTFCN_FILES})
endfunction()

# CMakeTools version of install target, this parses previous information 
# associated with the target from cmt_add_<library;ececutable> and 
# cmt_target_headers.
# 
# The target is installed wholely into a single ExportSet (goes into the same target files)
# 
# Note that the install COMPONENT is standardized to be:
# ${CMT_TARGET_STANDARD_NAME}_<COMPONENT_TYPE>, This is so that the packaging 
# step can parse the Components.
# 
# Input args:
#   Positional:
#     (Required) : targetname
#   Multi-Value:
#     (Optional) : SUBTARGETS - Other targets you want to get installed in the 
#                   same export set and component name. See notes above for info
#                   about what this is.
# 
function(cmt_install_target target_name)
  cmake_parse_arguments("CMTFCN" "" "" "SUBTARGETS" "${ARGN}")

  get_target_property(CMT_TARGET_EXPORT_NAME ${target_name} CMT_EXPORT_NAME)
  get_target_property(CMT_TARGET_NAMESPACE ${target_name} CMT_NAMESPACE)
  get_target_property(CMT_TARGET_STANDARD_NAME ${target_name} CMT_STANDARD_NAME)

  message(
    DEBUG
    "Installing target: ${target_name}\n"
    "      Export name: ${CMT_TARGET_EXPORT_NAME}\n"
    "      Namespace: ${CMT_TARGET_NAMESPACE}\n"
    "      Standard name: ${CMT_TARGET_STANDARD_NAME}")

  set_target_properties(
    ${target_name} PROPERTIES EXPORT_NAME ${CMT_TARGET_EXPORT_NAME}
    OUTPUT_NAME ${target_name})

  set(EXPORT_SET ${CMT_TARGET_NAMESPACE}${CMT_TARGET_EXPORT_NAME}Targets)

  # the component name is standardized so
  install(
    TARGETS ${target_name}
    EXPORT ${EXPORT_SET}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT ${CMT_TARGET_STANDARD_NAME}_Runtime
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT ${CMT_TARGET_STANDARD_NAME}_Runtime
    NAMELINK_COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development

    # header includes:
    FILE_SET cmt_public_headers
    COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development

    FILE_SET cmt_interface_headers
    COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

  if(CMTFCN_SUBTARGETS)
    foreach(subtarget ${CMTFCN_SUBTARGETS})
      install(
        TARGETS ${subtarget}
        EXPORT ${EXPORT_SET}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Runtime
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Runtime
        NAMELINK_COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
        FILE_SET cmt_public_headers
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
        INCLUDES
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        FILE_SET cmt_interface_headers
        COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development
        INCLUDES
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endforeach()
  endif()

  install(
    EXPORT ${EXPORT_SET}
    NAMESPACE ${CMT_TARGET_NAMESPACE}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
    COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development)
endfunction()

# generates a basic <ProjectName>Config.cmake file, it should only be called 
# once per project, probably in src directory.
# 
# It makes a bunch of assumptions about the structure of the project.
# 
# * There is a primary target in the project, there may be additional 
#   optionalally installed targets, but they all require the primary target.
#   This is because the cmake config package file is on a project basis, but 
#   needs to be installed with a target. this probably needs to be more explicit 
#   in the dependency graph.
# * All dependencies are required. (ToDo?)
# * No FindPackage component support. (ToDo?), grabs everything availiable.
# 
# Input args:
#   Positional:
#     (Required) : primary_target, this is the target that this pkg config gets 
#                  installed with (as part of the development component. This 
#                  means that this target is a requirement for any development)
#     
#   Multi-Value:
#     (Optional) : REQUIRED_DEPS - Any required deps that users of this project. 
function(cmt_install_cmake_config primary_target)
  cmake_parse_arguments("CMTFCN" "" "" "REQUIRED_DEPS;TARGETS" "${ARGN}")

  include(CMakePackageConfigHelpers)

  set(CMT_PKGCFG_ProjectName ${PROJECT_NAME})
  set(CMT_PKGCFG_Dependecies ${CMTFCN_REQUIRED_DEPS})

  get_target_property(CMT_TARGET_EXPORT_NAME ${primary_target} CMT_EXPORT_NAME)
  get_target_property(CMT_TARGET_NAMESPACE ${primary_target} CMT_NAMESPACE)
  get_target_property(CMT_TARGET_STANDARD_NAME ${primary_target} CMT_STANDARD_NAME)

  if(NOT (CMT_TARGET_NAMESPACE STREQUAL PROJECT_NAME))
    message(FATAL_ERROR "Tried to install config file for primary target ${target} which is not a member of project ${PROJECT_NAME}")
  endif()

  set(CMT_PKGCFG_Targets "")
  list(APPEND CMT_PKGCFG_Targets "${CMT_TARGET_EXPORT_NAME}")

  # get the standard name/namespace for each non-primary target:
  foreach(target ${CMTFCN_TARGETS})
    get_target_property(TMP_TARGET_NAMESPACE ${target} CMT_NAMESPACE)
    get_target_property(TMP_TARGET_EXPORT_NAME ${target} CMT_EXPORT_NAME)
    if(NOT (TMP_TARGET_NAMESPACE STREQUAL PROJECT_NAME))
      message(FATAL_ERROR "Tried to install config file for target ${target} which is not a member of project ${PROJECT_NAME}")
    endif()
    list(APPEND CMT_PKGCFG_Targets "${TMP_TARGET_EXPORT_NAME}")
  endforeach()



  message(
    DEBUG
    "Installing target config: ${target_name}\n"
    "      Export name: ${CMT_TARGET_EXPORT_NAME}\n"
    "      Namespace: ${CMT_TARGET_NAMESPACE}\n"
    "      Standard name: ${CMT_TARGET_STANDARD_NAME}")

  message(DEBUG "Configuring cmake package config for ${target_name}")
  message(DEBUG "src cmt_packageconfig ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/cmt_packageconfig.cmake.in")
  configure_package_config_file(
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/cmake/cmt_packageconfig.cmake.in 
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
    # NO_SET_AND_CHECK_MACRO
    # NO_CHECK_REQUIRED_COMPONENTS_MACRO
 )

 write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
 VERSION ${PROJECT_VERSION}
 COMPATIBILITY SameMajorVersion)




 install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  # EXPORT ${CMT_TARGET_NAMESPACE}${CMT_TARGET_EXPORT_NAME}Targets
  # NAMESPACE ${CMT_TARGET_NAMESPACE}::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
  COMPONENT ${CMT_TARGET_STANDARD_NAME}_Development)

endfunction()