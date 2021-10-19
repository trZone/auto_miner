
' !!!!! SET THESE TWO FOLDERS !!!!!
miningFolder = "C:\stuff\Claymore v15.0"     'folder where claymore EthDcrMiner64.exe is
scriptDir = "C:\stuff\AUTOMINE"              'folder where this script is


Dim gpuConfigsDir, miningConfigFile
gpuConfigsDir = scriptdir & "\GPU_CONFIGS"
gpuIndividualCardsConfigsDir = scriptdir & "\GPU_CONFIGS\INDIVIDUAL_CARDS"
miningConfigFile = scriptdir & "\MINING_CONFIG.txt"

Dim wallet_address, miner_name, email_address, custom_args

If WScript.Arguments.Count > 0 Then
  method = WScript.Arguments.Item(0)
  method = lCase(method)
End If


  Set gpuTypes = CreateObject("System.Collections.ArrayList")

  Dim method, filesys
  Set filesys = CreateObject("Scripting.FileSystemObject")


 If filesys.FileExists(scriptdir & "\MINE\halt.txt") then
   filesys.DeleteFile(scriptdir & "\MINE\halt.txt")
 End If

 If method = "mine" Then

    If Not filesys.FolderExists(scriptdir & "\MINE") Then
      filesys.CreateFolder(scriptdir & "\MINE")
    End If

    If Not filesys.FolderExists(gpuConfigsDir) Then
      filesys.CreateFolder(gpuConfigsDir)
    End If


    If Not filesys.FolderExists(gpuIndividualCardsConfigsDir) Then
      filesys.CreateFolder(gpuIndividualCardsConfigsDir)
    End If



    If Not filesys.FileExists(miningConfigFile) Then

      makeTheMiningConfigFile()

      result = readTheMiningConfigFile()

    Else
      result = readTheMiningConfigFile()
    End If


     If result <> "COMPLETE" Then

         Set fileTxt = filesys.CreateTextFile(scriptdir & "\MINE\halt.txt", True)
         filetxt.WriteLine(result)
         filetxt.Close()
         Set fileTxt = Nothing

         wscript.echo()
         wscript.echo()

         wscript.echo "!!!!!!! **************************************** !!!!!!!"
         wscript.echo result
         wscript.echo()
         wscript.echo vbTab & "Please configure settings in this file:"
         wscript.echo vbTab & miningConfigFile
         wscript.echo vbTab & "REQUIRED: wallet_address=YOUR ETHEREUM WALLET ADDRESS"
         wscript.echo vbTab & "REQUIRED: miner_name=YOUR MINER's NAME YOU COME UP WITH"
         wscript.echo vbTab & "REQUIRED: email_address=YOUR EMAIL ADDRESS TO RECEIVE NOTIFICATIONS"
         wscript.echo vbTab & "OPTIONAL: custom_args=CUSTOM ARGUMENTS TO ADD TO EthDcrMiner64.exe"
         wscript.echo "!!!!!!! **************************************** !!!!!!!"

         wscript.echo()
         wscript.echo()

      End If



    If filesys.FileExists(scriptdir & "\MINE\AUTO_MINE.bat.old.txt") Then

      filesys.DeleteFile(scriptdir & "\MINE\AUTO_MINE.bat.old.txt")

    End If

    If filesys.FileExists(scriptdir & "\MINE\AUTO_MINE.bat") Then
      filesys.MoveFile scriptdir & "\MINE\AUTO_MINE.bat", scriptDir & "\MINE\AUTO_MINE.bat.old.txt"
    End If

  End If



  Dim rxboost, cclock, mclock, powlim, cvddc, mvddc

  rxboost = "-"
  cclock = "-"
  mclock = "-"
  powlim = "-"
  cvddc = "-"
  mvddc = "-"


Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_VideoController",,48)

Set fileCards = filesys.CreateTextFile(scriptdir & "\cards_found.txt", True)

