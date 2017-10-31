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
set p_SWIG_PATH=%LIBRARY_BIN%

if not defined CONDA_BUILD (
	echo Release_Anaconda should only be built through conda build, exiting.&exit /b 1
)

if not "%PY_VER%" == "2.7" if not "%PY_VER%" == "3.6" echo Build for unsupported python version "%PY_VER%" requested, stopping & exit /b 1

if "%p_DebugBuild%" == "true" echo Currently no Python build for Debug configurations, exiting.&exit /b 0

set CNTK_LIB_PATH=%p_OutDir%

set DIST_DIR=%p_OutDir%\Python
set CNTK_COMPONENT_VERSION=%p_CNTK_COMPONENT_VERSION%
set MSSdk=1
set DISTUTILS_USE_SDK=1

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
  Cntk.BinaryConvolutionExample-%CNTK_COMPONENT_VERSION%.dll
  Cntk.PerformanceProfiler-%CNTK_COMPONENT_VERSION%.dll
) do (
  if defined CNTK_LIBRARIES (
    set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D
  ) else (
    set CNTK_LIBRARIES=%CNTK_LIB_PATH%\%%D
  )
)

@REM Cntk.Deserializers.Image-%CNTK_COMPONENT_VERSION%.dll (plus dependencies) is optional
if exist Cntk.Deserializers.Image-%CNTK_COMPONENT_VERSION%.dll for %%D in (
  Cntk.Deserializers.Image-%CNTK_COMPONENT_VERSION%.dll
  opencv_world*.dll
) do set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D

if /i %p_GpuBuild% equ true for %%D in (
  nvml.dll
) do (
  set CNTK_LIBRARIES=!CNTK_LIBRARIES!;%CNTK_LIB_PATH%\%%D
)

echo CNTK DLLs %CNTK_LIBRARIES%

popd
if errorlevel 1 echo Cannot restore directory.&exit /b 1

REM Build everything in supplied order
python setup.py build
pip install .

if not %ERRORLEVEL% == 0 echo Failed to build and install package& exit /b %ERRORLEVEL%
