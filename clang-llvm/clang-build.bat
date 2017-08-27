@echo off

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

set CMAKE=cmake.exe
set NINJA=ninja.exe
set DEVENV="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.com"
set ROOTDIR=%~dp0llvm

if "%CONFIGURATION%" == "" (
	set BUILDDIR=%ROOTDIR%\build-%BUILDTOOL%-%BUILD_ARCH%
) else (
	set BUILDDIR=%ROOTDIR%\build-%BUILDTOOL%-%BUILD_ARCH%-%CONFIGURATION%
)

if exist %ROOTDIR% (
	svn update  %ROOTDIR%
) else (
	svn co    http://llvm.org/svn/llvm-project/llvm/trunk        %ROOTDIR%
)

if exist %ROOTDIR%\tools\clang (
	svn update  %ROOTDIR%\tools\clang
) else (
	svn co    http://llvm.org/svn/llvm-project/cfe/trunk         %ROOTDIR%\tools\clang
)

if exist %ROOTDIR%\tools\lld (
	svn update  %ROOTDIR%\tools\lld
) else (
	svn co    http://llvm.org/svn/llvm-project/lld/trunk         %ROOTDIR%\tools\lld
)

if exist %ROOTDIR%\tools\polly (
	svn update  %ROOTDIR%\tools\polly
) else (
	svn co    http://llvm.org/svn/llvm-project/polly/trunk       %ROOTDIR%\tools\polly
)

if exist %ROOTDIR%\projects\compiler-rt (
	svn update  %ROOTDIR%\projects\compiler-rt
) else (
	svn co    http://llvm.org/svn/llvm-project/compiler-rt/trunk %ROOTDIR%\projects\compiler-rt
)

if exist %ROOTDIR%\projects\libcxx (
	svn update  %ROOTDIR%\projects\libcxx
) else (
	svn co    http://llvm.org/svn/llvm-project/libcxx/trunk      %ROOTDIR%\projects\libcxx
)


if exist %ROOTDIR%\projects\libcxxabi (
	svn update  %ROOTDIR%\projects\libcxxabi
) else (
	svn co    http://llvm.org/svn/llvm-project/libcxxabi/trunk   %ROOTDIR%\projects\libcxxabi
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
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" %BUILD_ARCH%
if "%BUILDTOOL%" == "ninja" (
	%CMAKE% -G %CMAKE_GENERATOR% -D CMAKE_INSTALL_PREFIX=c:\clang -D CMAKE_BUILD_TYPE=%CONFIGURATION% %ROOTDIR% || goto onerror
	%NINJA% -v package || goto onerror
) else if "%BUILDTOOL%" == "vs2017" (
	%CMAKE% -G %CMAKE_GENERATOR% -D CMAKE_INSTALL_PREFIX=c:\clang %ROOTDIR% || goto onerror
	%DEVENV% LLVM.sln  /build "Release|%PARAM_ARCH%" || goto onerror
)

cd /d %~dp0
exit /b 0

:onerror
cd /d %~dp0
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
