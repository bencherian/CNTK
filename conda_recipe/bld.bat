@echo off
setlocal enabledelayedexpansion

set BOOST_INCLUDE_PATH=%LIBRARY_INC%
set BOOST_LIB_PATH=%LIBRARY_LIB%;%LIBRARY_BIN%
set CUB_PATH=%LIBRARY_INC%
set CUDA_PATH=%LIBRARY_PREFIX%
set CUDA_PATH_V9_1=%LIBRARY_PREFIX%
set CUDNN_PATH=%LIBRARY_PREFIX%
set MKL_PATH=%LIBRARY_PREFIX%
set SWIG_PATH=%LIBRARY_BIN%
set ZLIB_PATH=%LIBRARY_PREFIX%

echo Running bld.bat

MSBuild CNTK.sln /t:Rebuild /p:Configuration=Release /maxcpucount
