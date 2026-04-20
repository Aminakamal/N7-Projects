# OpenGL Lighting

- Building
  - [Windows](#windows)
  - [Linux](#linux)
  - [MacOs](#macos)

---

## Windows

### Prerequisites

Not necessary if you already did the previous tp, but to recall:

- download and install the latest version of CMake

  - download here (choose "Windows x64 Installer:"): <https://cmake.org/download/>

> [!IMPORTANT]
> When installing make sure that the checkbox "ne pas ajouter cmake au PATH" is NOT checked

- if you don't have it already, download and install MS Visual Studio Community Edition (free for students): <https://visualstudio.microsoft.com/downloads/>

  - install instructions here: <https://docs.microsoft.com/en-us/cpp/build/vscpp-step-0-installation?view=vs-2019>

> [!IMPORTANT]
> install the "Desktop development with C++"
  
  - If you have VS already installed, you can go in **Tools** --> **Get Tools and Features...** to install "Desktop development with C++" if it is missing.

### Create the Visual Studio Solution

This step enables you to create the project file to load inside VS:

- unzip the code inside a folder.

> [!WARNING]
> Avoid to place the code in folders with spaces and accented characters in the path.

- open a Terminal and go to the directory containing the code.

- execute:

  - `md build`
  
  - `cd build`
  
  - `cmake -G "Visual Studio 16 2019" -A x64 -DCMAKE_BUILD_TYPE:STRING=Release ..`
  
  - `dir`
  
> [!NOTE]
> if you had a different version of VS installed (not the latest) you may need to adapt the string `Visual Studio 16 2019` to your version: e.g. Visual Studio 15 2017, Visual Studio 14 2015, Visual Studio 12 2013
  
- if everything went well you should find a file named `tp2.sln` inside the directory.

### Compile, build, execute

- open `tp3.sln` inside VS either by double clicking on it or opening from inside VS

- build the solution (**Build Solution** from the **Build menu**)

- from the tp directory copy `freeglut\bin\x64\freeglut.dll` in `build\Release`

- execute the code:  

  - Select the project you want to run (e.g. `lumiere`), right click on it and select **Set as Startup Project** 
  
  - On the menu bar, choose **Debug** --> **Start without debugging**.

(see <https://docs.microsoft.com/en-us/cpp/build/vscpp-step-2-build?view=vs-2019> for how to build, execute, etc)

### Editing the code

Edit the code according to the assignments that are given, rebuild the solution and execute.

> [!NOTE]
> You need to run the cmake line only **once**

> [!NOTE]
> You need to copy the dll file only **once**.

---

## Linux

### Prerequisites

**Not necessary if you already did the previous tp.**

In order to develop with OpenGL some system packages are required (unless you are using the N7 machines):

```shell
sudo apt-get install libglu1-mesa-dev freeglut3-dev build-essential mesa-common-dev libxi-dev libxmu-dev automake
```

To build this code we use the CMake build system. You can install CMake from the system package manager but you need a recent version >= 3.10. Check the version that is provided by your linux distribution and if it is suitable usually you need to.

```shell
sudo apt-get install cmake
```

otherwise you can install the binaries from here (choose Linux x86_64): <https://cmake.org/download/>

Once downloaded, in order to install:

```shell
chmod +x cmake-X.YY.Z-Linux-x86_64.sh
sudo ./cmake-X.YY.Z-Linux-x86_64.sh --prefix=/usr/local/ --skip-license
```
  
### Build

To compile and build the code you do 

 ```shell
 mkdir build && cd build
 cmake ..
 make lumiere
 ```

Also,

```shell
make all
```

builds everything, and

```shell
make clean
```

cleans everything.

Execute the code:

```shell
./lumiere
```

### Editing the code

Edit the code as required and then

```shell
make lumiere
```

> [!NOTE]
> the cmake line has to be run only **once**

---

## macOS

### Prerequisites

In order to develop with OpenGL check if

```shell
ls  /System/Library/Frameworks/
```

contains OpenGL and GLUT frameworks.
If not you need to install XCode  from the `Mac App Store`, see here for more details <https://developer.apple.com/support/xcode/>

Download and install the latest version of CMake <https://cmake.org/download/> OR if you have `brew` installed you can do

```shell
brew install cmake
```

### Build

Same as Linux.

### Editing the code

Same as Linux.
