setlocal

pushd %SP_DIR%
pushd cntk\tests
echo RUNNING cntk unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\debugging\tests
echo RUNNING cntk\debugging unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\internal\tests
echo RUNNING cntk\internal unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\io\tests
echo RUNNING cntk\io unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\layers\tests
echo RUNNING cntk\layers unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\learners\tests
echo RUNNING cntk\learners unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\logging\tests
echo RUNNING cntk\logging unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\losses\tests
echo RUNNING cntk\losses unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\metrics\tests
echo RUNNING cntk\metrics unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\ops\tests
echo RUNNING cntk\ops unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\train\tests
echo RUNNING cntk\train unit tests...
pytest --deviceid gpu
if errorlevel 1 exit /b 1
popd

pushd cntk\losses
echo RUNNING cntk\losses doctests...
pytest __init__.py
if errorlevel 1 exit /b 1

pushd cntk\ops
echo RUNNING cntk\ops doctests...
pytest __init__.py
if errorlevel 1 exit /b 1
popd

pushd cntk\ops
echo RUNNING cntk\ops function doctests...
pytest functions.py
if errorlevel 1 exit /b 1
popd

pushd cntk\ops\sequence
echo RUNNING cntk\ops\sequence doctests...
pytest __init__.py
if errorlevel 1 exit /b 1
popd

pushd cntk\layers
echo RUNNING cntk\layers doctests...
pytest layers.py
if errorlevel 1 exit /b 1
popd

endlocal
