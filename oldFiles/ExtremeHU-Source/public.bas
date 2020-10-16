Attribute VB_Name = "PublicVARs"
Public StoredCAM As String
Public StoredCAMLastByte As String
Public HUZKT As String
Public Key12Byte As String
Public PPV_Limit_Change As String
Public PPV_Limit_Current As String
Public bin_file_data(8192) As Byte
Public OriginalBin(8192) As Byte
Public changed As Boolean
Public Key_Byte(8) As String
Public CardKey(8) As String
Public CardKeyString As String
Public CancelError As Boolean
Public TimeOutError As Boolean
Public TransactionLog(2024) As String
Public LogIndex

Declare Function GetTickCount& Lib "kernel32" ()


Public Declare Function GetPrivateProfileString Lib "kernel32" Alias _
        "GetPrivateProfileStringA" (ByVal lpAppName As String, _
        ByVal lpKeyName As Any, ByVal lpDefault As String, _
        ByVal lpReturnedString As String, ByVal nSize As Long, _
        ByVal lpFileName As String) As Long
        
Public Declare Function WritePrivateProfileString Lib "kernel32" Alias _
        "WritePrivateProfileStringA" (ByVal lpAppName As String, _
        ByVal lpKeyName As Any, ByVal lpDefault As String, _
        ByVal lpFileName As String) As Long

Function LoadINI()

Form7.WrtDly.Text = 85
Form7.COMPort_Box.Text = "COM1:"
Form7.AutoAdjust.Value = 0
Form7.GlitchStart_Combo.ListIndex = 0
Form7.GlitchAttempts_txtbox.Text = 7

End Function


Function SendToLog(DataForLog As String)

TransactionLog(LogIndex) = DataForLog
LogIndex = LogIndex + 1

End Function

Function EncryptionNeeded(TestAddr As String) As Boolean
Dim DecAddr As Integer

DecAddr = HexToDec(TestAddr)

If DecAddr >= &H2024 And DecAddr <= &H24BF Then
    EncryptionNeeded = True
    Exit Function
End If

If DecAddr >= &H24C8 And DecAddr <= &H24CB Then
    EncryptionNeeded = True
    Exit Function
End If

If DecAddr >= &H24E0 And DecAddr <= &H2EDF Then
    EncryptionNeeded = True
    Exit Function
End If

If DecAddr >= &H2AD3 And DecAddr <= &H2EDF Then
    EncryptionNeeded = True
    Exit Function
End If

EncryptionNeeded = False

End Function


