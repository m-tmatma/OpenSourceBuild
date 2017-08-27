set INITDIR=%CD%
set ARCHITECTURE=x86
set CONFIGURATION=Release

@echo on
if "%VS150COMNTOOLS%" == "" (
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" %ARCHITECTURE%
)

set SRC_CMAKE=%INITDIR%\cmake
set OUTDIR_CMAKE=%INITDIR%\build-cmake-%ARCHITECTURE%-%CONFIGURATION%

if not exist "%SRC_CMAKE%" (
	git clone https://gitlab.kitware.com/cmake/cmake.git %SRC_CMAKE%
)

if     exist %OUTDIR_CMAKE%      rmdir /s /q %OUTDIR_CMAKE%
if not exist %OUTDIR_CMAKE%      mkdir %OUTDIR_CMAKE%

cd /d %OUTDIR_CMAKE%

cmake -G Ninja -D CMAKE_BUILD_TYPE=%CONFIGURATION% %SRC_CMAKE%  || goto error-end
ninja -v                    || goto error-end
ninja -v package            || goto error-end

cd /d %INITDIR%\
exit /b 0

:error-end
cd /d %INITDIR%\
exit /b 1
