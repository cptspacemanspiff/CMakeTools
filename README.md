# CMakeTools
Writing good, high quality, CMake projects is hard. There is alot of boilerplate required even for the simple cases,even if you know what you are doing it can be a pain, with a lot of copy pasting from other projects. It does not have to be that way. The objective of this library is to provide simplified abstractions, and opinionated standardizations for the 95% use case, with the overall goal of spending less time fighting your build system and more time building your code.

## Goal

Ideally this should be a project that evolves to the needs of the users. Often there are so many scripts that are hacked together within a company/project/etc. Developers have enough to do, recreating the wheel, that thousands of others have made in the past is not a good use of peoples time and life. That being said I have only worked in a relatively few number of codebases, and as the great Computer Scientist Leo Tolstoy once said:
```All happy build systems are alike; each unhappy build system is unhappy in its own way.```

So this has been built to solve my unhappy build system, please contribute if your feel that there are changes needed for it to fix your own.


## Features:

* Standardized conventions to support other people including the CMake project via installed dependency, as submodule (subfolder), or via fetch-content.
  * standardized target namespaces, variables and targetnames.
* Automatic support for library best practices in terms of symbol visability.
* Doxygen generation support.
* Automatic packaging for RPM, Debian, Windows and MacOS.
  * Automatic dependency parsing.
  * Versioning dependnecies.
  * RPATH/RUNPATH defaults.
* Testing helpers
  * Static analysis
  * Automatic sanitizer support with CI system.
  * Supporting multi-target builds.
* cross compilation support
  * QEMU, ARM, x86 


## Guide:

### Code Coverage

To build a code coverage (and generate coverage report) use the coverage cmake build type. This will automatically add targets that are specified as Covered to the code coverage analysis.

