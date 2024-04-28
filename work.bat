@echo off
start remedybg bin\*.rdbg
start gvim src/main.jai
start wt.exe -d %~dp0
