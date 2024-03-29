@echo off
REM ****************************************************************************
REM Vivado (TM) v2022.2.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Sun Jan 28 00:36:51 +0200 2024
REM SW Build 3788238 on Tue Feb 21 20:00:34 MST 2023
REM
REM IP Build 3783773 on Tue Feb 21 23:41:56 MST 2023
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim tb_Binary_Calculator_behav -key {Behavioral:sim_1:Functional:tb_Binary_Calculator} -tclbatch tb_Binary_Calculator.tcl -view C:/Users/iones/Desktop/AMD/Binary_Calculator/Modules/Binary_Calculator/Binary_Calculator/tb_Binary_Calculator_behav.wcfg -log simulate.log"
call xsim  tb_Binary_Calculator_behav -key {Behavioral:sim_1:Functional:tb_Binary_Calculator} -tclbatch tb_Binary_Calculator.tcl -view C:/Users/iones/Desktop/AMD/Binary_Calculator/Modules/Binary_Calculator/Binary_Calculator/tb_Binary_Calculator_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