X = int(1)
For Each objItem in colItems

  Wscript.Echo X & ": " & objItem.Caption
  wscript.echo vbTab & objItem.AdapterDACType
  isInArray = False
  For Each item In gpuTypes
    If item = objItem.Caption Then
      isInArray = True
    End If
  Next

  fileCards.WriteLine()
  fileCards.WriteLine(X & " :" & objItem.Caption)
  fileCards.WriteLine(vbTab & "AdapterDACType:" & vbTab & objItem.AdapterDACType)
  fileCards.WriteLine(vbTab & "PNPDeviceID:" & vbTab & objItem.PNPDeviceID)
  fileCards.WriteLine(vbTab & "Description:" & vbTab & objItem.Description)
  fileCards.WriteLine(vbTab & "Status:" & vbTab & objItem.Status)
  fileCards.WriteLine(vbTab & "DeviceID:" & vbTab & objItem.DeviceID)
  fileCards.WriteLine(vbTab & "AdapterRAM:" & vbTab & objItem.AdapterRAM)

  If isInArray = False And objItem.AdapterDACType <> "Internal" Then
    gpuTypes.Add objItem.Caption
  End If


'wscript.echo vbTab & "PNPDeviceID: " & objItem.PNPDeviceID
'wscript.echo vbTab & "Description: " & objItem.Description

X = X + 1
Next
fileCards.Close()



wscript.echo()
wscript.echo()


'====================================================================================



wscript.echo "Checking..."
Set objShell = WScript.CreateObject("WScript.Shell")
objShell.Run "check.bat", 0, 1


Set powershellGPUs = CreateObject("System.Collections.ArrayList")

Set objFile = filesys.OpenTextFile("check.txt", 1)


thisDeviceDesc = "NULL"
thisLocationInfo = "NULL"
thisPCIbus = "NULL"
thisDeviceInfo = "NULL"
thisHexSerial = "NULL"

