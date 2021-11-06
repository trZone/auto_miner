Set objWMIService = GetObject("winmgmts:\\localhost\root\CIMV2")

'Set filesys = CreateObject("Scripting.FileSystemObject")
'Set batFile = filesys.CreateTextFile("check_cpu.bat", True)

done = False
sample1 = int(-1)
sample2 = int(-1)
sample3 = int(-1)

Do Until done = True

  X = int(0)
  highest = int(0)
  Do Until X = 3
    Set CPUInfo = objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfOS_Processor",,48) 
    For Each item in CPUInfo 

     If item.PercentProcessorTime > highest Then
       highest = item.PercentProcessorTime
     End If

    Next
  X = X + 1
  Loop

  wscript.echo "CPU Usage: " & highest & chr(37)

  If highest < 50 Then

    If sample1 = -1 Then
      sample1 = highest    
    ElseIf sample2 = -1 Then
      sample2 = highest
    ElseIf sample3 = -1 Then
      sample3 = highest
    End If

  Else

    sample1 = -1
    sample2 = -1
    sample3 = -1

  End If

  If sample1 <> -1 And sample2 <> -1 And sample3 <> -1 Then
    If sample1 < 50 And sample2 < 50 and sample3 < 50 Then
      done = True
    End If
  End If

  wscript.Sleep(3000)

Loop

