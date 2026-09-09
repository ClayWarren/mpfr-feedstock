@echo on
cl /nologo /W4 test-native.c /I"%LIBRARY_INC%" /Fe:consumer-msvc.exe /link /LIBPATH:"%LIBRARY_LIB%" mpfr.lib gmp.lib
if errorlevel 1 exit /b 1
consumer-msvc.exe
if errorlevel 1 exit /b 1
set "EXPECTED_MACHINE=8664 machine (x64)"
set "NATIVE_DLL=libmpfr-6.dll"
if "%target_platform%"=="win-arm64" (
    set "EXPECTED_MACHINE=AA64 machine (ARM64)"
    set "NATIVE_DLL=mpfr-6.dll"
)
dumpbin /headers consumer-msvc.exe | findstr /C:"%EXPECTED_MACHINE%"
if errorlevel 1 exit /b 1
dumpbin /headers "%LIBRARY_BIN%\%NATIVE_DLL%" | findstr /C:"%EXPECTED_MACHINE%"
if errorlevel 1 exit /b 1
if "%target_platform%"=="win-arm64" (
    call %CC% %CFLAGS% -I"%LIBRARY_INC%" test-native.c -L"%LIBRARY_LIB%" -lmpfr -lgmp %LDFLAGS% -o consumer-clang.exe
    if errorlevel 1 exit /b 1
    consumer-clang.exe
    if errorlevel 1 exit /b 1
    dumpbin /headers consumer-clang.exe | findstr /C:"AA64 machine (ARM64)"
    if errorlevel 1 exit /b 1
)
