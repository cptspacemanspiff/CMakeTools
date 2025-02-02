# CMakeTools
> [!WARNING]
> This library is still under active development, and has not fully stabilized, use at your own risk.

Writing a good, high quality, CMake project is hard. There is alot of boilerplate required even for the simple cases. Even if you know what you are doing it can be a pain, with a lot of copy pasting from other projects. It does not have to be that way. The objective of this library is to provide simplified abstractions, and opinionated standardizations for the 95% use case, with the overall goal of spending less time fighting your build system and more time building your code.

## Goal

Ideally this should be a project that evolves to the needs of the users. Often there are so many scripts that are hacked together within a company/project/etc. Developers have enough to do. Recreating the wheel, that thousands of others have made in the past is not a good use of an individuals time and life. That being said I have only worked in a relatively few number of codebases, and as the great Computer Scientist Leo Tolstoy once said:
```
All happy build systems are alike; each unhappy build system is unhappy in its own way.
```

So this has been built to solve my own unhappy build systems, please contribute if your feel that there are changes needed for it to fix your own.

## Features:

- [x] Standardized Conventions.
  - [x] Support other people including the CMake project via installed dependency, as submodule (subfolder), or via fetch-content.
  - [x] Standardized target namespaces, variables and target names.
  - [x] Automatic enabling/generation of symbol visbility.
  - [ ] Installed RPATH/RUNPATH Defaults.
  - [x] Standardized Install/Export of CMake targets.
  - [x] Best Practice Defaults.
- [ ] External versioning help
  - [x] Support projectVersionDetails.cmake as external version script.
  - [x] Commits since last version update.
  - [ ] Check whether we are on main/master and yell warnings if out of date.
- [x] Multi-target generator support
  - [x] Ninja Multi-Config
  - [x] MSVC
- [ ] Automatic packaging with CPACK.
  - [ ] Multi OS
    - [ ] Ubuntu
    - [ ] RHEL
    - [ ] Windows
    - [ ] MacOS
  - [ ] Automatic dependency parsing and versioning.
- [ ] External Build Helpers/ Integration with fetchContent
  - [ ] Build external projects from source at configure time.
- [ ] Integrated testing helpers.
  - [ ] Static Analysis
    - [ ] Clang-Tidy
    - [ ] CppCheck
  - [ ] Sanitizers
    - [ ] LLVM/GCC
      - [ ] Address
      - [ ] Thread
      - [ ] Undefined Behavior
    - [ ] Windows Support
      - [ ] Address
  - [x] Code Coverage
    - [x] gcovr
    - [x] lcov
  - [ ] Code Formating
    - [ ] Clang-Format 
  - [ ] ABI Verification
    - [ ] ABI-Compliance-Checker
  - [ ] Performance reports
    - [ ] d3-flamegraph
  - [ ] git pre-commits
- [ ] Documentation Helpers
  - [ ] Doxygen CMake helpers.
    - [ ] Dependency Graphs
    - [ ] PlantUML integration
    - [ ] Diagnostic Mode
- [ ] Meta-builds
  - [ ] Meta CMake Projects
  - [ ] Meta Documentation
  - [ ] Meta Packaging
- [ ] Cross Compilation
  - [ ] WASM
  - [ ] X86
  - [ ] ARM
- [ ] Simple Find<PackageName>.cmake Scripts
- [ ] Utility Scripts
  - [ ] Push/Pop stack

# Guide:

In order to have a standardized build process there are three types of targets/helper functions that CMakeTools uses:

1. Target level targets: These are your standard cmake targets/executables, an individual cmake project can have multiple of these, and they may or may not be exported and installed.
2. Project level targets: These are things that are made once per project. Examples could be Documentation, or Packaging. 
3. Build level targets: These are things that are made once per build, and can include meta-build artifacts (combined documentation, meta-rpm), coverage reports, static analysis.

The rational is that most things are done on a target by target basis, however there are often things that are shared at the project level (Versioning, documentation, notes, etc). Above that are things that are share across all targets at the build level.

## Build Level Targets:

### Code Coverage

To build a code coverage (and generate coverage report) use the coverage cmake build type. This will automatically add targets that are specified as Covered to the code coverage analysis.

CMT handles code coverage as a special global target, this means that for a given build there will be a single code coverage report. To add a target to the coverage report simply add the following:

```cmt_coverage_setup_target(TARGET)```

This relied on using cmt_target_headers, to locate all headers and source files associated with a target and aromatically add them to the coverage report.

The coverage report can be generated by lcov, gcovr or both using either the GNU and llvm compilers (currently only tested on linux). The resulting artifacts get placed into coverage/gcovr and coverage/lcov in the build directory. 

## Project Level Targets

### Documentation

For documentation there is currently only a single documentation generator implemented so far: Doxygen. Doxygen uses 2 types of documentation, autogenerated documentation from code comments, and manually created documentation pages. 

In order to 

### Packaging

### Project Helper Target

## Target Level Targets:

### Regular Targets

### Versioning helper

## General Flow:

If there is a cmt_* prefixed funtion, use it. the main workhorses of this opinionated library are cmt_add_library and cmt_add_executable. Additionally cmt_target_headers is the way to add headers to be installed, as this process automatically adds them to additional fields on the target, so that they can be picked up in documentation, code coverage, static analysis, packaging, etc.

One of the main goals is to create a opinionated builds so that everything related to a target is embedded in that target. This allows one to create additional tools as needed to and plug them in to the build structure without having to rewrite a bunch of code, or worry about how to pass data from one part of the build structure to the other.

A simple example build is the following, which builds up a project and a adds a library to it. The cmt_* functions wrap up their normal calls and add custom properties to the targets, allowing one to have simple standardized interfaces.

```cmake
# project folder CMakeLists:
include(cmake/CMakeTools/CMTUtils.cmake)

Project(EEP VERSION 0.1.0)
set(CMAKE_CXX_STANDARD 17)
cmt_project_setup()

find_package(pybind11 REQUIRED COMPONENTS embed)

# src folder CMakeLists
cmt_add_library(Plugin NAMESPACED SHARED)
target_sources(${CMT_LAST_TARGET} PRIVATE
    PluginInterpreterImpl.cpp
    PluginObjectImpl.cpp
    PluginTypesImpl.cpp
    Plugin.cpp
    Exceptions.cpp)

target_link_libraries(${CMT_LAST_TARGET} PRIVATE pybind11::embed)

# add headers:
cmt_target_headers(${CMT_LAST_TARGET}
    PRIVATE
    FILES
    PluginInterpreterImpl.h
    PluginObjectImpl.h)

cmt_target_headers(${CMT_LAST_TARGET}
    PUBLIC
    BASE_DIRS
    ${PROJECT_SOURCE_DIR}/include
    FILES
    ${PROJECT_SOURCE_DIR}/include/EEP/Plugin.h
    ${PROJECT_SOURCE_DIR}/include/EEP/Exceptions.h)

cmt_coverage_setup_target(${CMT_LAST_TARGET})

# test folder CMakeLists

# doc folder CMakeLists

```

The simple code a
