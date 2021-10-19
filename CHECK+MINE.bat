@ECHO OFF
REM Pause

REM !!!!!! SET THESE FOLDERS !!!!!!
setx miningFolder C:\stuff\AUTOMINE
setx ethLargementFolder C:\Stuff\ETHlargementPill

REM ***** MAKE THE AUTO-MINER BATCH FILE ******************************

CD /D "%miningFolder%"
cscript /NOLOGO check.vbs "mine"

IF NOT EXIST "%miningFolder%\MINE" MKDIR "%miningFolder%\MINE"

IF NOT EXIST "%miningFolder%\MINE\halt.txt" GOTO noHalt

PAUSE
EXIT

:noHalt


REM ***** Kill existing EthlargmentPill if running *******************
TASKKILL /F /FI "imagename eq ETHlargementPill*"

REM ***** WAIT A LITTLE BIT ******************************************
ECHO waiting 30 seconds...
ping -n 30 127.0.0.1>NUL

ECHO Waiting for CPU to go under 50%% utilization...
cscript.exe /NOLOGO check_cpu.vbs


REM ***** Start EthlargmentPill **************************************
CD /D "%ethLargementFolder%\ETHlargementPill-r2"

REM > start.vbs ECHO Set objShell = WScript.CreateObject("WScript.Shell")
REM >>start.vbs ECHO objShell.Run "ETHlargementPill-r2.exe", 2, 0 
wscript start.vbs

setx GPU_FORCE_64BIT_PTR 0
setx GPU_MAX_HEAP_SIZE 100
setx GPU_USE_SYNC_OBJECTS 1
setx GPU_MAX_ALLOC_PERCENT 100
setx GPU_SINGLE_ALLOC_PERCENT 100



REM ***** RUN THE AUTO-MINER BATCH FILE *******************************

CD /D "C:\stuff\AUTOMINE\MINE"

CALL "AUTO_MINE.bat"

CD /d "C:\stuff\AUTOMINE"

CALL "CHECK+MINE.bat"

