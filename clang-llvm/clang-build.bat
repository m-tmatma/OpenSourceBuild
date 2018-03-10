@echo off

set INITDIR=%CD%
set PARAM_BUILDTOOL=%1
if "%PARAM_BUILDTOOL%" == "ninja" (
	set BUILDTOOL=%PARAM_BUILDTOOL%
	set CMAKE_GENERATOR=Ninja
	set CONFIGURATION=Release
) else if "%PARAM_BUILDTOOL%" == "vs2017" (
	set BUILDTOOL=%PARAM_BUILDTOOL%
	set CMAKE_GENERATOR="Visual Studio 15 2017"
) else (
	goto SHOW_HELP
)

set PARAM_ARCH=%2
if "%PARAM_ARCH%" == "x86" (
	set BUILD_ARCH=%PARAM_ARCH%
	set PARAM_ARCH=Win32
) else if "%PARAM_ARCH%" == "x64" (
	set BUILD_ARCH=%PARAM_ARCH%
	set PARAM_ARCH=x64
) else (
	goto SHOW_HELP
)

set PARAM_ACTION=%3
if "%PARAM_ACTION%" == "rebuild" (
	set BUILD_ACTION=%PARAM_ACTION%
) else if "%PARAM_ACTION%" == "update" (
	set BUILD_ACTION=%PARAM_ACTION%
) else (
	set BUILD_ACTION=update
)

set REVISION=%4
if "%REVISION%" == "" (
	set REVISION=HEAD
)

set CMAKE=cmake.exe
set NINJA=ninja.exe
set DEVENV="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.com"
set ROOTDIR=%INITDIR%\llvm-%REVISION%

if "%CONFIGURATION%" == "" (
	set BUILDDIR=%ROOTDIR%\build-%BUILDTOOL%-%BUILD_ARCH%
) else (
	set BUILDDIR=%ROOTDIR%\build-%BUILDTOOL%-%BUILD_ARCH%-%CONFIGURATION%
)

if exist %ROOTDIR% (
	echo svn update -r %REVISION%  %ROOTDIR%
	svn update -r %REVISION%  %ROOTDIR%
) else (
	echo svn co -r %REVISION%    http://llvm.org/svn/llvm-project/llvm/trunk        %ROOTDIR%
	svn co -r %REVISION%    http://llvm.org/svn/llvm-project/llvm/trunk        %ROOTDIR%
)

if exist %ROOTDIR%\tools\clang (
	echo svn update -r %REVISION%  %ROOTDIR%\tools\clang
	svn update -r %REVISION%  %ROOTDIR%\tools\clang
) else (
	echo svn co -r %REVISION%    http://llvm.org/svn/llvm-project/cfe/trunk         %ROOTDIR%\tools\clang
	svn co -r %REVISION%    http://llvm.org/svn/llvm-project/cfe/trunk         %ROOTDIR%\tools\clang
)

if exist %ROOTDIR%\tools\lld (
	echo svn update -r %REVISION%  %ROOTDIR%\tools\lld
	svn update -r %REVISION%  %ROOTDIR%\tools\lld
) else (
	echo svn co -r %REVISION%    http://llvm.org/svn/llvm-project/lld/trunk         %ROOTDIR%\tools\lld
	svn co -r %REVISION%    http://llvm.org/svn/llvm-project/lld/trunk         %ROOTDIR%\tools\lld
)

if exist %ROOTDIR%\tools\polly (
	echo svn update -r %REVISION%  %ROOTDIR%\tools\polly
	svn update -r %REVISION%  %ROOTDIR%\tools\polly
) else (
	echo svn co -r %REVISION%    http://llvm.org/svn/llvm-project/polly/trunk       %ROOTDIR%\tools\polly
	svn co -r %REVISION%    http://llvm.org/svn/llvm-project/polly/trunk       %ROOTDIR%\tools\polly
)

if exist %ROOTDIR%\projects\compiler-rt (
	echo svn update -r %REVISION%  %ROOTDIR%\projects\compiler-rt
	svn update -r %REVISION%  %ROOTDIR%\projects\compiler-rt
) else (
	echo svn co -r %REVISION%    http://llvm.org/svn/llvm-project/compiler-rt/trunk %ROOTDIR%\projects\compiler-rt
	svn co -r %REVISION%    http://llvm.org/svn/llvm-project/compiler-rt/trunk %ROOTDIR%\projects\compiler-rt
)

