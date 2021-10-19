# auto_miner

**Put all files in the same folder before editing or using them**

**You need to edit CHECK+MINE.bat, check.vbs, CHECK_CARDS.bat, and MINING_CONFIG.txt onces CHECK+MINE.bat creates it**

**If any script asks to install .Net 3.5, this is for the powershell script that actually enumerates the cards on the PCI bus**

**CHECK+MINE.bat**
Once all configs are done, you will mine with this batch file

first, edit CHECK+MINE.bat with some computer configs

look for this section:
REM !!!!!! SET THESE FOLDERS !!!!!!
setx miningFolder "C:\stuff\AUTOMINE"
setx ethLargementFolder "C:\Stuff\ETHlargementPill"

This example has everything in folder C:\Stuff but you can put it anywhere, as long as you know the actual path.
Do not use USB or network path
If you use path like desktop, you have to put the REAL folder like
C:\Users\Person\Desktop\Mining_Folder

explanation of folders:

setx miningFolder this is the folder where all these scripts live. MUST put them all in this folder
setx ethLargementFolder folder where you extracted the folder ETHlargementPill-r2 that has ETHlargementPill-r2.exe and everything in it


**MINING_CONFIG.txt**
this file has your configs for claymore miner
at first run of CHECK+MINE.bat, it will create MINING_CONFIG.txt that looks like this:

wallet_address=NULL
miner_name=NULL
email_address=NULL
custom_args=NULL

here is an explanation for each line
wallet_address=NULL  your ETH wallet address for payouts
miner_name=NULL   your rig name for the mining software
email_address=NULL    your email address for nanopool to email you when the rig goes down
custom_args=NULL    all the command line args you want to use that aren't handled by the AUTO-MINER

here is an example of my current config
wallet_address=0x123456789abcdefabcdefabcdef123456789abcd
miner_name=miner_1
email_address=no_one@nothing.com
custom_args=-clKernel 0 -mpsw "my_password" -cdm 2 -cdmport 1234 -cdmpass "my_password" -epsw x -mode 1 -ftime 10 -tstop 85 -tt 80 -fanmin 60

**check.vbs**
this script creates the actual mining batch file every time CHECK+MINE.bat is ran

first, edit check.vbs with some computer settings

look for this section:

' !!!!! SET THESE TWO FOLDERS !!!!!
miningFolder = "C:\stuff\Claymore v15.0"     'folder where claymore EthDcrMiner64.exe is
scriptDir = "C:\stuff\AUTOMINE"              'folder where this script is

I recommend that scriptDir FOLDER lives in side folder with your other scripts for this, it makes everything easier

**CHECK_CARDS.bat**
this script simply shows you what order the GPU's were enumerated on the PCI bus. run at any time to see the order.

change the folder in this batch file:
REM EDIT THIS LINE WITH THE SAME FOLDER YOU SET IN CHECK+MINE.bat as the miningFolder
CD /D "C:\stuff\AUTOMINE"
this HAS to be the same folder as set in CHECK+MINE.bat

**check.bat**
this is a sript that CHECK+MINE.bat and CHECK_CARDS.bat use to enumerate the cards. Do not edit this file.

**check.ps1**
this is a powershell script that check.bat runs





