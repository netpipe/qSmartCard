Attribute VB_Name = "HUIO"
Public TextToWrite As String
Public RetValue As String
Public ReturnFromLoader As String
Public BytesSent As Integer
Public WRT_Delay As Long
Public Cray_Stop As Boolean
Public ReadTimeOut As Long
Function EncWriteHU(DataToWrite)

Dim DataLength As Integer
Dim Enc_Index As Integer
Dim Packet_Addr As String
Dim Packet_Data As String
Dim Single_Byte As String
Dim Returned_Data As String
Dim EncByte As Integer

Returned_Data = ""

    'Get The starting address for the data
Packet_Addr = Left(DataToWrite, 4)
    'Get the unencrypted data to write
Packet_Data = Mid(DataToWrite, 5)

    'Get the number of bytes to write
DataLength = Len(Packet_Data)
    'Find the correct key_byte for the starting address
Enc_Index = HexToDec(Right(Packet_Addr, 1))
If Enc_Index > 7 Then Enc_Index = inc_index - 8


'MsgBox Decimal_Length & " " & End_Addr & " " & Packet_Addr



For X = 1 To DataLength Step 2
    'get a byte fom the bin data
    Single_Byte = HexToDec(Mid(Packet_Data, X, 2))
    'MsgBox "norm " & Mid(Packet_Data, X, 2)
    EncByte = HexToDec(CardKey(Enc_Index))
    Single_Byte = HexString((Single_Byte Xor EncByte), 2)
    
    Returned_Data = Returned_Data & Single_Byte
    Enc_Index = Enc_Index + 1
    If Enc_Index = 8 Then Enc_Index = 0
Next X
Returned_Data = FormatHUData(Packet_Addr & Returned_Data)
'MsgBox Returned_Data


WriteHU (Returned_Data)

End Function

Function WriteHU(DataToWrite)

Dim ThisByte As Integer
Dim StringToWrite As String
Dim DataBytesToWrite As Integer

DataBytesToWrite = Len(DataToWrite)
StringToWrite = ""

For X = 1 To DataBytesToWrite Step 2
    ThisByte = HexToDec(Mid(DataToWrite, X, 2))
    StringToWrite = StringToWrite & Chr(ThisByte)
Next X

    'write to string to the loader
'Form1.MSComm1.Output = StringToWrite


End Function
Function ReadHU(ReturnBytes)
Dim RXByte As String
Dim RXString As String
Dim RXReturnLength As Integer


RXString = ""
TimeOutError = False
ReadTimeOut = GetTickCount + 2500 'milliseconds

Do While GetTickCount < ReadTimeOut And Form1.MSComm1.InBufferCount < ReturnBytes
DoEvents
Loop

Form1.MSComm1.InputLen = ReturnBytes

    'read the return from the loader
ReturnFromLoader = Form1.MSComm1.Input

RXReturnLength = Len(ReturnFromLoader)

If RXReturnLength = 0 Then
    ReturnFromLoader = Chr("0")
    RXReturnLength = 1
End If
    
    'convert the retrun to txt format
For z = 1 To RXReturnLength
    RXByte = Mid(ReturnFromLoader, z, 1)
    RXString = RXString & HexString(Asc(RXByte), 1)
Next z


DoEvents
ReadHU = RXString

End Function
Function GetByteFromHU(ByteToGet As Integer)
Dim temp1

ByteToGet = ByteToGet + 1
temp1 = Mid(ReturnFromLoader, ByteToGet, 1)
If Len(ReturnFromLoader) < ByteToGet Then temp1 = Chr(0)

GetByteFromHU = Asc(temp1)

End Function


Function FormatHUData(UnformatedData As String)
    'Send unformated data as  AAAADDDDDDDDDDDDDDDD
    'AAAA = Address
    'DDDDDDDDDDDDDDD = Data to write
    
Dim Code1 As String
Dim Code2 As Integer
Dim Code3 As Integer
Dim TmpData As String
Dim LenData As Integer

LenData = Len(UnformatedData) / 2
Code1 = LenData + 3
Code2 = &HC0 + LenData
Code3 = LenData - 2
Code3 = Code3 + &H80 - 1

TmpData = HexString(Code1, 2) & HexString(Code2, 2) & HexString(Code3, 2) & UnformatedData & "00"

FormatHUData = TmpData
End Function

Function LoaderError()
Form1.Text2.Text = "ERROR:  Incorrect Response From Deviece!"
End Function

