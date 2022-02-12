# Cessna 210 family
The Cessna 210 "Centurion" models implemented for FlightGear.

## Installation

Put the contents of this repository into a directory of your choice by either
* `git clone`ing it:
	```sh
	~$ cd /some/path/Aircraft
	/some/path/Aircraft$ git clone https://github.com/TheFGFSEagle/c210-family
	```
* or downloading the repository as a ZIP file and unzipping it with your favorite archive manager into `/some/path/Aircraft/c210-family`

Then, tell FlightGear to search `/some/path/Aircraft` for aircraft by either
* adding `/some/path/Aircraft` to the list of additional aircraft folders in the Addons tab of FGLauncher
* or passing `--aircraft-dir=/some/path/Aircraft` on the command line.

### IMPORTANT:
**No matter which of the methods above you use, make sure that you put this into `/some/path/Aircraft/c210-family` and pass `/some/path/Aircraft` to FlightGear to search for aircraft in - if you change `Aircraft/c210-family` to anything else, FlightGear will NOT be able to find and load the 3D model !**

## Contents

* Cessna P210N "Pressurized Centurion"
* Cessna P210N turboprop conversion "Silver Eagle"
