Attribute VB_Name = "GetCheckSum"
Function Get_Checksum(Hexdata As String)
    'send data to the function as :XXAAAA00DDDDDDDDDD
    ':    =  A constannt always ":"
    'XX   =  bytes to write (in hex)
    'AAAA =  Address to write to (in hex)
    '00   =  A constant allways 00
    'DD   =  The data to write (number of data bytes must match XX
    'the checsum for that line will be returned

Dim TempHex As String
Dim Hex_Length As Integer
Dim Checksum As Variant


Hex_Length = Len(Hexdata) + 1

For X = 2 To Hex_Length Step 2
TempHex = Mid(Hexdata, X, 2)
Checksum = Checksum + HexToDec(TempHex)
Next X

TempHex = Right(Hex(Checksum), 2)
Checksum = HexToDec(TempHex)
'Checksum = HexString(256 - Checksum, 2)
'If Len(Checksum) < 2 Then Checksum = "0" & Checksum


Get_Checksum = Right(HexString(256 - Checksum, 2), 2)

End Function
