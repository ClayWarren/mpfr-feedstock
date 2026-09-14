@echo on
cl /nologo /W4 test-native.c /I"%LIBRARY_INC%" /Fe:consumer-msvc.exe /link /LIBPATH:"%LIBRARY_LIB%" mpfr.lib gmp.lib
if errorlevel 1 exit /b 1
consumer-msvc.exe
if errorlevel 1 exit /b 1
