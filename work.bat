@echo off
start qrenderdoc
start remedybg bin\everett.rdbg
start gvim build.jai
start wt.exe -d %~dp0
