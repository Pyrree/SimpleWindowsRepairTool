#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Restart script as admin, cred: ( https://www.autohotkey.com/boards/viewtopic.php?t=63535 )

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

;MsgBox A_IsAdmin: %A_IsAdmin%`nCommand line: %full_command_line%

;Windows Version check
Gui, Submit, NoHide
GetCurV := ComObjCreate("WScript.Shell").Exec("Reg Query ""HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"" /v ReleaseId").StdOut.Readall()
ReleaseID := SubStr(GetCurV, 95, 4)


;Status View
Gui, Font, s9
Gui, Add, text,  x15 y20, OS Version: 
Gui, Add, text,  x15 y40, OS ReleaseID: %ReleaseID%
;Gui, add, Button, x15 y90 w20 h20 gFileCheck, ⭮

;Repair buttons
;Gui, Add, Button, gTestButton x200 y60 w90 h30, Test
Gui, Add, Button, gRWin x316 y10 w90 h30,  Repair Windows
Gui, Add, Button, gRUp x316 y40 w90 h30, Repair Updates

;Log output
Gui, Add, Groupbox, x10 y120 w400 h50, Log file output
Gui, Add, Edit, x15 y140 w300 h20 vSelect1, %A_ScriptDir%\
Gui, Add, Button, gBrowseLogFileFolder x316 y140 w90 h20 v1, Choose Folder
Gui, Show, w440 h180, Simple Windows Repair Tool v0.2.0
return

TestButton:
Gui, Submit, NoHide
getOSname := ComObjCreate("WScript.Shell").Exec("echo wmic os get Caption /value").StdOut.Readall()
OSname := SubStr(getOSname, 15, 20)
MsgBox, %OSname%
return

RWin:
SetTitleMatchMode, 2
;******* DISM *******
if FileExist(A_ScriptDir "\DISM.bat")
{	
	FileDelete, %A_ScriptDir%\DISM.bat
}

FileAppend,
(
@Echo off
Title DISM repair
DISM.exe /Online /Cleanup-image /Restorehealth
pause
exit
), %A_ScriptDir%\DISM.bat
RunWait, %A_ScriptDir%\DISM.bat

;******* SFC *******
if FileExist(A_ScriptDir "\sfc.bat")
{	
	FileDelete, %A_ScriptDir%\sfc.bat
}

FileAppend,
(
@Echo off
title SFC repair
sfc /scannow
pause
exit
), %A_ScriptDir%\sfc.bat
RunWait, %A_ScriptDir%\sfc.bat
return

RUp:
MsgBox,, Info, This does nothing yet.
return

BrowseLogFileFolder:
FileSelectFolder, LogFolder, , , Choose Folder
GuiControl,,Select%A_GuiControl%,%LogFolder%
if (LogFolder == "")
{
	GuiControl,,Select%A_GuiControl%,%A_ScriptDir%\
}
return

GuiClose:
ExitApp