if exist %ROOTDIR%\projects\libcxx (
	echo svn update -r %REVISION%  %ROOTDIR%\projects\libcxx
	svn update -r %REVISION%  %ROOTDIR%\projects\libcxx
) else (
	echo svn co -r %REVISION%    http://llvm.org/svn/llvm-project/libcxx/trunk      %ROOTDIR%\projects\libcxx
	svn co -r %REVISION%    http://llvm.org/svn/llvm-project/libcxx/trunk      %ROOTDIR%\projects\libcxx
)


if exist %ROOTDIR%\projects\libcxxabi (
	echo svn update -r %REVISION%  %ROOTDIR%\projects\libcxxabi
	svn update -r %REVISION%  %ROOTDIR%\projects\libcxxabi
) else (
	echo svn co -r %REVISION%    http://llvm.org/svn/llvm-project/libcxxabi/trunk   %ROOTDIR%\projects\libcxxabi
	svn co -r %REVISION%    http://llvm.org/svn/llvm-project/libcxxabi/trunk   %ROOTDIR%\projects\libcxxabi
)

if "%BUILD_ACTION%" == "rebuild" (
	echo rebuild
	if exist %BUILDDIR%     rmdir /s /q %BUILDDIR%
	if exist %BUILDDIR%     rmdir /s /q %BUILDDIR%
	if exist %BUILDDIR%     rmdir /s /q %BUILDDIR%
	if exist %BUILDDIR%     rmdir /s /q %BUILDDIR%
	if exist %BUILDDIR%     rmdir /s /q %BUILDDIR%
	if exist %BUILDDIR%     rmdir /s /q %BUILDDIR%
	if exist %BUILDDIR%     rmdir /s /q %BUILDDIR%
	if exist %BUILDDIR%     rmdir /s /q %BUILDDIR%
	if exist %BUILDDIR%     exit /b 1
	if not exist %BUILDDIR% mkdir %BUILDDIR%
) else if "%BUILD_ACTION%" == "update" (
	echo update
	if not exist %BUILDDIR% mkdir %BUILDDIR%
)

cd /d %BUILDDIR%

del /Q LLVM-*.exe

@echo on
echo call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" %BUILD_ARCH%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" %BUILD_ARCH%

echo cd /d %BUILDDIR%
cd /d %BUILDDIR%
if "%BUILDTOOL%" == "ninja" (
	echo %CMAKE% -G %CMAKE_GENERATOR% -D CMAKE_INSTALL_PREFIX=c:\clang -D CMAKE_BUILD_TYPE=%CONFIGURATION% %ROOTDIR%
	%CMAKE% -G %CMAKE_GENERATOR% -D CMAKE_INSTALL_PREFIX=c:\clang -D CMAKE_BUILD_TYPE=%CONFIGURATION% %ROOTDIR% || goto onerror

	echo %NINJA% -v package
	%NINJA% -v package || goto onerror
) else if "%BUILDTOOL%" == "vs2017" (
	echo %CMAKE% -G %CMAKE_GENERATOR% -D CMAKE_INSTALL_PREFIX=c:\clang %ROOTDIR%
	%CMAKE% -G %CMAKE_GENERATOR% -D CMAKE_INSTALL_PREFIX=c:\clang %ROOTDIR% || goto onerror

	echo %DEVENV% LLVM.sln  /build "Release|%PARAM_ARCH%"
	%DEVENV% LLVM.sln  /build "Release|%PARAM_ARCH%" || goto onerror
)

cd /d %INITDIR%\
echo OK
exit /b 0

:onerror
cd /d %INITDIR%\
echo NG
exit /b 1

:SHOW_HELP
	@echo off
	echo clang-build.bat BUILDTOOL ARCH [action]
	echo BUILDTOOL
	echo ninja
	echo vs2017
	echo ARCH
	echo x86: build for x86
	echo x64: build for x64
	echo action
	echo update : update build
	echo rebuild: rebuild
	exit /b 1
