@echo off
powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Doing this carries risks', 'Montegem Tech', 'OK', [System.Windows.Forms.MessageBoxIcon]::Warning)"
cls 
MODE 100,15
chcp 65001 >nul
title Montegem Tech Key System
color D

:Montegem Tech Key System
echo                    			[38;2;0;128;0m███╗   ███╗ ██████╗ ███╗   ██╗████████╗███████╗ ██████╗ ███████╗███╗   ███╗    ████████╗███████╗ ██████╗██╗  ██╗		
echo                    			[38;2;85;170;0m████╗ ████║██╔═══██╗████╗  ██║╚══██╔══╝██╔════╝██╔════╝ ██╔════╝████╗ ████║    ╚══██╔══╝██╔════╝██╔════╝██║  ██║	
echo                    			[38;2;150;200;100m██╔████╔██║██║   ██║██╔██╗ ██║   ██║   █████╗  ██║  ███╗█████╗  ██╔████╔██║       ██║   █████╗  ██║     ███████║	
echo                    			[38;2;200;230;150m██║╚██╔╝██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██║   ██║██╔══╝  ██║╚██╔╝██║       ██║   ██╔══╝  ██║     ██╔══██║	
echo                    			[38;2;230;250;210m██║ ╚═╝ ██║╚██████╔╝██║ ╚████║   ██║   ███████╗╚██████╔╝███████╗██║ ╚═╝ ██║       ██║   ███████╗╚██████╗██║  ██║	
echo                    			[38;2;255;255;255m╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝       ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝	

set /p KEY=@EnterKey: 

if "%KEY%"=="Tech_2025New_v0.3" (
    cls
    echo.
    echo Loading.
    timeout /t 1 >nul
    cls
    echo Loading..
    timeout /t 1 >nul
    cls
    echo Loading...
    timeout /t 1 >nul
    cls
    echo Injecting.
    timeout /t 1 >nul
    cls
    echo Injecting...
    timeout /t 1 >nul
    cls
    echo Injecting.
    timeout /t 1 >nul
    cls
    echo Settings.
    timeout /t 1 >nul
    cls
    echo Settings..
    timeout /t 1 >nul
    cls
    echo Settings...
    timeout /t 1 >nul
    cls
    echo Settings.
    timeout /t 1 >nul
    cls
    echo Settings..
    timeout /t 1 >nul
    cls
    echo Settings...
    timeout /t 1 >nul
    cls
    echo Injected!
    timeout /t 2 >nul
) else (
    echo.
    echo Invalid Key. Try again later.
    timeout /t 2 >nul
)
exit