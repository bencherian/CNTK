@echo off
setlocal enabledelayedexpansion

REM Copyright (c) Microsoft. All rights reserved.
REM
REM Licensed under the MIT license. See LICENSE.md file in the project root
REM for full license information.
REM ==============================================================================

REM Grab the parameters
REM
REM Note: don't rely on environment variables, since properties may have been
REM overridden at msbuild invocation.
set p_OutDir=%~1
set p_DebugBuild=%~2
set p_GpuBuild=%~3
set p_CNTK_COMPONENT_VERSION=%~4
set p_SWIG_PATH=%~5
set p_CNTK_PY_VERSIONS=%~6
set p_CNTK_PY27_PATH=%~7
set p_CNTK_PY35_PATH=%~8
set p_CNTK_PY36_PATH=%~9

setlocal enabledelayedexpansion
REM No need to check Python versions if being built with Conda
if not defined CONDA_BUILD (
  REM Construct p_CNTK_PY_VERSIONS if not explicitly defined
  REM (Note: to disable Python build completely, no CNTK_PYx_PATH variable must be defined)
  if not defined p_CNTK_PY_VERSIONS (
    REM Note: leading space doesn't hurt
    if defined p_CNTK_PY27_PATH set p_CNTK_PY_VERSIONS=!p_CNTK_PY_VERSIONS! 27
    if defined p_CNTK_PY35_PATH set p_CNTK_PY_VERSIONS=!p_CNTK_PY_VERSIONS! 35
    if defined p_CNTK_PY36_PATH set p_CNTK_PY_VERSIONS=!p_CNTK_PY_VERSIONS! 36
  )

  REM Validate p_CNTK_PY_VERSIONS contents.
  for %%p in (!p_CNTK_PY_VERSIONS!) do (
    if not "%%~p" == "27" if not "%%~p" == "35" if not "%%~p" == "36" echo Build for unsupported Python version '%%~p' requested, stopping&exit /b 1
  )

  REM Validate p_CNTK_PY_VERSIONS contents.
  REM (Note: Don't merge with above loop; more robust parsing)
  set nothingToBuild=1
  for %%p in (!p_CNTK_PY_VERSIONS!) do (
    call set extraPath=!p_CNTK_PY%%~p_PATH!
    if not defined extraPath echo Build for Python version '%%~p' requested, but CNTK_PY%%~p_PATH not defined, stopping&exit /b 1
    set nothingToBuild=
  )
  if defined nothingToBuild echo Python support not configured to build.&exit /b 0
) else (
	if not "%PY_VER%" == "36" or "%PY_VER%" == "35" or "%PY_VER%" == "27" (
		echo Attempting to build conda package for unsupported Python version %PY_VER%
		exit /b 1
	)
)
if "%p_DebugBuild%" == "true" echo Currently no Python build for Debug configurations, exiting.&exit /b 0

REM No need for VS activation in conda build
if not defined CONDA_BUILD (
  set pysrc_dir=%CD%
  if not exist "%VS2017INSTALLDIR%\VC\Auxiliary\build\vcvarsall.bat" (
    echo Error: "%VS2017INSTALLDIR%\VC\Auxiliary\build\vcvarsall.bat" not found.
    echo Make sure you have installed Visual Studio 2017 correctly.
	exit /b 1
  )
  call "%VS2017INSTALLDIR%\VC\Auxiliary\build\vcvarsall.bat" amd64 -vcvars_ver=14.11
)
if defined pysrc_dir (
  pushd %pysrc_dir%
)
set CNTK_LIB_PATH=%p_OutDir%
set CNTK_COMPONENT_VERSION=%p_CNTK_COMPONENT_VERSION%

REM These variables are already set appropriately or unneeded in the conda build environment
if not defined CONDA_BUILD (
  set DIST_DIR=%p_OutDir%\Python
  set "PATH=%p_SWIG_PATH%;%PATH%"
  set MSSdk=1
  set DISTUTILS_USE_SDK=1
)
pushd "%CNTK_LIB_PATH%"
if errorlevel 1 echo Cannot change directory.&exit /b 1

set CNTK_LIBRARIES=
for %%D in (
  Cntk.Composite-%CNTK_COMPONENT_VERSION%.dll
  Cntk.Core-%CNTK_COMPONENT_VERSION%.dll
  Cntk.Deserializers.Binary-%CNTK_COMPONENT_VERSION%.dll
  Cntk.Deserializers.HTK-%CNTK_COMPONENT_VERSION%.dll
  Cntk.Deserializers.TextFormat-%CNTK_COMPONENT_VERSION%.dll
  Cntk.Math-%CNTK_COMPONENT_VERSION%.dll
  Cntk.ExtensibilityExamples-%CNTK_COMPONENT_VERSION%.dll  
  Cntk.PerformanceProfiler-%CNTK_COMPONENT_VERSION%.dll
  Cntk.ImageWriter-%CNTK_COMPONENT_VERSION%.dll
) do (
  if defined CNTK_LIBRARIES (
    set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D
  ) else (
    set CNTK_LIBRARIES=%CNTK_LIB_PATH%\%%D
  )
)

REM These libraries are provided by conda package dependencies
if not defined CONDA_BUILD (
  for %%D in (
    libiomp5md.dll
    mklml.dll
  ) do (
    if defined CNTK_LIBRARIES (
      set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D
   ) else (
      set CNTK_LIBRARIES=%CNTK_LIB_PATH%\%%D
    )
  )

  @REM mkldnn.dll is optional
  if exist mkldnn.dll (
   set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\mkldnn.dll
  )
)

@REM Cntk.BinaryConvolution-%CNTK_COMPONENT_VERSION%.dll is optional
if exist Cntk.BinaryConvolution-%CNTK_COMPONENT_VERSION%.dll for %%D in ( 
  Cntk.BinaryConvolution-%CNTK_COMPONENT_VERSION%.dll 
  Halide.dll 
) do set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D 

@REM Cntk.Deserializers.Image-%CNTK_COMPONENT_VERSION%.dll (plus dependencies) is optional
if exist Cntk.Deserializers.Image-%CNTK_COMPONENT_VERSION%.dll for %%D in (
  Cntk.Deserializers.Image-%CNTK_COMPONENT_VERSION%.dll
  opencv_world*.dll
) do set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D

@REM These libraries are provided by conda packages as well
@REM Cntk.Deserializers.Image-%CNTK_COMPONENT_VERSION%.dll (plus dependencies) is optional
if not defined CONDA_BUILD (
  if exist Cntk.Deserializers.Image-%CNTK_COMPONENT_VERSION%.dll for %%D in (
    zip.dll
    zlib.dll
  ) do set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D
)


if not defined CONDA_BUILD (
  if /i %p_GpuBuild% equ true for %%D in (
    cublas64_*.dll
    cudart64_*.dll
    cudnn64_*.dll
    curand64_*.dll
    cusparse64_*.dll
  ) do (
    set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D
  )
)

if /i %p_GpuBuild% equ true (
  set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\nvml.dll
)

popd
if errorlevel 1 echo Cannot restore directory.&exit /b 1
cd
REM Build everything in supplied order
if not defined CONDA_BUILD (
  echo Building wheels for non-conda build
  set "oldPath=%PATH%"
  for %%p in (%p_CNTK_PY_VERSIONS%) do (
    call set "extraPath=!p_CNTK_PY%%~p_PATH!
    echo Building for Python version '%%~p', extra path is !extraPath!
    set PATH=!extraPath!;!oldPath!
    python.exe .\setup.py ^
        build_ext --inplace --force --compiler msvc --plat-name=win-amd64 ^
        bdist_wheel --dist-dir "%DIST_DIR%"
    if errorlevel 1 exit /b 1
  )
) else (
  echo Installing conda package to host environment
  %PYTHON% setup.py install --single-version-externally-managed -r record.txt --compile
)
