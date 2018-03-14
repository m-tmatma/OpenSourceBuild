#!/usr/bin/python

import os
import os.path
import shutil
import subprocess
import time
import distutils.spawn

def checkout_or_update(dir):
	urls = [
		[ "http://llvm.org/svn/llvm-project/llvm/trunk"        ,"." ],
		[ "http://llvm.org/svn/llvm-project/cfe/trunk"         ,"./tools/clang" ],
		[ "http://llvm.org/svn/llvm-project/lld/trunk"         ,"./tools/lld" ],
		[ "http://llvm.org/svn/llvm-project/polly/trunk"       ,"./tools/polly" ],
		[ "http://llvm.org/svn/llvm-project/compiler-rt/trunk" ,"./projects/compiler-rt" ],
		[ "http://llvm.org/svn/llvm-project/libcxx/trunk"      ,"./projects/libcxx" ],
		[ "http://llvm.org/svn/llvm-project/libcxxabi/trunk"   ,"./projects/libcxxabi" ],
	]

	start = time.time()
	for url in urls:
		checkout_dir = os.path.normpath(os.path.join(dir, url[1]))
		svn_dir = os.path.normpath(os.path.join(checkout_dir, ".svn"))
		if os.path.isdir(svn_dir):
			command = " ".join(['svn', 'up ', checkout_dir])
		else:
			command = " ".join(['svn', 'co ', url[0], checkout_dir])
		print command
		result = subprocess.call(command, shell=True)

	end = time.time()

	return end - start

def get_builddir(prefix, buildmethod, cpuarch):
	elements = []
	if prefix:
		elements.append(prefix)
	if buildmethod:
		elements.append(buildmethod)
	if cpuarch:
		elements.append(cpuarch)
		
	builddir = "-".join(elements)
	return os.path.normpath(builddir)

def run_cmake(buildmethod):
	start = time.time()
	cmake_path_forMac = "/Applications/CMake.app/Contents/bin/cmake"
	if os.path.isfile(cmake_path_forMac):
		cmake_path = cmake_path_forMac
	else:
		cmake_path = "cmake"

	if buildmethod == "make":
		generator = '-G "Unix Makefiles"'
	elif buildmethod == "ninja":
		generator = '-G "Ninja"'

	command = " ".join([cmake_path, generator, ".."])
	print command
	result = subprocess.call(command, shell=True)

	end = time.time()
	return end - start

def run_build(buildmethod):
	start = time.time()
	if buildmethod == "make":
		command = " ".join(["make", "-j 4"])
	elif buildmethod == "ninja":
		command = " ".join(["ninja", "-v"])

	print command
	result = subprocess.call(command, shell=True)
	end = time.time()
	return end - start

def run_package(buildmethod):
	start = time.time()
	if buildmethod == "make":
		command = " ".join(["make", "-j 4", "package"])
	elif buildmethod == "ninja":
		command = " ".join(["ninja", "-v ", "package"])

	print command
	result = subprocess.call(command, shell=True)
	end = time.time()
	return end - start

def main():
	start = time.time()
	dir = "llvm"
	prefix = "build"
	
	if distutils.spawn.find_executable('ninja') != None:
		buildmethod = "ninja"
	else:
		buildmethod = "make"
	cpuarch = "x86"

	time_checkout = checkout_or_update(dir)

	os.chdir(dir)

	builddir = get_builddir(prefix, buildmethod, cpuarch)
	if os.path.isdir(builddir):
		shutil.rmtree(builddir)

	os.makedirs(builddir)
	os.chdir(builddir)

	time_cmake = run_cmake(buildmethod)
	time_build = run_build(buildmethod)
	time_package = run_package(buildmethod)

	end = time.time()
	diff = end - start

	print "svn time: " + str(time_checkout) + " sec"
	print "cmake time: " + str(time_cmake) + " sec"
	print "build time: " + str(time_build) + " sec"
	print "build package: " + str(time_package) + " sec"
	print "total time: " + str(diff) + " sec"

main()
