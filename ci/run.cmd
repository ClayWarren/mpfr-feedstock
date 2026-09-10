@echo on
set "CONDA_SUBDIR=win-64"
if not exist C:\mpfr-tools\python.exe (
    "%RUNNER_TEMP%\micromamba.exe" create -y -p C:\mpfr-tools -c conda-forge conda-build conda-index
    if errorlevel 1 exit /b 1
)
call C:\mpfr-tools\condabin\conda.bat activate C:\mpfr-tools
if errorlevel 1 exit /b 1
python ci\build.py %1
if errorlevel 1 exit /b 1
