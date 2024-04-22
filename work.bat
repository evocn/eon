@echo off
start remedybg bin\everett.rdbg
start gvim src/main.jai
start wt.exe -d %~dp0