Do Until objFile.AtEndOfStream
  strLine = objFile.ReadLine

  If Left(strLine, 7) = "keyName" Then

    Y = inStr(strLine, "data")

  End If

  If Left(strLine, 25) = "DEVPKEY_Device_DeviceDesc" Then
    thisDeviceDesc = Trim(Mid(strLine, Y, len(strLine)))
  End If

  If Left(strLine, 27) = "DEVPKEY_Device_LocationInfo" Then
    thisLocationInfo = Trim(Mid(strLine, Y, len(strLine)))

    parts = Split(thisLocationInfo, ",", 2)

    thisPCIbus = Mid(parts(0), 9)
    If Len(thisPCIbus) = 1 Then
      thisPCIbus = "0" & thisPCIbus
    End If

  End If


  If Left(strLine, 25) = "DEVPKEY_Device_InstanceId" Then
    thisDeviceInfo = Trim(Mid(strLine, Y, len(strLine)))

    parts = Split(thisDeviceInfo, "\")

    parts2 = Split(parts(2), "&")

    thisHexSerial = parts2(1)

    isInArray = False
    For Each item In gpuTypes
      If item = thisDeviceDesc Then
        isInArray = True
      End If
    Next

    If isInArray = True Then
      powershellGPUs.Add thisPCIbus & "|" & thisDeviceDesc & "|" & thisHexSerial
    End If

    thisDeviceDesc = "NULL"
    thisLocationInfo = "NULL"
    thisPCIbus = "NULL"

  End If


Loop

powershellGPUs.Sort

  X = int(0)
  For Each item In powershellGPUs

    X = X + 1

    sayX = Cstr(X)
    If Len(sayX) = 1 Then
      sayX = "0" & sayX
    End If

    parts = Split(item, "|")
    thisPCIbus = parts(0)
    thisDescription = parts(1)
    thisHexSerial = parts(2)

    If Mid(thisPCIbus, 1,1) = "0" Then

      thisPCIbus = mid(thisPCIbus, 2)
    End If

'    wscript.echo "GPU" & X & ":" & item
    wscript.echo "GPU" & X & ": " & thisDescription & "|" & thisHexSerial & " " & chr(40) & "pcie " & thisPCIbus & chr(41)


    If method = "mine" Then

      If Not filesys.FileExists(gpuIndividualCardsConfigsDir & "\" & thisDescription & "_" & thisHexSerial & ".txt") Then

        return = setupMiningForCard(thisDescription, thisHexSerial)
      End If

      useIndividual = setupMiningForCard(thisDescription, "NA")


      If useIndividual = True Then

        return = setupMiningForCard(thisDescription, thisHexSerial)

      End If


    End If

  Next

wscript.echo()
wscript.echo()

If method = "mine" Then

  If X = 0 Then
    wscript.echo()
    wscript.echo "********** THERE ARE NO AVAILABLE GPU's TO MINE **********"
    wscript.echo "**********    not creating AUTO_MINE.bat        **********"
    wscript.echo()
    wscript.quit()
  End If


  rxboost = Mid(rxBoost, 3)
  cclock = Mid(cclock, 3)
  mclock = Mid(mclock, 3)
  powlim = Mid(powlim, 3)
  cvddc = Mid(cvddc, 3)
  mvddc = Mid(mvddc, 3)

  cardArgs = "-rxboost " & rxboost & " -cclock " & cclock & " -mclock " & mclock & " -powlim " & powlim & " -cvddc " & cvddc & " -mvddc " & mvddc

  miningFile = scriptdir & "\MINE\AUTO_MINE.bat"

  Set mineTxt = filesys.CreateTextFile(miningFile, True)

  putCustom_Args = " "
  If custom_args <> "NULL" Then
    putCustom_Args = custom_args

    putCustom_Args = Replace(putCustom_Args, chr(34), chr(34) & chr(34))
    putCustom_Args = " " & putCustom_Args & " "
  End If

'  minetxt.WriteLine(chr(34) & miningFolder & "\EthDcrMiner64.exe"" -epool eth-us-east1.nanopool.org:9999 -ewal " & wallet_address & "." & miner_name & "/" & email_address & " -eworker " & miner_name & " -mpsw ""closer123"" -cdm 2 -cdmport 1025 -cdmpass ""closer123"" -epsw x -mode 1 -ftime 10 -tstop 85 -tt 80 -fanmin 60 " & cardArgs)

  minetxt.WriteLine(chr(34) & miningFolder & "\EthDcrMiner64.exe"" -epool eth-us-east1.nanopool.org:9999 -ewal " & wallet_address & "." & miner_name & "/" & email_address & " -eworker " & miner_name & putCustom_Args & cardArgs)

  minetxt.Close

End If


Function setupMiningForCard(cardDescription, hexSerial)



  cardFile = "NULL"
  setupMiningForCard = False

  If hexSerial = "NA" Then
    cardFile = gpuConfigsDir & "\" & cardDescription & ".txt"
  Else
    cardFile = gpuIndividualCardsConfigsDir & "\" & cardDescription & "_" & hexSerial & ".txt"
  End If



  makeThisFile = "FALSE"

  thisUseIndividualConfigs = "NULL"
  thisRxboost = "NULL"
  thisCvddc = "NULL"
  thisMvddc = "NULL"
  thisPowlim = "NULL"
  thisCclock = "NULL"
  thisMclock = "NULL"


  If Not filesys.FileExists(cardFile) Then

    makeThisFile = "NEW"

    thisUseIndividualConfigs = "False"
    thisRxboost = "0"
    thisCvddc = "0"
    thisMvddc = "0"
    thisPowlim = "0"
    thisCclock = "0"
    thisMclock = "0"

  Else

    Set objFile = filesys.OpenTextFile(cardFile, 1)

    Do Until objFile.AtEndOfStream
      strLine = objFile.ReadLine

      If instr(strLine, "=") Then

        parts = Split(strLine, "=", 2)
        parts(0) = lCase(parts(0))

        Select Case parts(0)
        Case "useindividualconfigs"
          If lCase(parts(1)) = "true" Then
            thisUseIndividualConfigs = True
            setupMiningForCard = True

          Else
            thisUseIndividualConfigs = False
            setupMiningForCard = False
          End If
        Case "rxboost"
          thisRxboost = parts(1)
        Case "cvddc"
          thisCvddc = parts(1)
        Case "mvddc"
          thisMvddc = parts(1)
        Case "powlim"
          thisPowlim = parts(1)
        Case "cclock"
          thisCclock = parts(1)
        Case "mclock"
          thisMclock = parts(1)
        End Select
      End If

    Loop

    'Don't write this paramater to file for individual cards
    If hexSerial <> "NA" Then
      thisUseIndividualConfigs = False
    End If

  End If

  parmsToAdd = int(0)



  If thisUseIndividualConfigs = "NULL" Then
    parmsToAdd = parmsToAdd + 1
    wscript.Echo vbTab & "Missing paramater: useIndividualConfigs"
    makeThisFile = True
    thisUseIndividualConfigs = "False"
  End If
  If thisRxboost = "NULL" Then
    parmsToAdd = parmsToAdd + 1
    wscript.Echo vbTab & "Missing paramater: rxboost"
    makeThisFile = True
    thisRxboost = "0"
  End If
  If thisCvddc = "NULL" Then
    parmsToAdd = parmsToAdd + 1
    wscript.Echo vbTab & "Missing paramater: cvddc"
    makeThisFile = True
    thisCvddc= "0"
  End If
  If thisMvddc = "NULL" Then
    parmsToAdd = parmsToAdd + 1
    wscript.Echo vbTab & "Missing paramater: mvddc"
    makeThisFile = True
    thisMvddc = "0"
  End If
  If thisPowlim = "NULL" Then
    parmsToAdd = parmsToAdd + 1
    wscript.Echo vbTab & "Missing paramater: powlim"
    makeThisFile = True
    thisPowlim = "0"
  End If
  If thisCclock = "NULL" Then
    parmsToAdd = parmsToAdd + 1
    wscript.Echo vbTab & "Missing paramater: cclock"
    makeThisFile = True
    thisCclock = "0"
  End If
  If thisMclock = "NULL" Then
    parmsToAdd = parmsToAdd + 1
    wscript.Echo vbTab & "Missing paramater: mclock"
    makeThisFile = True
    thisMclock = "0"
  End If




  If makeThisFile <> "FALSE" Then

    Set fileTxt = filesys.CreateTextFile(cardFile, True)

    If makeThisFile = "TRUE" Then
      wscript.Echo vbTab & "config file created"
    ElseIf parmsToAdd = 1 Then
      wscript.Echo vbTab & "1 paramater added to file"
    ElseIf parmsToAdd > 1 Then
      wscript.Echo vbTab & parmsToAdd & " paramaters added to file"
    End If

    If hexSerial = "NA" Then
      filetxt.WriteLine("useIndividualConfigs=" & thisUseIndividualConfigs)
    End If

    filetxt.WriteLine("rxboost=" & thisRxboost)
    filetxt.WriteLine("cvddc=" & thisCvddc)
    filetxt.WriteLine("mvddc=" & thisMvddc)
    filetxt.WriteLine("powlim=" & thisPowlim)
    filetxt.WriteLine("cclock=" & thisCclock)
    filetxt.WriteLine("mclock=" & thisMclock)

    filetxt.Close()

  End If

If thisUseIndividualConfigs <> True Then

  rxboost = rxboost & "," & thisRxboost
  cvddc = cvddc & "," & thisCvddc
  mvddc = mvddc & "," & thisMvddc
  powlim = powlim & "," & thisPowlim
  cclock = cclock & "," & thisCclock
  mclock = mclock & "," & thisMclock

End If

End Function

Sub makeTheMiningConfigFile()

   Set fileTxt = filesys.CreateTextFile(miningConfigFile, True)

   filetxt.WriteLine("wallet_address=NULL") 'required
   filetxt.WriteLine("miner_name=NULL") 'required
   filetxt.WriteLine("email_address=NULL") 'required
   filetxt.WriteLine("custom_args=NULL") 'optional

   filetxt.Close()

End Sub

Function readTheMiningConfigFile()


 Set readConfigFile = filesys.OpenTextFile(miningConfigFile, 1)

  wallet_address = "NULL"
  miner_name = "NULL"
  email_address= "NULL"
  custom_args = "NULL"

  Do Until readConfigFile.AtEndOfStream
    strLine = readConfigFile.ReadLine

      If instr(strLine, "=") Then

        parts = Split(strLine, "=", 2)
        parts(0) = lCase(parts(0))

        Select Case parts(0)
        Case "wallet_address"      'required
          wallet_address = parts(1)
        Case "miner_name"          'required
          miner_name = parts(1)
        Case "email_address"       'required
          email_address = parts(1)
        Case "custom_args"         'optional
          custom_args = parts(1)

        End Select
      End If

  Loop
  readConfigFile.Close()
  Set readConfigFile = Nothing

  errorsX = int(0)

  If wallet_address = "NULL" Then
    errorsX = errorsX + 1
    errorMessage = errorMessage & " wallet_address"
  End If
  If miner_name = "NULL" Then
    errorsX = errorsX + 1
    errorMessage = errorMessage & " miner_name"
  End If
  If email_address = "NULL" Then
    errorsX = errorsX + 1
    errorMessage = errorMessage & " email_address"
  End If

  If errorsX = 1 Then
    readTheMiningConfigFile = vbTab & "Cannot mine. Required configuration is missing:" & vbCrlf & vbTab & Mid(errorMessage, 2)
  ElseIf errorsX > 1 Then
    readTheMiningConfigFile = vbTab & "Cannot mine. Required configurations are missing: " & vbCrlf & vbTab & Mid(errorMessage, 2)
  ElseIf errorxX = 0 Then
    readTheMiningConfigFile = "COMPLETE"
  End If


End Function
