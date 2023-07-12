@echo off

setlocal

for %%A in ("%~dp0") do set "script_dir=%%~fA" // getting the bat file directory

set /p name=Enter your lbox loader name: 
// ^ asking for the lbox loader name

start %script_dir%%name%.exe -beta // running the lbox loader with the beta parameter
