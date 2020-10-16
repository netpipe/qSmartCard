Attribute VB_Name = "GetCAMLastDigit"
Function GetFullCAM(HexCamID As String)
Dim IntCamID, Index, Digit, CAMCheckSum
IntCamID = Right("00000000000" & HexToDec(HexCamID), 11)
CAMCheckSum = 0
For Index = 1 To 11
Digit = Mid(IntCamID, Index, 1)
If (Index Mod 2) = 1 Then
    Digit = Digit * 2
    If Digit >= 10 Then
        Digit = Digit - 9
    End If
End If
CAMCheckSum = CAMCheckSum + Digit
Next
Digit = 10 - (CAMCheckSum Mod 10)
If Digit = 10 Then
Digit = 0
End If
GetFullCAM = IntCamID & Digit
End Function

