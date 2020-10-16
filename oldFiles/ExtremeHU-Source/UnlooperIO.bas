Attribute VB_Name = "UnlooperIO"
Option Explicit

Function Reset_Unlooper() As String
Dim temp As String
Dim i As Integer
Dim Temp2 As String
Dim temp3 As String



Cray_Stop = False



Form1.Text2.Text = "Reseting Loader/Unlooper"
DoEvents
Form1.MSComm1.PortOpen = False
Form1.MSComm1.Settings = "115200,N,8,1"
WriteDelay
Form1.MSComm1.PortOpen = True
GoTo CommOK

BadComm:
Form1.Text2.Text = "ERROR:  Cant Open " & Form7.COMPort_Box.Text
GoTo EndOfRestUnlooper

CommOK:
' toggle reset line
Form1.MSComm1.DTREnable = True
Form1.MSComm1.SThreshold = 1
WriteDelay
Form1.MSComm1.DTREnable = False
Form1.MSComm1.RTSEnable = True

'clear buffer
ClearBuffer



' get unlooper version
Form1.MSComm1.Output = Chr(&H90)
WriteDelay
temp = Form1.MSComm1.Input


' reset card, set baud rate to 9600
Form1.MSComm1.Output = Chr(&H4) + Chr(&H10) + Chr(1) + Chr(&H9B) + Chr(0)
WriteDelay
ClearBuffer

Form1.Text2.Text = "Reset Complete.     ATMEL Code: " & temp

DoEvents
Reset_Unlooper = temp
EndOfRestUnlooper:
End Function

Function WriteDelay()


WRT_Delay = Form7.WrtDly.Text
'WRT_Delay = 80 ms

WRT_Delay = WRT_Delay + GetTickCount
DoEvents

Do
'DoEvents
' wait for unlooper to start sending data
Loop Until GetTickCount > WRT_Delay
End Function

Function WDTMR()
Dim RetValue As Integer
            
WriteHU ("05150E108000")
ReadHU (2)
  RetValue = GetByteFromHU(&H1)
  ReadHU (RetValue)

End Function

Function IsCardPresent()
Dim CardStat As String

WriteHU ("80")


CardStat = ReadHU(1)
If Len(CardStat) = 0 Then CardStat = "00"
IsCardPresent = CardStat
DoEvents
End Function

Function CheckLoader()

If Reset_Unlooper = "" Then
    CheckLoader = False
    Form1.Text2.Text = "ERROR:  No Programmer Found On " & Form7.COMPort_Box.Text
    Else: CheckLoader = True
End If

End Function
Function ClearBuffer()
Dim Trash As String
Form1.MSComm1.InputLen = 256

Trash = Form1.MSComm1.Input
WriteDelay
End Function

Function CloseLoader()

WriteHU ("A0")
WriteHU ("020200")
ReadHU (2)
End Function

