set INITDIR=%CD%

@echo on
if "%VS150COMNTOOLS%" == "" (
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
)

set SRC_CMAKE=%INITDIR%\cmake
set OUTDIR_CMAKE=%INITDIR%\build-cmake

if not exist "%SRC_CMAKE%" (
	git clone https://gitlab.kitware.com/cmake/cmake.git %SRC_CMAKE%
)

if     exist %OUTDIR_CMAKE%      rmdir /s /q %OUTDIR_CMAKE%
if not exist %OUTDIR_CMAKE%      mkdir %OUTDIR_CMAKE%

cd /d %OUTDIR_CMAKE%

cmake -G Ninja %SRC_CMAKE%  || goto error-end
ninja -v                    || goto error-end

cd /d %INITDIR%\
exit /b 0

:error-end
cd /d %INITDIR%\
exit /b 1
