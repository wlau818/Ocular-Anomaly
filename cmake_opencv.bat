@echo off
echo ========================================
echo   Building ocular_cpp for Windows
echo ========================================

cd /d "%~dp0"
set "ROOT_DIR=%cd%"

cmake --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] CMake could not be found. Please install CMake and add it to your PATH.
    pause
    exit /b
)

if not exist "%ROOT_DIR%\CMakeLists.txt" (
    echo [!] ERROR: CMakeLists.txt was not found in: %ROOT_DIR%
    pause
    exit /b
)

echo [*] Cleaning old build artifacts...
if exist "%ROOT_DIR%\build" rmdir /s /q "%ROOT_DIR%\build"
del /q "%ROOT_DIR%\ocular_cpp*.pyd" 2>nul

:: ----------------------------------------
:: Check and install pybind11
:: ----------------------------------------
echo [*] Checking pybind11 installation...
"%ROOT_DIR%\.venv\Scripts\pip.exe" show pybind11 >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] pybind11 not found. Installing now...
    "%ROOT_DIR%\.venv\Scripts\pip.exe" install pybind11
    if %errorlevel% neq 0 (
        echo [!] ERROR: Failed to install pybind11.
        pause
        exit /b
    )
    echo [*] pybind11 installed successfully.
) else (
    echo [*] pybind11 is already installed.
)

:: ----------------------------------------
:: Dynamically find pybind11 cmake dir
:: ----------------------------------------
echo [*] Resolving pybind11 cmake directory...

"%ROOT_DIR%\.venv\Scripts\python.exe" -c "import pybind11; print(pybind11.get_cmake_dir())" > "%TEMP%\pybind_path.txt" 2>nul
set /p PYBIND_PATH= < "%TEMP%\pybind_path.txt"
del "%TEMP%\pybind_path.txt" >nul 2>&1

if not exist "%PYBIND_PATH%\pybind11Config.cmake" (
    echo [*] Auto-detection failed. Trying fallback path...
    set "PYBIND_PATH=%ROOT_DIR%\.venv\Lib\site-packages\pybind11\share\cmake\pybind11"
)

if not exist "%PYBIND_PATH%\pybind11Config.cmake" (
    echo [!] ERROR: Could not locate pybind11 cmake files.
    echo     Try running: .venv\Scripts\pip install --upgrade pybind11
    pause
    exit /b
)

echo [*] pybind11 DIR: %PYBIND_PATH%

:: ----------------------------------------
:: OpenCV C++ SDK cmake dir
:: ----------------------------------------
echo [*] Resolving OpenCV cmake directory...

set "OpenCV_DIR=C:\opencv\build"

if not exist "%OpenCV_DIR%\OpenCVConfig.cmake" (
    echo [!] ERROR: OpenCV cmake files not found at: %OpenCV_DIR%
    echo     Make sure the C++ OpenCV SDK is installed at C:\opencv
    pause
    exit /b
)

echo [*] OpenCV DIR: %OpenCV_DIR%

:: ----------------------------------------
:: CMake Configure
:: ----------------------------------------
echo [*] Configuring CMake...
mkdir "%ROOT_DIR%\build"
cd /d "%ROOT_DIR%\build"

cmake -DPYTHON_EXECUTABLE="%ROOT_DIR%\.venv\Scripts\python.exe" ^
      -Dpybind11_DIR="%PYBIND_PATH%" ^
      -DOpenCV_DIR="%OpenCV_DIR%" ^
      "%ROOT_DIR%"

if %errorlevel% neq 0 (
    echo [!] ERROR: CMake configuration failed. See output above.
    cd /d "%ROOT_DIR%"
    rmdir /s /q "%ROOT_DIR%\build"
    pause
    exit /b
)

:: ----------------------------------------
:: CMake Build
:: ----------------------------------------
echo [*] Compiling C++ Module...
cmake --build . --config Release

if %errorlevel% neq 0 (
    echo [!] ERROR: Build failed. See output above.
    cd /d "%ROOT_DIR%"
    rmdir /s /q "%ROOT_DIR%\build"
    pause
    exit /b
)

:: ----------------------------------------
:: Finalize
:: ----------------------------------------
echo [*] Finalizing...
if exist Release\*.pyd move Release\*.pyd "%ROOT_DIR%\" >nul 2>&1

cd /d "%ROOT_DIR%"
rmdir /s /q "%ROOT_DIR%\build"

echo ========================================
echo   SUCCESS! ocular_cpp.pyd is ready.
echo ========================================
pause
