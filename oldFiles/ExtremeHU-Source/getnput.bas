Attribute VB_Name = "GetnPut"


Function Put_Bin_Data(BIN_Packet As String)
'This Function will chage data of the bin with the specified Packet.
'Packet must be setup as follows XXYYAAAA  DDDDDDDDDDDDDDD
'where XX=number of bytes to be changed
'      YY=00-no encryption  01-use encryption
'    AAAA=starting address
' DDDDDDD=the actual data to change.
'The bin data must be in an array as bin_file_data(8192)

Dim Data_Length As String
Dim Decimal_Length As Integer
Dim Enc_Check As Boolean
Dim Enc_Index As Integer
Dim Packet_Addr As String
Dim Data_to_Put As String
Dim End_Addr As Integer
Dim Single_Byte As String

    'Get the number of bytes to change
Data_Length = Left(BIN_Packet, 2)
Decimal_Length = HexToDec(Data_Length)
    'Check to see if encryption has been reqested
If Mid(BIN_Packet, 4, 1) = "1" Then
    Enc_Check = True
    Else: Enc_Check = False
End If
    'Get The starting address for the data
Packet_Addr = Mid(BIN_Packet, 5, 4)

    'Find the correct key_byte for the starting address
Enc_Index = HexToDec(Right(Packet_Addr, 1))
Enc_Index = Enc_Index + 1
If Enc_Index > 8 Then Enc_Index = Enc_Index - 8
    'Convert the address to decimal for the bin format
Packet_Addr = HexToDec(Packet_Addr) - 8191
End_Addr = Packet_Addr + Decimal_Length
    'Get the data to change
Data_to_Put = Mid(BIN_Packet, 11, Decimal_Length * 2)


i = 1
For X = Packet_Addr To End_Addr - 1

Single_Byte = HexToDec(Mid(Data_to_Put, i, 2))

If Enc_Check = True Then Single_Byte = Single_Byte Xor HexToDec(Key_Byte(Enc_Index))
bin_file_data(X) = Single_Byte

i = i + 2
Enc_Index = Enc_Index + 1
If Enc_Index = 9 Then Enc_Index = 1
Next X


End Function

Function Get_BIN_Data(BIN_Packet)
' bin_packet=xxyyaaaa
'xx = number of bytes to get
'yy =00 no encryption  01= use encryption
'aaaa =  starting address


Dim Data_Length As String
Dim Decimal_Length As Integer
Dim Enc_Check As Boolean
Dim Enc_Index As Integer
Dim Packet_Addr As String
Dim Returned_Data As String
Dim End_Addr As Integer
Dim Single_Byte As String

Returned_Data = ""
    'Get the number of bytes to change
Data_Length = Left(BIN_Packet, 2)
Decimal_Length = HexToDec(Data_Length)
    'Check to see if encryption has been reqested
If Mid(BIN_Packet, 4, 1) = "1" Then
    Enc_Check = True
    Else: Enc_Check = False
End If
    'Get The starting address for the data
Packet_Addr = Mid(BIN_Packet, 5, 4)

    'Find the correct key_byte for the starting address
Enc_Index = HexToDec(Right(Packet_Addr, 1))
Enc_Index = Enc_Index + 1
If Enc_Index > 8 Then Enc_Index = Enc_Index - 8
    'Convert the address to decimal for the bin format
Packet_Addr = HexToDec(Packet_Addr) - 8191
End_Addr = Packet_Addr + Decimal_Length - 1

'MsgBox Decimal_Length & " " & End_Addr & " " & Packet_Addr



For X = Packet_Addr To End_Addr
    'get a byte fom the bin data
Single_Byte = Hex(bin_file_data(X))
    'make sure its 2 hex digits long
If Len(Single_Byte) < 2 Then Single_Byte = "0" & Single_Byte
    'check to see of we need to unencode
If Enc_Check = True Then
    Single_Byte = Hex(HexToDec(Single_Byte) Xor HexToDec(Key_Byte(Enc_Index)))
        If Len(Single_Byte) < 2 Then Single_Byte = "0" & Single_Byte
    Returned_Data = Returned_Data & Single_Byte
    Else: Returned_Data = Returned_Data & Single_Byte
End If
    
Enc_Index = Enc_Index + 1
If Enc_Index = 9 Then Enc_Index = 1
Next X

Get_BIN_Data = Returned_Data
End Function

Function TierMonthText(Tiermonth As Integer)

Select Case Tiermonth
Case 0
    TierMonthText = "Jan"
Case 2
    TierMonthText = "Feb"
Case 3
    TierMonthText = "Mar"
Case 4
    TierMonthText = "Apr"
Case 5
    TierMonthText = "May"
Case 6
    TierMonthText = "Jun"
Case 7
    TierMonthText = "Jul"
Case 8
    TierMonthText = "Aug"
Case 9
    TierMonthText = "Sep"
Case 10
    TierMonthText = "Oct"
Case 11
    TierMonthText = "Nov"
Case 12
    TierMonthText = "Dec"
Case Else
    TierMonthText = "???"
End Select

End Function

