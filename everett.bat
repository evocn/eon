@echo off
cd ../../Code/everett/bin
start remedybg everett.rdbg
start wt.exe -d C:/Users/alexa/Code/everett/bin
start gvim -c "simalt ~x" ../src/main.jai
