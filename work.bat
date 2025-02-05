@echo off
start remedybg bin\debug.rdbg
start gvim source/main.jai
start wt.exe -d %~dp0
