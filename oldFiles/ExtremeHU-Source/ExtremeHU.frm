VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Object = "{5E9E78A0-531B-11CF-91F6-C2863C385E30}#1.0#0"; "MSFLXGRD.OCX"
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSCOMM32.OCX"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "#DSSTech  -  Extreme HU    Version 1.1"
   ClientHeight    =   6480
   ClientLeft      =   45
   ClientTop       =   615
   ClientWidth     =   9795
   ForeColor       =   &H00000000&
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   6480
   ScaleWidth      =   9795
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton ChangeLoaderSettings 
      Caption         =   "Change Loader Settings"
      Height          =   375
      Left            =   2940
      TabIndex        =   0
      Top             =   6000
      Width           =   2040
   End
   Begin VB.CommandButton CraysStopButton 
      Caption         =   "Stop Glitching"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2940
      TabIndex        =   1
      Top             =   6000
      Visible         =   0   'False
      Width           =   2025
   End
   Begin VB.CheckBox Check1 
      Caption         =   "View Decoded EEPROM"
      Height          =   255
      Left            =   120
      TabIndex        =   40
      Top             =   6060
      Width           =   2295
   End
   Begin VB.TextBox ATR_Textbox 
      BackColor       =   &H8000000F&
      ForeColor       =   &H00008000&
      Height          =   285
      Left            =   1320
      Locked          =   -1  'True
      MousePointer    =   1  'Arrow
      TabIndex        =   35
      ToolTipText     =   "Good ATR = 3F 7F 13 25 03 38 B0 04 FF FF 4A 50 00 00 29 48 55 5X 00 00"
      Top             =   465
      Width           =   4845
   End
   Begin VB.Frame Frame3 
      Height          =   15
      Left            =   0
      TabIndex        =   30
      Top             =   0
      Width           =   9855
   End
   Begin VB.Frame Frame1 
      Caption         =   "PPV Purchase Info"
      Height          =   855
      Left            =   6480
      TabIndex        =   20
      Top             =   4950
      Width           =   3135
      Begin VB.Label slot2Limit_label 
         Caption         =   "$0.00"
         Height          =   255
         Left            =   2160
         TabIndex        =   29
         Top             =   480
         Width           =   855
      End
      Begin VB.Label slot1Limit_label 
         Caption         =   "$0.00"
         Height          =   255
         Left            =   2160
         TabIndex        =   28
         Top             =   720
         Visible         =   0   'False
         Width           =   735
      End
      Begin VB.Label slot2Purch_label 
         Caption         =   "$0.00"
         Height          =   255
         Left            =   960
         TabIndex        =   27
         Top             =   480
         Width           =   855
      End
      Begin VB.Label slot1Purch_label 
         Caption         =   "$0.00"
         Height          =   255
         Left            =   960
         TabIndex        =   26
         Top             =   720
         Visible         =   0   'False
         Width           =   855
      End
      Begin VB.Label Label13 
         Caption         =   "Slot"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   -1  'True
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   25
         Top             =   240
         Width           =   495
      End
      Begin VB.Label Label12 
         Caption         =   "Limit"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   -1  'True
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   2160
         TabIndex        =   24
         Top             =   240
         Width           =   615
      End
      Begin VB.Label Label11 
         Caption         =   "Purchased"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   -1  'True
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   960
         TabIndex        =   23
         Top             =   240
         Width           =   975
      End
      Begin VB.Label Label10 
         Caption         =   "Slot 1"
         Height          =   255
         Left            =   120
         TabIndex        =   22
         Top             =   480
         Width           =   615
      End
      Begin VB.Label Label9 
         Caption         =   "Slot 1"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   720
         Visible         =   0   'False
         Width           =   735
      End
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Exit"
      Height          =   375
      Left            =   7560
      TabIndex        =   7
      Top             =   6000
      Width           =   975
   End
   Begin VB.Frame Frame2 
      Caption         =   "EEPROM Info"
      Height          =   4335
      Left            =   6480
      TabIndex        =   2
      Top             =   480
      Width           =   3135
      Begin VB.ComboBox Ratings_Textbox 
         BackColor       =   &H8000000F&
         Height          =   315
         ItemData        =   "ExtremeHU.frx":0000
         Left            =   1200
         List            =   "ExtremeHU.frx":001F
         MousePointer    =   1  'Arrow
         TabIndex        =   34
         Top             =   1440
         Width           =   1815
      End
      Begin VB.TextBox xor_key_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   32
         Top             =   3600
         Width           =   1815
      End
      Begin VB.TextBox Guide_Byte_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         MaxLength       =   2
         TabIndex        =   19
         ToolTipText     =   "To change the guide byte, enter the new guide byte here."
         Top             =   1800
         Width           =   1815
      End
      Begin VB.TextBox USW_TextBox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   17
         Top             =   2160
         Width           =   1815
      End
      Begin VB.TextBox zipcode_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         MaxLength       =   5
         TabIndex        =   15
         ToolTipText     =   "To change zip code enter the new zip here."
         Top             =   2880
         Width           =   1815
      End
      Begin VB.ComboBox timezone_combo 
         BackColor       =   &H8000000F&
         Height          =   315
         ItemData        =   "ExtremeHU.frx":008D
         Left            =   1200
         List            =   "ExtremeHU.frx":00A3
         MousePointer    =   1  'Arrow
         TabIndex        =   14
         Top             =   2520
         Width           =   1815
      End
      Begin VB.TextBox Fusebytes_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   11
         Top             =   1080
         Width           =   1815
      End
      Begin VB.TextBox IRD_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   10
         Top             =   720
         Width           =   1815
      End
      Begin VB.TextBox CAM_textbox 
         BackColor       =   &H8000000F&
         BeginProperty DataFormat 
            Type            =   0
            Format          =   "0"
            HaveTrueFalseNull=   0
            FirstDayOfWeek  =   0
            FirstWeekOfYear =   0
            LCID            =   1033
            SubFormatType   =   0
         EndProperty
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   8
         Top             =   360
         Width           =   1815
      End
      Begin VB.TextBox password_textbox 
         BackColor       =   &H8000000F&
         BeginProperty DataFormat 
            Type            =   0
            Format          =   "0"
            HaveTrueFalseNull=   0
            FirstDayOfWeek  =   0
            FirstWeekOfYear =   0
            LCID            =   1033
            SubFormatType   =   0
         EndProperty
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MaxLength       =   4
         MousePointer    =   1  'Arrow
         TabIndex        =   6
         Top             =   3240
         Width           =   1815
      End
      Begin VB.Label WP_StatusLabel 
         Alignment       =   2  'Center
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   165
         TabIndex        =   41
         Top             =   3990
         Width           =   2775
      End
      Begin VB.Label Label15 
         Caption         =   "Ratings Limit"
         Height          =   255
         Left            =   120
         TabIndex        =   33
         Top             =   1440
         Width           =   975
      End
      Begin VB.Label Label14 
         Caption         =   "XOR Key"
         Height          =   255
         Left            =   120
         TabIndex        =   31
         Top             =   3600
         Width           =   975
      End
      Begin VB.Label Label8 
         Caption         =   "Guide Byte"
         Height          =   255
         Left            =   120
         TabIndex        =   18
         Top             =   1800
         Width           =   1095
      End
      Begin VB.Label Label6 
         Caption         =   "USW"
         Height          =   255
         Left            =   120
         TabIndex        =   16
         Top             =   2160
         Width           =   855
      End
      Begin VB.Label Label7 
         Caption         =   "Zip Code"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   2880
         Width           =   855
      End
      Begin VB.Label Label5 
         Caption         =   "Fuse Bytes"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   1080
         Width           =   855
      End
      Begin VB.Label Label4 
         Caption         =   "IRD Number"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   720
         Width           =   975
      End
      Begin VB.Label Label3 
         Caption         =   "Password"
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   3240
         Width           =   855
      End
      Begin VB.Label T 
         Caption         =   "Time Zone"
         Height          =   255
         Left            =   120
         TabIndex        =   4
         Top             =   2520
         Width           =   855
      End
      Begin VB.Label C 
         Caption         =   "Card ID"
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   360
         Width           =   855
      End
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   6960
      Top             =   3120
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Frame Frame4 
      Height          =   105
      Left            =   -105
      TabIndex        =   38
      Top             =   210
      Width           =   9960
   End
   Begin MSFlexGridLib.MSFlexGrid MSFlexGrid1 
      Height          =   4875
      Left            =   105
      TabIndex        =   39
      Top             =   1005
      Width           =   6135
      _ExtentX        =   10821
      _ExtentY        =   8599
      _Version        =   393216
      Rows            =   513
      Cols            =   17
      RowHeightMin    =   1
      ForeColor       =   0
      AllowBigSelection=   0   'False
      GridLines       =   0
      ScrollBars      =   2
      Appearance      =   0
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Fixedsys"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin MSCommLib.MSComm MSComm1 
      Left            =   9240
      Top             =   5880
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
   Begin VB.Label Label17 
      Alignment       =   2  'Center
      ForeColor       =   &H00008000&
      Height          =   255
      Left            =   0
      TabIndex        =   37
      Top             =   30
      Width           =   9855
   End
   Begin VB.Label Label16 
      Caption         =   "Simulated ATR:"
      Height          =   255
      Left            =   30
      TabIndex        =   36
      Top             =   480
      Width           =   1215
   End
   Begin VB.Menu File_menu 
      Caption         =   "&File"
      Begin VB.Menu eeprom_open_menu 
         Caption         =   "&Open EEPROM"
      End
      Begin VB.Menu save_as_menu 
         Caption         =   "&Save As"
         Begin VB.Menu Save_Normal_menu 
            Caption         =   "Normal Hex"
         End
         Begin VB.Menu SaveASCII_Menu 
            Caption         =   "ASCII Encoded Hex"
         End
         Begin VB.Menu SaveBinFile_Menu 
            Caption         =   "Bin FIle"
         End
      End
      Begin VB.Menu exit_menu 
         Caption         =   "E&xit"
      End
   End
   Begin VB.Menu View_menu 
      Caption         =   "&View"
      NegotiatePosition=   3  'Right
      Begin VB.Menu atrinfo_menu 
         Caption         =   "&ATR Info"
      End
      Begin VB.Menu humap_munu 
         Caption         =   "HU &Map"
      End
      Begin VB.Menu tierinfo_menu 
         Caption         =   "Tie&r Data"
      End
      Begin VB.Menu view_eeprom 
         Caption         =   "EEPROM Dump"
      End
      Begin VB.Menu MsgWinNoClear_Menu 
         Caption         =   "Message Window"
      End
   End
   Begin VB.Menu eeprom_menu 
      Caption         =   "&EEPROM"
      Begin VB.Menu Clean_EEPROM_Menu 
         Caption         =   "&Clean EEPROM"
      End
      Begin VB.Menu ClearEEP_Pass_menu 
         Caption         =   "Clear &Password"
      End
      Begin VB.Menu Fix_4th_Byte_Menu 
         Caption         =   "Fix &ATR 4th Byte"
      End
      Begin VB.Menu Clear_IRD_Menu 
         Caption         =   "&Unmarry"
      End
      Begin VB.Menu Clean_PPV_Menu 
         Caption         =   "&Wipe PPV"
      End
      Begin VB.Menu patch_hex_file_menu 
         Caption         =   "Patch &HEX File"
      End
      Begin VB.Menu camtools_menu 
         Caption         =   "CAM/&ZKT Tools"
         Begin VB.Menu load_HUCamZkt 
            Caption         =   "&Store CAM/ZKT"
         End
         Begin VB.Menu Write_HUCamZkt 
            Caption         =   "&Patch CAM/ZKT"
         End
         Begin VB.Menu HCamSave_menu 
            Caption         =   "Save Cam/ZKT for &H Card"
         End
      End
   End
   Begin VB.Menu card_io_menu 
      Caption         =   "&Card"
      Begin VB.Menu CheckActualATR_menu 
         Caption         =   "Chec&k ATR"
      End
      Begin VB.Menu CardUtil_Menu 
         Caption         =   "Ut&ilities"
         Begin VB.Menu clean_card_menu 
            Caption         =   "&Clean Card"
            Visible         =   0   'False
         End
         Begin VB.Menu CardClearPass_menu 
            Caption         =   "Clear &Password"
         End
         Begin VB.Menu CardChangeZone_menu 
            Caption         =   "Change Time &Zone"
         End
         Begin VB.Menu Card_Fix4thByte_menu 
            Caption         =   "Fix &ATR 4th Byte"
         End
         Begin VB.Menu CardReadUSW_menu 
            Caption         =   "Read US&W"
         End
         Begin VB.Menu CardUnmarry_menu 
            Caption         =   "&Unmarry"
         End
         Begin VB.Menu RewmoceProtection_Menu 
            Caption         =   "Remove Write &Protection"
            Visible         =   0   'False
         End
      End
      Begin VB.Menu ReadEEP_Menu 
         Caption         =   "&Read Card"
      End
      Begin VB.Menu WriteEEP_Menu 
         Caption         =   "&Write Current EEPROM"
      End
      Begin VB.Menu write_menu 
         Caption         =   "Write"
         Visible         =   0   'False
         Begin VB.Menu WrieHexToCard_menu 
            Caption         =   "Hex File"
         End
      End
   End
   Begin VB.Menu Help_menu 
      Caption         =   "&Help"
      Begin VB.Menu prgramhlp_menu 
         Caption         =   "&Program Help"
      End
      Begin VB.Menu about_menu 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Dim i As Integer
Dim X As Integer
Dim IRD_Number As String
Dim CAM_Number As Long
Dim CAM_Text As String
Dim Time_Zone As String
Dim Time_Zone_Byte As String
Dim HU_Password As String
Dim Patch_File As String
Dim EEPROM_Keya As String
Dim EEPROM_Keyb As String
Dim EEPROM_Key As String
Dim HU_Bin As String
Dim Decrypt_Key As String
Dim encryption_bytes As String
Dim CAM_first4bytes As String
Dim CAM As String
Dim CAM_Encrypted As String
Dim Hex_File As String
Dim CAM_lastbyte As String
Dim ZKT(8) As String
Dim HU_ZKT As String
Dim Output_file As String
Dim Input_file As String
Dim addr As String
Dim data As String
Dim Strip_Data As String
Dim line_input(512) As String
Dim intel_hex(513) As String
Dim Trash As String
Dim DecNumber As Variant
Dim Hexdata As String
Dim Hexnumber As String
Dim check_sum As Variant
Dim encoded_intel_hex(513) As Variant
Dim encoded_byte As Variant
Dim temp1 As String
Dim Temp2 As String
Dim path As String
Dim result As Integer
Dim Bad_ATR As Boolean
Dim BinSaved As Boolean
Dim SavedMsgs(18) As String
Dim CancelError As Boolean



Private Sub about_menu_Click()
Load Form5
Form5.Show 1

End Sub
Private Sub NotInThisBeta()
MsgBox "This feature is not available in this beta release.  Sorry."
End Sub

Private Sub AddProtection_Menu_Click()
Dim ProtectString As String

ProtectString = FormatHUData("38308EDC0A")

SetMsgWin



LoadBootStrap
If CheckForError = True Then Exit Sub
WDTMR
HU_Write (ProtectString)
WriteDelay
ReadHU (2)


End Sub

Private Sub atrinfo_menu_Click()
Load Form3
Form3.Show
End Sub

Private Sub Card_Fix4thByte_menu_Click()

SetMsgWin
LoadBootStrap

If CheckForError = True Then Exit Sub
GetKeysFromCard
    'write 00 00 to 2465
HU_Write ("07C4812465" & CardKey(5) & CardKey(6) & "00")
MSFlexGrid1.TextMatrix(9, 1) = "Fix ATR 4th Byte Operation Complete."

CloseLoader

End Sub

Private Sub CardChangeZone_menu_Click()
Dim NewZone As Integer
Dim NewZoneHex As String

SetMsgWin

Load CardChangeZones
CardChangeZones.Show 1

If CheckForError = True Then Exit Sub
NewZone = HexToDec(Left(CardChangeZones.timezone_combo.Text, 2))


LoadBootStrap
If CheckForError = True Then Exit Sub
GetKeysFromCard
NewZoneHex = HexString(NewZone Xor HexToDec(CardKey(0)), 2)

HU_Write ("06C38024E0" & NewZoneHex & "00")
ReadHU (2)

MSFlexGrid1.TextMatrix(9, 1) = "Time Zone Changed to " & CardChangeZones.timezone_combo.Text
MSFlexGrid1.TextMatrix(10, 1) = "Operation Complete."
DoEvents

CloseLoader


End Sub

Private Sub CardClearPass_menu_Click()

SetMsgWin
LoadBootStrap
If CheckForError = True Then Exit Sub
GetKeysFromCard
    'write encoded 00 00 00 00 to the password
HU_Write ("09C683240C" & CardKey(4) & CardKey(5) & CardKey(6) & CardKey(7) & "00")
ReadHU (2)

MSFlexGrid1.TextMatrix(9, 1) = "Clear Password Operation Complete."

CloseLoader

End Sub

Private Sub CardReadUSW_menu_Click()
Dim CardUSW As String
Dim TempUSW As String

SetMsgWin
LoadBootStrap
If CheckForError = True Then Exit Sub

GetKeysFromCard

    'Get Usw
HU_Write ("06C20124C88100")
TempUSW = Right(ReadHU(4), 2)

CardUSW = HexString(HexToDec(TempUSW) Xor HexToDec(CardKey(2)), 2)
MSFlexGrid1.TextMatrix(9, 1) = "USW = " & CardUSW
MSFlexGrid1.TextMatrix(10, 1) = "Read USW Operation Complete."

CloseLoader
End Sub

Private Sub CardUnmarry_menu_Click()
'NotInThisBeta
'Exit Sub
Dim IRD1 As String
Dim IRD2 As String



SetMsgWin
LoadBootStrap
If CheckForError = True Then Exit Sub

GetKeysFromCard

IRD1 = CardKey(0) & CardKey(1) & CardKey(2) & CardKey(3)
IRD2 = CardKey(4) & CardKey(5) & CardKey(6) & CardKey(7)

HU_Write ("09C6832460" & IRD1 & "00")
ReadHU (2)
Call WDTMR
HU_Write ("09C68324A4" & IRD2 & "00")
ReadHU (2)
MSFlexGrid1.TextMatrix(9, 1) = "Unmarry Operation Complete."


'clean up
CloseLoader


End Sub

Private Sub ChangeLoaderSettings_Click()
Load Form7
Form7.Show 1

End Sub

Private Sub Check1_Click()

Dim dec_addr As Integer
Dim CellData As String
Dim decyrpted_bin_data(8192) As String

Form1.MousePointer = 11

If Check1.Value = 0 Then
    LoadBinData
    Exit Sub
End If

For X = 0 To 8191
    decyrpted_bin_data(X) = Hex(bin_file_data(X + 1))
Next X

For X = &H24 To &H4BF
    dec_addr = &H2000
    dec_addr = dec_addr + X
    decyrpted_bin_data(X) = Get_BIN_Data("0101" & Hex(dec_addr))
Next X

For X = &H4C8 To &H4DB
    dec_addr = &H2000
    dec_addr = dec_addr + X
    decyrpted_bin_data(X) = Get_BIN_Data("0101" & Hex(dec_addr))
Next X

For X = &H4E0 To &H53F
    dec_addr = &H2000
    dec_addr = dec_addr + X
    decyrpted_bin_data(X) = Get_BIN_Data("0101" & Hex(dec_addr))
Next X

For X = &HAD3 To &HEDE
    dec_addr = &H2000
    dec_addr = dec_addr + X
    decyrpted_bin_data(X) = Get_BIN_Data("0101" & Hex(dec_addr))
Next X

i = 0
For X = 1 To 512
    For Y = 1 To 16
    CellData = decyrpted_bin_data(i)
    If Len(CellData) < 2 Then CellData = "0" & CellData
    MSFlexGrid1.CellAlignment = flexAlignLeftCenter
    MSFlexGrid1.TextMatrix(X, Y) = CellData
    i = i + 1
    Next Y
Next X

Form1.MousePointer = 0
End Sub

Private Sub CheckActualATR_menu_Click()
SetMsgWin
If CheckLoader = False Then Exit Sub
Check_HU_ATR
HU_Write ("020200")
HU_Write ("A0")
Form1.MSFlexGrid1.TextMatrix(5, 1) = "ATR Check Complete."

End Sub


Private Sub Clean_EEPROM_Menu_Click()
Clean_EEPROM

End Sub

Private Sub Clean_PPV_Menu_Click()
Clean_PPV
End Sub

Private Sub Clear_IRD_Menu_Click()
Clear_IRD
End Sub

Private Sub Command1_Click()

CommonDialog1.FileName = ""
CommonDialog1.Filter = "All Files (*.*)|*.*|BIN Files (*.BIN)|*.BIN|Text Files (*.TXT)|*.TXT"
CommonDialog1.ShowOpen       'display Open dialog box

If CommonDialog1.FileName = "" Then GoTo End_open_file
file_size = FileLen(CommonDialog1.FileName)

   'chck file size to make sure is the corrct file.
If file_size <> 29184 And file_size <> 8192 Then
    MsgBox CommonDialog1.FileName & "   Does not apear to be a valid EEPROM File."
    GoTo End_open_file
End If


Input_file = CommonDialog1.FileName


If Input_file <> "" Then Enable_Options
If Input_file <> "" And file_size = 29184 Then Read_EEPROM_Text_File
If Input_file <> "" And file_size = 8192 Then Read_BIN_File

End_open_file:
Form1.MousePointer = 0
If Input_file = "" Then Disable_Options
End Sub



Sub Read_EEPROM_Text_File()

i = 1
check_sum = 0
Form1.MousePointer = 11
    'get the input file name that the user selected
'Input_file = Text1.Text

    
Open Input_file For Input As #1
Do Until EOF(1)                                         'Open the file for reading
    Line Input #1, Input_file
    line_input(i) = Input_file
    
    addr = Left(Input_file, 4)                          'pull the address from the input
    data = Right(Input_file, 48)                        'pull the unformated data from input
    
    For X = 1 To 48 Step 3                              'this step removes the spaces from the
        Strip_Data = Strip_Data + Mid(data, X, 2)       'the data.
    Next X
    
    

       'assemble the full line for the output file and compute the checksum
    Hexdata = ":10" & addr & "00" & Strip_Data
    intel_hex(i) = Hexdata & Get_Checksum(Hexdata)
    Pull_EEPInfo
        
    i = i + 1
    Line Input #1, Trash                    'read another line and trash it. Its blank
    Strip_Data = ""                         'clear stip_data
    
Loop

Close #1                                    'close eeprom.txt'
intel_hex(i) = ":00000001FF" 'setup last line of the hex file

    'convert to hex to bin
HexToBIN
    'Display the eeprom info
Display_EEPROM_Info

End Sub
Sub Read_BIN_File()

'Dim bin_file_data(8192) As Byte
Dim addr_counter As Integer
Dim bin_file_index As Integer
Dim ThisByte As String

Form1.MousePointer = 11

bin_file_index = 0
    
Open Input_file For Binary As #1
For i = 1 To 8192
  Get #1, i, bin_file_data(i)

Next i
Close #1
addr_hex = &H2000
For i = 1 To 512
    For X = 1 To 16
        ThisByte = Hex(bin_file_data(bin_file_index + X))
        If Len(ThisByte) < 2 Then ThisByte = "0" & ThisByte
        Strip_Data = Strip_Data & ThisByte
    Next X
    bin_file_index = bin_file_index + 16
    addr = Hex(addr_hex)
    Hexdata = ":10" & addr & "00" & Strip_Data
    intel_hex(i) = Hexdata & Get_Checksum(Hexdata)
    Pull_EEPInfo
    addr_hex = addr_hex + &H10
    Strip_Data = ""

Next i
intel_hex(513) = ":00000001FF"
Display_EEPROM_Info

End Sub
Sub Pull_EEPInfo()


    ZKT(1) = ":10847800" & Get_BIN_Data("10002550")
    ZKT(2) = ":10848800" & Get_BIN_Data("10002560")
    ZKT(3) = ":10849800" & Get_BIN_Data("10002570")
    ZKT(4) = ":1084A800" & Get_BIN_Data("10002580")
    ZKT(5) = ":1084B800" & Get_BIN_Data("10002590")
    ZKT(6) = ":1084C800" & Get_BIN_Data("100025A0")
    ZKT(7) = ":1084D800" & Get_BIN_Data("100025B0")
    ZKT(8) = ":1084E800" & Get_BIN_Data("100025C0")




End Sub

Sub Display_EEPROM_Info()

Dim temp_password_digit
Dim HU_Pass_hex As String
Dim ird_hex As String
Dim USW_Info As String
Dim ird_txt_num As Double
Dim hex_zipcode As String
Dim zipcode_text As String
Dim FullCam As String
Dim PPV1_Amount As String
Dim PPV1_Limit As String
Dim PPV2_Amount As String
Dim PPV2_Limit As String
Dim Ratings_Byte As String
Dim ratings_limit As String
Dim ATR As String
Dim ATR_Byte13 As String
Dim ATR_Byte14 As String
Dim ATR_Byte15 As String
Dim ATR_Byte16 As String
Dim ATR_Byte17 As String
Dim ATR_Byte18 As String
Dim ATR_Byte19 As String
Dim ATR_Byte20 As String
Dim card_type As String
Dim Bad_ATR As Boolean

Bad_ATR = False


Get_Key

    'get cam and decrypt the data
Hexnumber = Get_BIN_Data("040124D8")
    'get the checksom digit for the cam
FullCam = GetFullCAM(Hexnumber)
CAM_Number = FullCam
temp1 = CAM_Number
Temp2 = 12 - Len(temp1)
CAM_textbox.Text = String(Temp2, "0") & CAM_Number

    'display possible atr for this eeprom
    'set the first 3 byte for the atr that are writen from rom
ATR = "3F 7F 13 "
    'get the data at 2465 and 2466 this is used to calulate the 4th byte of the ATR
temp1 = Get_BIN_Data("02012465")
If temp1 = "0000" Then
    ATR = ATR & "25 "
    Else:
        ATR = ATR & "00 "
        Bad_ATR = True
End If
    'get byte 2010. tihs is the 5th byte of the ATR
temp1 = Get_BIN_Data("01002010")
If temp1 <> "03" Then Bad_ATR = True
ATR = ATR & temp1 & " "
    'setup the next xx byte of the ATR that come form rom
ATR = ATR & "38 B0 04 FF FF 4A 50 "
    'get bytes 2018-201F.  these are used to calulate the last 8 bytes of ATR
temp1 = Get_BIN_Data("08002018")
ATR_Byte13 = Mid(temp1, 1, 2)
If ATR_Byte13 <> "8A" Then Bad_ATR = True
ATR_Byte14 = Mid(temp1, 3, 2)
If ATR_Byte14 <> "D3" Then Bad_ATR = True
ATR_Byte15 = Mid(temp1, 5, 2)
If ATR_Byte15 <> "DB" Then Bad_ATR = True
ATR_Byte16 = Mid(temp1, 7, 2)
If ATR_Byte16 <> "64" Then Bad_ATR = True
ATR_Byte17 = Mid(temp1, 9, 2)
If ATR_Byte17 <> "73" Then Bad_ATR = True
ATR_Byte18 = Mid(temp1, 11, 2)
If Left(ATR_Byte18, 1) <> "7" Then Bad_ATR = True
ATR_Byte19 = Mid(temp1, 13, 2)
If ATR_Byte19 <> "00" Then Bad_ATR = True
ATR_Byte20 = Mid(temp1, 15, 2)
If ATR_Byte20 <> "3A" Then Bad_ATR = True

ATR_Byte13 = Hex(HexToDec(ATR_Byte13) Xor HexToDec("8A"))
If Len(ATR_Byte13) < 2 Then ATR_Byte13 = "0" & ATR_Byte13
ATR_Byte14 = Hex(HexToDec(ATR_Byte14) Xor HexToDec("D3"))
If Len(ATR_Byte14) < 2 Then ATR_Byte14 = "0" & ATR_Byte14
ATR_Byte15 = Hex(HexToDec(ATR_Byte15) Xor HexToDec("F2"))
If Len(ATR_Byte15) < 2 Then ATR_Byte15 = "0" & ATR_Byte15
ATR_Byte16 = Hex(HexToDec(ATR_Byte16) Xor HexToDec("2C"))
If Len(ATR_Byte16) < 2 Then ATR_Byte16 = "0" & ATR_Byte16
ATR_Byte17 = Hex(HexToDec(ATR_Byte17) Xor HexToDec("26"))
If Len(ATR_Byte14) < 2 Then ATR_Byte17 = "0" & ATR_Byte17
ATR_Byte18 = Hex(HexToDec(ATR_Byte18) Xor HexToDec("21"))
If Len(ATR_Byte18) < 2 Then ATR_Byte18 = "0" & ATR_Byte18
ATR_Byte19 = Hex(HexToDec(ATR_Byte19) Xor HexToDec("00"))
If Len(ATR_Byte19) < 2 Then ATR_Byte19 = "0" & ATR_Byte19
ATR_Byte20 = Hex(HexToDec(ATR_Byte20) Xor HexToDec("3A"))
If Len(ATR_Byte20) < 2 Then ATR_Byte20 = "0" & ATR_Byte20

ATR = ATR & ATR_Byte13 & " " & ATR_Byte14 & " " & ATR_Byte15 & " " & ATR_Byte16 & " "
ATR = ATR & ATR_Byte17 & " " & ATR_Byte18 & " " & ATR_Byte19 & " " & ATR_Byte20


If Bad_ATR = True Then
    ATR_Textbox.ForeColor = &HC0&
    Else: ATR_Textbox.ForeColor = &H8000&
End If

ATR_Textbox.Text = ATR

card_type = Right(ATR_Byte18, 1) & "B"

    'display the fuse bytes addr 2014 - 2015
Fuse_Bytes = Get_BIN_Data("02002014")
Fusebytes_textbox.Text = Fuse_Bytes

    'display the Rating Limit addr 2464
 
Ratings_Byte = Get_BIN_Data("01012464")

ratings_limit = Ratings_Byte
Select Case Ratings_Byte
Case "01"
    ratings_limit = Ratings_Byte & " - All Locked"
Case "02"
    ratings_limit = Ratings_Byte & " - NR"
Case "03"
    ratings_limit = Ratings_Byte & " - G"
Case "04"
    ratings_limit = Ratings_Byte & " - PG"
Case "06"
    ratings_limit = Ratings_Byte & " - PG13"
Case "07"
    ratings_limit = Ratings_Byte & " - NR Content"
Case "09"
    ratings_limit = Ratings_Byte & " - R"
Case "0B"
    ratings_limit = Ratings_Byte & " - NR Mature"
Case "0D"
    ratings_limit = Ratings_Byte & " - NC17"
End Select
Ratings_Textbox.Text = ratings_limit

    'display the gude byte addr 251F
Guide_Byte = Get_BIN_Data("0101251F")
'If Fuse_Bytes = "20DF" Then Guide_Byte = Get_BIN_Data("0101251F")
'If Fuse_Bytes = "25DA" Then Guide_Byte = Get_BIN_Data("0100251F")
If Len(Guide_Byte) < 2 Then Guide_Byte = "0" & Guide_Byte
Guide_Byte_textbox.Text = Guide_Byte

    'get time zone byte addr 240
Time_Zone_Byte = Get_BIN_Data("010124E0")

    'display the usw addr 24E6 - 24E7
USW_Info = Get_BIN_Data("020124C8")
USW_TextBox.Text = Right(USW_Info, 2)

    'display the time zone
'timezone_combo.Text = ""
Select Case Time_Zone_Byte
Case "A0"
    Time_Zone = Time_Zone_Byte & " - Pacific"
Case "A2"
    Time_Zone = Time_Zone_Byte & " - Mountain"
Case "A4"
    Time_Zone = Time_Zone_Byte & " - Central"
Case "A6"
    Time_Zone = Time_Zone_Byte & " - Eastern"
Case "A8"
    Time_Zone = Time_Zone_Byte & " - Atlantic"
Case "A9"
    Time_Zone = Time_Zone_Byte & " - Newfoundland"
Case Else
    Time_Zone = Time_Zone_Byte
End Select
timezone_combo.Text = Time_Zone

    'display the zip code addr 2411-1415
hex_zipcode = Get_BIN_Data("05012411")
zipcode_textbox.Text = hex_zipcode
For X = 2 To 10 Step 2
    zipcode_text = zipcode_text & Mid(hex_zipcode, X, 1)
Next X
zipcode_textbox.Text = zipcode_text

    'display the password addr 240c -240f
HU_Pass_hex = Get_BIN_Data("0401240C")
HU_Password = ""
For X = 2 To 8 Step 2
    temp_password_digit = HexToDec(Mid(HU_Pass_hex, X, 1))
    HU_Password = HU_Password & temp_password_digit
Next X
password_textbox.Text = HU_Password

    'display ird number
ird_hex = Get_BIN_Data("040124A4")
ird_txt_num = Val(HexToDec(ird_hex))
If ird_txt_num = 0 Then IRD_textbox.Text = "00000000"
If ird_txt_num = 1 Then IRD_textbox.Text = "00000001"
If ird_txt_num <> 0 And ird_txt_num <> 1 Then IRD_textbox.Text = ird_txt_num

    'display the xor key bytes
xor_key_textbox.Text = Key_Byte(1) & Key_Byte(2) & Key_Byte(3) & Key_Byte(4) & Key_Byte(5) & Key_Byte(6) & Key_Byte(7) & Key_Byte(8)


    'display the PPV info
 
    'get amount from addr 241C
 PPV1_Amount = Get_BIN_Data("0201241C")
 PPV1_Amount = HexToDec(PPV1_Amount)
 If PPV1_Amount <> 0 Then PPV1_Amount = PPV1_Amount - 1
 If Len(PPV1_Amount) < 3 Then PPV1_Amount = "00" & PPV1_Amount
 
 PPV1_Amount = "$" & Mid(PPV1_Amount, 1, Len(PPV1_Amount) - 2) & "." & Right(PPV1_Amount, 2)
 
 PPV1_Limit = Get_BIN_Data("0201241E")
 PPV1_Limit = HexToDec(PPV1_Limit)
 If PPV1_Limit <> 0 Then PPV1_Limit = PPV1_Limit - 1
 If Len(PPV1_Limit) < 3 Then PPV1_Limit = "00" & PPV1_Limit
 PPV1_Limit = "$" & Mid(PPV1_Limit, 1, Len(PPV1_Limit) - 2) & "." & Right(PPV1_Limit, 2)
 
 slot1Purch_label.Caption = PPV1_Amount
 slot1Limit_label.Caption = PPV1_Limit
 
 slot2Purch_label.Caption = PPV1_Amount
 slot2Limit_label.Caption = PPV1_Limit
 
 If Get_BIN_Data("03003830") = "8EDC0A" Then WP_StatusLabel.Caption = "Write Protection is OFF"
 If Get_BIN_Data("03003830") = "2200E6" Then WP_StatusLabel.Caption = "Write Protection is ON"
 
 Enable_Options
 ViewDump
 
 Form1.Check1.SetFocus
 Form1.MousePointer = 0
 
End Sub

Private Sub ClearEEP_Pass_menu_Click()
clear_password
End Sub

Private Sub Command3_Click()
    'Exit the program
Unload Form1
End
End Sub



Private Sub COMPort_Box_Click()
Form1.MSFlexGrid1.TextMatrix(12, 1) = ""
On Error GoTo ComError
If Form1.MSComm1.PortOpen = True Then Form1.MSComm1.PortOpen = False
Form1.MSComm1.CommPort = Mid(Form7.COMPort_Box.Text, 4, 1)
Form1.MSComm1.PortOpen = True
Form1.MSComm1.RThreshold = ReturnBytes
GoTo comchanged

ComError:
Form1.MSFlexGrid1.TextMatrix(12, 1) = "ERROR:  Cant Open " & Form7.COMPort_Box.Text


comchanged:
'Form1.Convert.SetFocus

End Sub

Private Sub SaveEEP_Info()



change_zipcode
Change_TimeZone
Change_Guide_Byte
Change_Ratings



End Sub
Sub HexToBIN()

Dim bin_data_string As String
i = 1
For X = 1 To 512
    bin_data_string = Mid(intel_hex(X), 10, 32)
   
    For Y = 1 To 31 Step 2
        bin_file_data(i) = HexToDec(Mid(bin_data_string, Y, 2))
        i = i + 1
    Next Y
Next X

End Sub
Sub Write_intel_hex()
Dim addr_counter As Integer
Dim bin_file_index As Integer
Dim ThisByte As String

bin_file_index = 0
stipdata = ""

CommonDialog1.CancelError = True
On Error GoTo EndOfWriteIntelHex
CommonDialog1.Filter = "Bin Files (*.HEX)|*.HEX"
CommonDialog1.FileName = CAM_textbox.Text & ".HEX"
CommonDialog1.ShowSave       'display Open dialog box
If CommonDialog1.FileName = "" Then GoTo EndOfWriteIntelHex
Output_file = CommonDialog1.FileName




addr_hex = &H2000
For i = 1 To 512
    For X = 1 To 16
        ThisByte = Hex(bin_file_data(bin_file_index + X))
       
        If Len(ThisByte) < 2 Then ThisByte = "0" & ThisByte
        Strip_Data = Strip_Data & ThisByte
    Next X
    bin_file_index = bin_file_index + 16
    addr = Hex(addr_hex)
    Hexdata = ":10" & addr & "00" & Strip_Data
    intel_hex(i) = Hexdata & Get_Checksum(Hexdata)
    addr_hex = addr_hex + &H10
    Strip_Data = ""

Next i
intel_hex(513) = ":00000001FF"

Open Output_file For Output As #2

For z = 2 To 513
Print #2, intel_hex(z)
Next z

Close #2
MsgBox "The file was created to " & Output_file
BinSaved = True
EndOfWriteIntelHex:

End Sub

Sub Write_encoded_intel_hex()

Dim addr_counter As Integer
Dim bin_file_index As Integer
Dim ThisByte As String

bin_file_index = 0
stipdata = ""

CommonDialog1.CancelError = True
On Error GoTo EndOfWriteEncoded
CommonDialog1.Filter = "Hex Files (*.HEX)|*.HEX"
CommonDialog1.FileName = "@" & CAM_textbox.Text & ".HEX"
CommonDialog1.ShowSave       'display Open dialog box
If CommonDialog1.FileName = "" Then GoTo EndOfWriteEncoded
Output_file = CommonDialog1.FileName


addr_hex = &H2000
For i = 1 To 512
    For X = 1 To 16
        ThisByte = Hex(bin_file_data(bin_file_index + X))
       
        If Len(ThisByte) < 2 Then ThisByte = "0" & ThisByte
        Strip_Data = Strip_Data & ThisByte
    Next X
    bin_file_index = bin_file_index + 16
    addr = Hex(addr_hex)
    Hexdata = ":10" & addr & "00" & Strip_Data
    intel_hex(i) = Hexdata & Get_Checksum(Hexdata)
    addr_hex = addr_hex + &H10
    Strip_Data = ""

Next i
intel_hex(513) = ":00000001FF"


Open Output_file For Output As #3

For X = 2 To 513
temp1 = intel_hex(X)
encoded_intel_hex(X) = ":"

    For z = 2 To Len(temp1)
    Temp2 = Asc(Mid(temp1, z, 1))
    encoded_byte = Hex(Temp2 Xor 170)                               'XOr with 170 (Hex AA)
    encoded_byte = Right(encoded_byte, 1) & Left(encoded_byte, 1)   'Swap the digits
    Hexnumber = encoded_byte
    DecNumber = HexToDec(Hexnumber)                                 'convert to decimal
    encoded_byte = Chr(DecNumber)                                   'convert to ASCII
    encoded_intel_hex(X) = encoded_intel_hex(X) & encoded_byte
    Next z
    
Print #3, encoded_intel_hex(X)

Next X

Close #3

MsgBox "The file was created to " & Output_file
BinSaved = True
EndOfWriteEncoded:

End Sub

Sub Write_H_CamZKT()

CommonDialog1.CancelError = True
On Error GoTo EndOfWriteHImg
CommonDialog1.Filter = "IMG Files (*.IMG)|*.IMG"
CommonDialog1.FileName = "H_CAMnZKT_" & CAM_textbox.Text & ".IMG"
CommonDialog1.ShowSave     'display Open dialog box
If CommonDialog1.FileName = "" Then GoTo EndOfWriteHImg
Output_file = CommonDialog1.FileName



    'get cam id
CAM_first4bytes = Get_BIN_Data("040124D8")
CAM_lastbyte = Get_BIN_Data("010024DC")

ZKT(1) = ":10847800" & Get_BIN_Data("10002550")
ZKT(2) = ":10848800" & Get_BIN_Data("10002560")
ZKT(3) = ":10849800" & Get_BIN_Data("10002570")
ZKT(4) = ":1084A800" & Get_BIN_Data("10002580")
ZKT(5) = ":1084B800" & Get_BIN_Data("10002590")
ZKT(6) = ":1084C800" & Get_BIN_Data("100025A0")
ZKT(7) = ":1084D800" & Get_BIN_Data("100025B0")
ZKT(8) = ":1084E800" & Get_BIN_Data("100025C0")



CAM = ":05837400" & CAM_first4bytes & CAM_lastbyte


Open Output_file For Output As #3
    'Get the checksum for the Cam data
CAM = CAM & Get_Checksum(CAM)
    'Wrte the cam data to the image file
Print #3, CAM

    'Get the checksum for the zkt data and wirte to the Image file
For Y = 1 To 8
ZKT(Y) = ZKT(Y) & Get_Checksum(ZKT(Y))
Print #3, ZKT(Y)
Next Y

    'Write last line of image file
Print #3, ":00250A01D0"

Close #3
MsgBox "The file was created to " & Output_file & ".   Be sure to verify it in BasicH."
EndOfWriteHImg:
End Sub

Sub Get_Key()
Dim key_search1 As String

EEPROM_Keya = Get_BIN_Data("080024C0")
EEPROM_Keyb = Get_BIN_Data("08002658")
Decrypt_Key = ""

Y = 1
    'xor EEPROM_keya with EEPROM_keyb to get the decryptinon bytes
For X = 1 To 15 Step 2
    key_search1 = Hex(HexToDec(Mid(EEPROM_Keya, X, 2)) Xor HexToDec(Mid(EEPROM_Keyb, X, 2)))
        'Make sure the hex byte is two digits long
    If Len(key_search1) < 2 Then key_search1 = "0" & key_search1
    Decrypt_Key = Decrypt_Key & key_search1
    Key_Byte(Y) = key_search1
    Y = Y + 1
Next X


End Sub

Sub Write_HU_Bin()
Get_Key
'Dim bin_data(8192) As Byte
'Dim bin_data_string As String

CommonDialog1.CancelError = True
On Error GoTo EndOfWriteHUBin
CommonDialog1.Filter = "Bin Files (*.BIN)|*.BIN"
CommonDialog1.FileName = CAM_textbox.Text & ".BIN"
CommonDialog1.ShowSave       'display Open dialog box
If CommonDialog1.FileName = "" Then GoTo EndOfWriteHUBin
Output_file = CommonDialog1.FileName

Open Output_file For Binary As #3

For X = 1 To 8192
    Put #3, X, bin_file_data(X)
Next X

Close #3
MsgBox "The file was created to " & Output_file
BinSaved = True

EndOfWriteHUBin:
End Sub

Sub Clean_PPV()

Dim Temp_Header As String
Dim Temp_Leader As String
Dim PPV_Slot1 As String
Dim PPV_Slot2 As String
Dim PPV_Opt1 As String
Dim PPV_Opt2 As String
Dim PPV_Amount1 As String
Dim PPV_Amount2 As String
Dim PPV_Limit1 As String
Dim PPV_Limit2 As String
Dim TempByte As String
Dim LimitByte1 As String
Dim LimitByte2 As String

    'get the PPV Limit form user and chage purchase limit if needed.
changed = False
Load Form4
Form4.Show 1

    'test of setting 2424 to 1188
Put_Bin_Data ("04012422  6E103C5B")

    'set the buy option to 67
Put_Bin_Data ("0101241B  69")

    'set purchases to $0.00
Put_Bin_Data ("0201241C  0001")

    'Clear 2024 - 202f
Put_Bin_Data ("0C012024  000000000000000000000000")
    'Clear 2030 - 20FF
Put_Bin_Data ("20012030  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012050  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012070  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012090  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200120B0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200120D0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("100120F0  00000000000000000000000000000000")
    'Clear 2100 - 2103 Not sure if this is part of the PPV area
Put_Bin_Data ("06012100  000000000000")

BinSaved = False
Display_EEPROM_Info

End Sub

Sub Clear_IRD()
'clear both locations of the ird to 00 00 00 00

Dim IRD_Clear_Bytes As String

    'clear first Location
Put_Bin_Data ("04012460  00000000")

    'clear second location
Put_Bin_Data ("040124A4  00000000")

Display_EEPROM_Info
BinSaved = False
End Sub

Sub change_zipcode()

Get_Key
Dim new_zipcode As String
Dim zip_hex_digit(5) As String

new_zipcode = zipcode_textbox.Text
For X = 1 To 5
    zip_hex_digit(X) = "3" & Mid(new_zipcode, X, 1)
Next X
new_zipcode = zip_hex_digit(1) & zip_hex_digit(2) & zip_hex_digit(3) & zip_hex_digit(4) & zip_hex_digit(5)
Put_Bin_Data ("01012410  55")
Put_Bin_Data ("05012411  " & new_zipcode)
Put_Bin_Data ("02012416  2020")

Display_EEPROM_Info
BinSaved = False
End Sub
Sub clear_password()
    'address 240C
Put_Bin_Data ("0401240C  00000000")

BinSaved = False
Display_EEPROM_Info
End Sub



Sub Change_TimeZone()
Dim New_TimeZone As String

    'Get the new TimeZone and Xor it with the key byte
New_TimeZone = Left(timezone_combo.Text, 2)

    'Make sure the hex number is 2 digits long
If Len(New_TimeZone) < 2 Then New_TimeZone = "0" & New_TimeZone

Put_Bin_Data ("010124E0  " & New_TimeZone)
Display_EEPROM_Info
BinSaved = False
End Sub
Sub Change_Guide_Byte()
Dim X_Guide_Byte As String

X_Guide_Byte = Guide_Byte_textbox.Text

    'Make sure the hex number is 2 digits long
If Len(X_Guide_Byte) < 2 Then X_Guide_Byte = "0" & X_Guide_Byte
Put_Bin_Data ("0101251F  " & X_Guide_Byte)

Display_EEPROM_Info
BinSaved = False

End Sub
Private Sub Change_Ratings()
Dim Ratings As String

Ratings = Left(Ratings_Textbox.Text, 2)

Put_Bin_Data ("01012464  " & Ratings)

Display_EEPROM_Info
BinSaved = False
End Sub

Private Sub CraysStopButton_Click()
Cray_Stop = True

End Sub

Private Sub eeprom_open_menu_Click()
Command1_Click
End Sub

Private Sub exit_menu_Click()
Command3_Click
End Sub

Private Sub Fix_4th_Byte_Menu_Click()
Fix_ATR_Byte4
End Sub

Private Sub Form_Load()
SetMsgWin
LoadINI
COMPort_Box_Click
MSFlexGrid1.Col = 1
MSFlexGrid1.Row = 6
MSFlexGrid1.CellForeColor = &H0&
MSFlexGrid1.Col = 1
MSFlexGrid1.Row = 12
MSFlexGrid1.CellForeColor = &H0&
Form1.MSFlexGrid1.TextMatrix(1, 1) = "Welcome to #DSSTech - Extreme HU"
Form1.MSFlexGrid1.TextMatrix(2, 1) = "Version 1.1 (BETA 1) "
Form1.MSFlexGrid1.TextMatrix(4, 1) = "New in this version:"
Form1.MSFlexGrid1.TextMatrix(6, 1) = "Fixed gude, fuse, and time zone save problem."
Form1.MSFlexGrid1.TextMatrix(7, 1) = "Added Stop Button during glitching prosses."
Form1.MSFlexGrid1.TextMatrix(8, 1) = "Added Loader Settings Button."
Form1.MSFlexGrid1.TextMatrix(9, 1) = "Added Read USW option."
Form1.MSFlexGrid1.TextMatrix(10, 1) = "Added online help"
Form1.MSFlexGrid1.TextMatrix(11, 1) = "You can now turn on fuse and guide bytes"
Form1.MSFlexGrid1.TextMatrix(12, 1) = "when patching hex files."

Disable_Options
BinSaved = True

End Sub

Private Sub Fix_ATR_Byte4()

    'set address 2465 to hex 00  xored with keybyte
Put_Bin_Data ("02012465  0000")

BinSaved = False
Display_EEPROM_Info

End Sub
Sub patch_hex()

Dim patch_input(513) As String
Dim normal_hex_string As String
Dim End_of_String As Integer
Dim bytes_to_write As String
Dim addr_to_write As String
Dim data_to_write As String
Dim Checksum_byte As String
Dim CAM_clone_check As String

CancelError = False

CommonDialog1.FileName = ""
CommonDialog1.Filter = "HEX Files (*.HEX)|*.HEX"
CommonDialog1.ShowOpen       'display Open dialog box

If CommonDialog1.FileName = "" Then GoTo End_open_file
Input_patch_file = CommonDialog1.FileName
i = 1

Load WriteHexOptions
WriteHexOptions.Show 1
If CancelError = True Then Exit Sub

Open Input_patch_file For Input As #1
Do Until EOF(1)                                         'Open the file for reading
    Line Input #1, Patch_File
    If Left(Patch_File, 1) = ":" Then
        patch_input(i) = Patch_File
        i = i + 1
    End If

Loop
Close #1

If Asc(Mid(patch_input(1), 2, 1)) < 48 Or Asc(Mid(patch_input(1), 2, 1)) > 54 Then
    
    'convert file to nomal hex
    
    For X = 1 To i - 1
    normal_hex_string = ""
    temp1 = patch_input(X)
        For z = 2 To Len(temp1)
        Temp2 = Asc(Mid(temp1, z, 1))                                   'get the ascii code
        encoded_byte = Hex(Temp2 Xor 170)                               'XOr with 170 (Hex AA)
        If Len(encoded_byte) < 2 Then encoded_byte = "0" & encoded_byte
        encoded_byte = Right(encoded_byte, 1) & Left(encoded_byte, 1)   'Swap the digits
        Hexnumber = encoded_byte
        encoded_byte = HexToDec(Hexnumber)                              'convert to decimal
        encoded_byte = Chr(encoded_byte)                                'convert to normal Char.
        normal_hex_string = normal_hex_string & encoded_byte
        Next z
    patch_input(X) = ":" & normal_hex_string

    Next X
End If

    'check the hex file to make sure its valid
For X = 1 To i - 1
    End_of_String = Len(patch_input(X))
    End_of_String = End_of_String - 2
        'get the checksum that is in the file
    Checksum_byte = Right(patch_input(X), 2)
        'check to see if it is a good checksum. If not Abort!"
        
   If Checksum_byte <> Get_Checksum(Mid(patch_input(X), 1, End_of_String)) Then
        MsgBox "The Hex file is not valid. Operation Aborted!", vbCritical, "Patch Failed"
        GoTo End_open_file
    End If
Next X


    'get the cam id, so we can see if card has been cloned
CAM_clone_check = Get_BIN_Data("040124D8")

    'write the data to the bin
For X = 1 To i - 2
    End_of_String = Len(patch_input(X))
    End_of_String = End_of_String - 2
    bytes_to_write = Mid(patch_input(X), 2, 2)
    addr_to_write = Mid(patch_input(X), 4, 4)
    data_to_write = Mid(patch_input(X), 10, End_of_String)
    Put_Bin_Data (bytes_to_write & "00" & addr_to_write & "  " & data_to_write)
   
Next X


If WriteHexOptions.TurnOnFuseBytes.Value = 1 Then Put_Bin_Data ("02002014  25DA")
If WriteHexOptions.TurnOnGuide = 1 Then Put_Bin_Data ("0201251E  804D")

'If WriteHexOptions.TurnOnWP.Value = 1 Then
'    WP_Option = "2200E6"
'    Else: WP_Option = "8EDC0A"
'End If





BinSaved = False
Display_EEPROM_Info

If CAM_clone_check <> Get_BIN_Data("040124D8") Then
    MsgBox "Warning! The hex file has cloned your EEPROM.", vbExclamation, "Clone Warning."
    Else: MsgBox "The EEPROM has been patched with the hex file you selected.", vbInformation, "Finished"
End If
End_open_file:

End Sub



Private Sub Clean_EEPROM()


result = MsgBox("You have selected to clean the EEPROM.  Do you wish to coninue?", vbYesNo, "Are you sure?")


If result = 7 Then Exit Sub


    'Clean Guide Byte area
Put_Bin_Data ("01002500  00")
Put_Bin_Data ("0F012501  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")
Put_Bin_Data ("10012510  FFFF0000000000000000000000000000")


    'clean PPV guide area
Put_Bin_Data ("08012418  0000000000010000")
Put_Bin_Data ("20012420  0000000000000000000000010000000000000000000000000000000000000000")
Put_Bin_Data ("20012040  0000000000000100000000000000000000000000000000000000000000000000")
                       
    'Clean common jump points
'Put_Bin_Data ("0900283A  D1FEFEAAFFFD8E3F3D")
'Put_Bin_Data ("030028CB  8C29C4")
'Put_Bin_Data ("03003830  8EDC0A")

Put_Bin_Data ("0401240C  00000000")         'password
Put_Bin_Data ("08012410  0000000000000000") 'zip code
Put_Bin_Data ("06012406  03E800000000")     'spending limit
Put_Bin_Data ("02002014  20DF")             'fuse bytes
Put_Bin_Data ("07012460  00000001090000")   'IRD Location 1, ATR 00 to 25 fix, and ratings
Put_Bin_Data ("040124A4  00000001")         'IRD Location 2
Put_Bin_Data ("010124E0  A6")               'time zone
'Put_Bin_Data ("020124C8  0000")             'set usw to 0000

    'clean main code
Put_Bin_Data ("02002000  0000")
Put_Bin_Data ("200022F2  2210E37702270C8EE2B67610280575FC67D56A8CDCE712608EDB7E7D0029020B")
Put_Bin_Data ("20002312  982A30EF1D6102038CD4B5F97D40BE060375FED28CD15C40010017C5AA0060AB")
Put_Bin_Data ("20002332  0101C33D170FF5748028F98800603088003B327202068EE5ADF9726015882ACE")
Put_Bin_Data ("20002352  2A720204E700098A2ACFB34D006102EAF912088E3C96F9C5AA2AF8D024AA3F50")
Put_Bin_Data ("0B002372  13248E3C96C35D080FEEF9")
Put_Bin_Data ("1F0023B3  982A30EF70012A8E3C96C704EDD70904E0D5088827052A8ED1B0F98ED21D8E")
Put_Bin_Data ("200023D2  3C96F9C58E23F5F4CC2E2A0F0C8E23F5F4CC2A2E0F07223FE6D32CD32CC35D0C")
Put_Bin_Data ("140023F2  0FE2F99A2CD02DD32C9A2CD02ED32CF9FFFFFFFF")
Put_Bin_Data ("20002690  0000000000000000B3B8BDC2C7C7C7C7C7C7C7C7C7B3B3B3B3B3CCD1D1D1D1D1")
Put_Bin_Data ("200026B0  D1D6DB06C9DC3E1306C9DC3E2B08C9DC3E4306C9DC3E6301C9DC3E7B04C9DC3E")
Put_Bin_Data ("200026D0  7F01C9DC3E8F01C9DC3E9303C9DC3E97FFC8A0CE0D16F082AC8602C081580703")
Put_Bin_Data ("200026F0  0000FF40000000000000000000000000DFE1F01A00DFE1003800DF83043800D5")
Put_Bin_Data ("20002710  13011800D912031800D597001820D59B001820DAE50B1800D8B1812820D7AF82")
Put_Bin_Data ("20002730  3800385003D000289E051C00DFE1023800DABE122860D7B30328E0D6A1012860")
Put_Bin_Data ("20002750  DFE2002860D7F3822860D4110828E0D883003800DF7F00380028C50D28E0DEBA")
Put_Bin_Data ("20002770  0228E0D834042860D8B8082860D8DE003800D8D7043800D90B033800D93B2338")
Put_Bin_Data ("20002790  00D9CEF03800DAB7003860DAD0003820DAD4023860DB16043800D42A052860DB")
Put_Bin_Data ("200027B0  2800181022F2F01800DFF0042860DD808D28E0D9CEF03800DB4C853860DFE101")
Put_Bin_Data ("200027D0  180028A1883C002308E12860D5E7821800D667842860DB9FD52860E002822860")
Put_Bin_Data ("200027F0  DBD0813800D809D29000DFE1F09000383003F000D9608628E02FC79028A02F10")
Put_Bin_Data ("20002810  8028A02ABF89D000DB4C8528E02F088428E0DE458C28E0DE548628E05507AA24")
Put_Bin_Data ("20002830  B843000EAA2650130EF9D1FEFEAAFFFD8E3F3D2DF78C2F5C8E3F5812399B3012")
Put_Bin_Data ("20002850  3AF4EB0130F9B8C8D829D82AC5AA2AF0D007AA3F481307AB00DDC35D080FEE22")
Put_Bin_Data ("20002870  A064AB00DDC35D100FF5C59A30AB00ED700130C33D060FF38C3039008CC2988C")
Put_Bin_Data ("20002890  C0EC8C3EEB8C3B068C3B348C38198C39788CC27A8C3C968C393A8CE0748C2F43")
Put_Bin_Data ("200028B0  8C37008CE30E8C3D128C37808C37708CE0438C3C968C3D568CD6B28C29C48C2F")
Put_Bin_Data ("200028D0  568C31818C3F378C2AC58C3B558C3B798C36EA8CC4308C33B78C2F9D8CD6F68C")
Put_Bin_Data ("200028F0  31038CD3438C36F58C231E8C37738C3ED08C305C8CEC9C8C37728C377220203F")
Put_Bin_Data ("20002910  EF00000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20002930  000000000000000000000000005CDA5EFA8F6152EA1CFED0C6043DA97745BB98")
Put_Bin_Data ("20002950  231803ECF766BD3570C1DF224A8EA4599B94A5B8FF490C27663B80DE52CD7AE1")
Put_Bin_Data ("20002970  134DAAF79438C92552BC617F8016EE03DB01298401005C0A3C7D919AC5AA24B8")
Put_Bin_Data ("20002990  AB00EDAA2650AB00F5C35D080FEFC522A064AB00DDC35D100FF58800ED2A8800")
Put_Bin_Data ("200029B0  DD2C7210FD8E3EB272DD158824B02A721004E7F9C877202703757F2775EF2742")
Put_Bin_Data ("200029D0  2A0275F727751F02731F02D3024D04020F034204024C0204F750113215D80298")
Put_Bin_Data ("200029F0  2A347780270DD105D50E322A8E283A3205000A77202703B50003AA0000764027")
Put_Bin_Data ("20002A10  0ED0039A2AB81303D40315030206B99B2A740827C370012ADA02C7D402770827")
Put_Bin_Data ("20002A30  07882AA72A8E2A9575F7273215F75011762027277780270DD105D50E32348E28")
Put_Bin_Data ("20002A50  3A32050003AA00007640270AD0039A341303150302059B34740827C3700134DA")
Put_Bin_Data ("20002A70  02CED11577082707882AB32A8E2A9598342A7D0004020389FF45757F2775DF27")
Put_Bin_Data ("20002A90  75BF27C4F9C59A2AAB00ED70012AC35D0C0FF38E00EDF9F76011F761118EE7AE")
Put_Bin_Data ("20002AB0  8CE799F76211F763118EE7AE8CE7998EDCBB8CD5537702120225FE8CC89E0000")
Put_Bin_Data ("20002EF8  A5A5A5A5A5A5A5A5A5A5A5A500FFFFFF7601D001F98CDE3A720504882ACE2A8E")
Put_Bin_Data ("20002F18  E6A0720C048824F42A8EE6A02202E377022701F9D5D08EE02F8824662E882406")
Put_Bin_Data ("20002F38  2C8EC5078822F22E8CD8992D00F406E0938EE0F3771026034224938CE0D47223")
Put_Bin_Data ("20002F58  038CC0C1062FAAFFFC2DD80628B4B4C4D50BF4D9002A0EC8322A8E2F8FC4D00E")
Put_Bin_Data ("20002F78  AA006043000E440E0BC3D32A3D070FE2B4B4120BF932FE5507AA24C043000EAA")
Put_Bin_Data ("20002F98  2658130EF97DFF6002038CD9E51217021D7202078EDA993260CD5D030B10AA2A")
Put_Bin_Data ("20002FB8  D01D6102060FE6770160E27480D3F98EDC9977022745C5AA0064AB00EDC35D0C")
Put_Bin_Data ("20002FD8  0FF5AA297CAB00EDC35D100FF58829412A8800ED2C7210FD8E3EB2C5AA00EDD0")
Put_Bin_Data ("20002FF8  0BAA0064130BAB0064C35D0C0FEE8824F42A720C047264158CDC54F9E2880100")
Put_Bin_Data ("20003018  30E9D50BC5AA24F4D009AA2AE4130944000BC35D0C0FEE120B02032205E68CD0")
Put_Bin_Data ("20003038  0D225064AB00EDC35D100FF58800DD2A8800ED2C7206FD8E3EB298EE3AD42AD4")
Put_Bin_Data ("20003058  29C4B4F975BFCF32BEAA3073D029AA3074D02A8EC37A9E2A8C3404C358CE77C7")
Put_Bin_Data ("20003078  ECCFF8C358C358C358C358C358C7FBC358C358C358C358C358C358C358C358C3")
Put_Bin_Data ("20003098  58C358C7F5CF56C806C6A4CCC43EDCC358CF08C983C358C358C358D0EED0EE30")
Put_Bin_Data ("200030B8  143F20CE3F3710C6E4C358C358CEAD3BA1C9A0CEB83722C8A0C5498E311C9A2A")
Put_Bin_Data ("200030D8  D02B70012A9A2AD02C9E2C8ED27812088ED310D517120802088E23CED0178ED3")
Put_Bin_Data ("200030F8  108CD25A7D87080FD200057D80080BF48A2ACE2D02020AF4CA2A270506032240")
Put_Bin_Data ("20003118  E68CD242320855075A0788312F2A4B012A4900298CD1B03190F0382023693280")
Put_Bin_Data ("1F003138  CF382023632329D23810237C233D823800237CDFE1F038202369DFE1823800")
Put_Bin_Data ("1F003159  235982386023698E311C7D82080B258ED3AE770227058ED4079E194B17388C")
Put_Bin_Data ("20003178  D3807D87080FE1000C7610B6032241E67D80080BED8CD36C220F8E32718824C8")
Put_Bin_Data ("20003198  3088009E32720206EB4D609E060A4261244C9F2402020314D39E4D609E060C4D")
Put_Bin_Data ("200031B8  629F0607426124D3240001F9C5AA0063AB0090C35D0C0FF5C5AA0090AB0070C3")
Put_Bin_Data ("200031D8  5D0C0FF5AA2931AB0090C35D100FF58829712A8800902C7210FD8E3EB2C5AA00")
Put_Bin_Data ("200031F8  70D00EAA0090130EAB0090C35D100FEED72404C4D50BC5AA2EECD00EAA009043")
Put_Bin_Data ("20003218  000E440E0BC35D0C0FED120B0202009B726315882EEC2A720C04E78800603088")
Put_Bin_Data ("20003238  24C832720206ED1217028022038E32714261FD98622A753F291260B7B7D0048E")
Put_Bin_Data ("20003258  32717780FD0D88006030982A32420406ED00D4726015E700CE42170BD0178ED3")
Put_Bin_Data ("20003278  D54C170B420B17F97440CF22038E3271126202042D040F01F98824E63088009E")
Put_Bin_Data ("20003298  32720206EBF4CC9F610A057D0162021206E68824CA30EFB002DE2507B34D0062")
Put_Bin_Data ("200032B8  06D698619F3262224CC702072231C7020222401D1706C1720C04882EF82A8EE6")
Put_Bin_Data ("200032D8  A03262D1FFC70658220C8E3271C5AA0060AB00DDC35D0C0FF5AA297CAB00DDC3")
Put_Bin_Data ("200032F8  5D100FF58829412A8800DD2C7208FD8E3EB2C5AA0060D00EAA00DD130EAB00DD")
Put_Bin_Data ("20003318  C35D0C0FEE72DD15882EE02A720C04E7882DE02A8E337C882E002A8E337C002B")
Put_Bin_Data ("20003338  C7061A22118E327188006030882AD332721106ED882E202A8E337C000E882E40")
Put_Bin_Data ("20003358  2A8E337C882E602A8E337C88009E308824E632720206ED12FF8824CA30EA75BF")
Put_Bin_Data ("20003378  CF89FF1422208E327188006030982A32722006EDF98824CA30EF2507F9B87260")
Put_Bin_Data ("20003398  BE8E3537D4BE002512BE2D5C0BEF7640CFEB0019D7D78E338D2D030BEB000EC5")
Put_Bin_Data ("200033B8  B5AB00DAC35D260FF812D706E722908CC38F52FF8E351F120B0239002C300100")
Put_Bin_Data ("200033D8  60C5AA0101AB0061C33D600FF58824E63088009E32720206EBF4CC9F6202D300")
Put_Bin_Data ("200033F8  088824CA30EFB002D48900AE768028F1F98CC27A5D0C06F9C5AA2951AB0100C3")
Put_Bin_Data ("20003418  5D100FF5882AD330EFD00BC5AA0063AB0100C33D0B0FF5C5AA0100AB0140C35D")
Put_Bin_Data ("20003438  100FF58829612A8801002C7204FD8E3EB2223C8E3ECBD5DB32DBC2A801002C8E")
Put_Bin_Data ("20003458  ECA58EECA5C59A2CD009AA014013099B2CF4EB102CAB0140D32CC35D100FE7D3")
Put_Bin_Data ("20003478  DB7D04DB0FD28801402C8EECA58EECA5226A8E3ECBD509C5AA0140D00BAA0148")
Put_Bin_Data ("20003498  130BAB0140D00BA82ADC30EF130B440009C35D080FE21209020D8EDED97701B8")
Put_Bin_Data ("200034B8  037217C689FF49C5AA0100D00BA82DE030EF130BAB0100C35D400FECC5A82AD4")
Put_Bin_Data ("200034D8  30EFAB00DDC35D080FF3882AD330EFC01260B7B76CD0248800632A4B012AC53D")
Put_Bin_Data ("200034F8  240B059A2AAB00DDD32AC35D080FF08E0100C5AA00DDD00BAA00A0130BAB00A0")
Put_Bin_Data ("20003518  C35D080FEE009DD50BC5AA2EE0D00EAA2EF8130E44000BC35D0C0FEE120BF98E")
Put_Bin_Data ("20003538  3ED68A288B0207882F042A8EE68E8824CA30EFD01625072D03061C8E36A17260")
Put_Bin_Data ("20003558  0C7202128EE4098EE41A882E802A8E36C18E36A18901212D04061E8E36A1882E")
Put_Bin_Data ("20003578  803088010032726006EB72600C7202128EE41A8E36BD8900FF2D070259D5E926")
Put_Bin_Data ("20003598  0102D9E98E36A18829812A8EC4AEC542E9EA5D060B02D9EAAA2EE015EAAB00DD")
Put_Bin_Data ("200035B8  C35D0C0FEA222D8E3ECB8800DD2A22608EEBEF226A8E3ECBC5AA0100AB0060C3")
Put_Bin_Data ("200035D8  5D200FF572600C7202128EE4098EE41A8E36BD8C36907248948EED82D5DB32DB")
Put_Bin_Data ("200035F8  5D400B06A82DE02A00225D480B06A82A942A00185D500B06A82A942A000E5D51")
Put_Bin_Data ("20003618  0B06A82A832A0004A82DCF2A982A30EF8EEDA4C3129502095DB10FC4C88EEE89")
Put_Bin_Data ("20003638  C4129606B9D1DB5DB10FB3C5AA0088AB00DDC35D0C0FF5AA297CAB00DDC35D10")
Put_Bin_Data ("20003658  0FF58829412A8800DD2C7208FD8E3EB2C5AA0088D00EAA00DD130EAB00DDC35D")
Put_Bin_Data ("20003678  0C0FEE72DD15882EF82A720C04E78E351F020852028E3EA31216B38824CA30EA")
Put_Bin_Data ("20003698  B5882F042A8EE68EF9882E202A726004C5982A349A34AB0100700134C33D040F")
Put_Bin_Data ("200036B8  F38E36C4F9882E202A7260048801002C420422C59A2CAB006070012CC35D200F")
Put_Bin_Data ("200036D8  F388006030982A32722006ED7C202204E2F92D080604C58E3EA38CC3A3D002A6")
Put_Bin_Data ("200036F8  013DFC80351302F97D54BE06087D400902032200E68CC1C9E2D0C18ED06A7260")
Put_Bin_Data ("20003718  157240048826102AE7F9760112178ED06A770125058ECEFF00288ED04D882610")
Put_Bin_Data ("20003738  2A7701101172400C8EE4098EE41A8801002A7601120DC59A2AE170012AC35D40")
Put_Bin_Data ("20003758  0FF5F998C3AB8837D22A8E379BC5AA0088E1C35D080FF7F9D50BF93203AB0164")
Put_Bin_Data ("20003778  B81202AB016CB4F92240522DAB0100C35D3F0FF81210AB01008826902A8E379F")
Put_Bin_Data ("20003798  8C376576011014C59A2A7D5ABE0601B2AB00A4C370012A5D080FED7248948EED")
Put_Bin_Data ("200037B8  827D44BE020D7D56BE02088E37DA8E37DA00068E37F38E37F3F9E44425024554")
Put_Bin_Data ("200037D8  14D4C5AA01008EEDA4C35D400FF5C5AA00A48EEDA4C35D080FF5F9C5A8010030")
Put_Bin_Data ("200037F8  EE8EEDA4C35D2D0FF3AA01008EEDA4C35D400FF5C5AA00A48EEDA4C35D080FF5")
Put_Bin_Data ("20003818  F9D513D50B7D36BE0201F972041E8E386622368E3CA000F28EDC0A88006230EE")
Put_Bin_Data ("20003838  272004302987D78A2ACE27010776401E03223EE68E3866F9302987D78A2ACE27")
Put_Bin_Data ("20003858  0203223DE6D51E74801E8E3866F97201D977801E037200D98E39168E38B18838")
Put_Bin_Data ("20003878  912A77801E048838A12AC59A2AAB00A0C370012A5D100FF3F950E75FA407240E")
Put_Bin_Data ("20003898  C5A87738C1CBE7B663B3029E192FC4CF365AB16C722D1DB1BEF70038F7003AF7")
Put_Bin_Data ("200038B8  803DFF5207F7083D8E38D9C704FA8839012C77801E0488390A2C8E38EE8E38D9")
Put_Bin_Data ("200038D8  F99A2AD0059A2E1305A6013DFC213070012A70012EF99A2C213270012C9A2C21")
Put_Bin_Data ("200038F8  3470012C9A2C213DF902622C02403402442601642D01603401422F03403C121E")
Put_Bin_Data ("20003918  25072704022504B2BC8826602A4B002A790029883F582E4B002E79002DF97410")
Put_Bin_Data ("02003938  B6F9")
Put_Bin_Data ("1500393D  2240AB0100C35D400FF88E3ED6C5AA2688D024AA3F801324AB00A4")
Put_Bin_Data ("20003958  C35D080FEE8E37B3C5D509E2D002AA00881302440009C35D080FF0120902BFF9")
Put_Bin_Data ("20003978  8E3ED67D40BE061A8824503088009032720406EB129014910208720206880090")
Put_Bin_Data ("20003998  30E58E3A8375EFB68E3AE48E3F8872970A920A8EE7D1726A0A920A520C8E3AFC")
Put_Bin_Data ("200039B8  7D67080601E25208A6013DFC80358E3CA0C704F4C5AA00A02DFB0F022CFBAB00")
Put_Bin_Data ("200039D8  7CC35D080FEF12D988E91F30B0020488EA3F3098302A72A30A920A12D98EE89F")
Put_Bin_Data ("200039F8  726A0A920AC5E2D007A8015C30EE1307AB0060C35D08020D7D670802E95D050F")
Put_Bin_Data ("20003A18  E5D50700E4F7803DFFC5F7083DAA0060A6013DFC2130C35D070FF28839072C77")
Put_Bin_Data ("20003A38  801E048839102C8E38EE1267A6013DFC2130C5A6013DFC8035AB007CC35D080F")
Put_Bin_Data ("20003A58  F2982A3072A30A920A12D9D5038EE8D5726A0A920A7D0803F406C27AB0021B77")
Put_Bin_Data ("20003A78  021E0552018E3EA38CDCDF5208A6013DFC80358E3C96C704F4F97410B68800B0")
Put_Bin_Data ("20003A98  2A88003B2E7202078EDBD87D40BE06D8F7803D88390A2CF7083D8E38EEF7283D")
Put_Bin_Data ("20003AB8  C5AA00A0A6013DFC2130C35D070605F7243D00EDF7283D5D0F0FE68839132C8E")
Put_Bin_Data ("20003AD8  38EE12AFA6013DFC2130009C8839042C77801E0488390D2C8E38EE12D8A6013D")
Put_Bin_Data ("20003AF8  FC2130F9B58E3CA012D8C704F8F932117D60BE06068EFFBC2317F912BE250F2D")
Put_Bin_Data ("20003B18  0A061112D402038CFFB67620C1038CFF9E8CFFAE7D56BE02F58CFFA67D60BE06")
Put_Bin_Data ("20003B38  05882E202AF912D402058825D02AF97620C1058825502AF98825902AF97D60BE")
Put_Bin_Data ("20003B58  061A8E338D2D030605882E7F2CF92D040605882E4F2CF988007F2CF988264F2C")
Put_Bin_Data ("20003B78  F97D60BE061D8E338D2D030606F4CA2C2E4FF92D040606F4CA2C2E1FF9F4CA2C")
Put_Bin_Data ("20003B98  005FF9F4CA2C260FF98E3ED67710B82FD508D5B87708D0087216087404B80051")
Put_Bin_Data ("20003BB8  7640B54D880176308800A0327208068EE5B7D5A8D5A97401B88E3C74890096C5")
Put_Bin_Data ("20003BD8  AA24F4D00BAA00A043000BAA2AE4130BAB00A0C35D0C0FE88EDED98EDF617D17")
Put_Bin_Data ("20003BF8  C606037204B87708B8037402D17601B80FC5B5AB00A0AB0088C35D0A0FF50037")
Put_Bin_Data ("20003C18  C58801762CA6013DFC80358E3CA0A8017630EE13D89B2C70012CC35D0A0FE688")
Put_Bin_Data ("20003C38  01762CC59A2CAB00A0AB0088B59B2CC370012C5D0A0FED7740B7038E3D907601")
Put_Bin_Data ("20003C58  B604D5A8D5A98E3C74C5AA0088AB00A0C35D080FF598D6C398A7D6F942B5AA12")
Put_Bin_Data ("20003C78  B82507D0AB32C734C802057401D2D5084208ACC5AA00A0E1C35D0D0FF7F9A601")
Put_Bin_Data ("20003C98  3DFC21308E3CA0F9B8C8D5DBD5DCD0D87B05DC32DBAA00A81BD8AB00A8D0DAAA")
Put_Bin_Data ("20003CB8  00A013DAAB00A013DC251FC0AA3CF2D0DA32DB5306AA00A813DAAB00A8B0BDD0")
Put_Bin_Data ("20003CD8  DA32DB5305AA00A01CDAAB00A04300D8D3DB7D08DB0FB9C4B4F9BF12939242AF")
Put_Bin_Data ("20003CF8  E7E3B2C6B89180B4E8739EF75DFDA082F96F25177D0B55970C8022678EE06F74")
Put_Bin_Data ("20003D18  042522088EE06F8E3A838E3AE48E3F8872970A920A8EE7D1726A0A920A520A8E")
Put_Bin_Data ("20003D38  3AFC8839012C8E38EEC5A6013DFC80358E3C9612D88EE06FC35D080FEDF98EFA")
Put_Bin_Data ("20003D58  27B006F98800683088245832720406EDC5AA2688D007AA3F80430007AA006013")
Put_Bin_Data ("20003D78  07AB0060C35D080FE87260158826902A720804E77420D1F9882460308800ED32")
Put_Bin_Data ("20003D98  720406EB720407D5063206AA00A0D0045503AA00EDD0053206C35507AA00A04B")
Put_Bin_Data ("20003DB8  0005C85503AA00EDD00932043C00553F8E3E0843000512041309BDB0BDC08E3E")
Put_Bin_Data ("20003DD8  08BE1B05C4AB00A0C5D8F0AA00EDD002B0BFD003B4D8022580BE1403AB00EDC3")
Put_Bin_Data ("20003DF8  770401E7B4D3067708069ED7070498F98EFFB67D00D406F78CFF9E0012010125")
Put_Bin_Data ("20003E18  002008001E010124100808001A0101240602080013010125202008002D010124")
Put_Bin_Data ("20003E38  08040800D0010124650108002E010124682008004E0101245C04080058010124")
Put_Bin_Data ("20003E58  E0010800F3010124A40408001901012464010800FE0101240C04080041010121")
Put_Bin_Data ("20003E78  060408C9F400000045010124881C0800F8010120240908CA360000CA750000CA")
Put_Bin_Data ("20003E98  B100000044010124E80C08B8A82AD02A9A2AB302038EE68EB4F9223C8E3ECB42")
Put_Bin_Data ("20003EB8  04FED50E8EECA5D30E4DFD0E0FF642FE04226AD00A920AF98E3ED68CC1A47202")
Put_Bin_Data ("20003ED8  058CC204E2C07604D10375BFD375F7CF8CC9597601CF1B2D7F06178E298C8EC2")
Put_Bin_Data ("20003EF8  4C8A2F04020A882E202A72C0048EE6A0227F7D5EBE060E7D01120609D31D7D08")
Put_Bin_Data ("20003F18  1D060222018CC00B770212108ED0EE8EDED97608B80375BFB48CCC4E8CCC3675")
Put_Bin_Data ("10003F38  FBB48CD59FF4CA2CCBB90603728646F9")
Put_Bin_Data ("10003F58  12937D04060603751F938E2856D093F9")
Put_Bin_Data ("20003F88  727B0252058E3FB8722902000A520FAA00A0BCF008D0028E3FB3AA00A0823FDF")
Put_Bin_Data ("20003FA8  C522C72306724B024B02005203A40220AA00AA1B02AB00AAAA009FCAF3F91E72")
Put_Bin_Data ("20003FC8  CB250299A866F0DA234B00F8F5A0ABA70005009FCAB9F95203AA00A0D002AA00")
Put_Bin_Data ("18003FE8  AC4B0002AA3F9413022B5ABE236BAB00ACCAE6A3FD20F900")

    'clean blank areas
Put_Bin_Data ("0C012024  000000000000000000000000")
Put_Bin_Data ("20012030  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012050  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012070  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012090  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200120B0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200120D0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200120F0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012110  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012130  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012150  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012170  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012190  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200121B0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200121D0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200121F0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012210  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012230  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012250  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012270  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012290  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200122B0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("200122D0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("020122F0  0000")
'Put_Bin_Data ("20012210  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012B00  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012B20  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012B40  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012B60  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012B80  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012BA0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012BC0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012BE0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012C00  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012C20  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012C40  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012C60  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012C80  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012CA0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012CC0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012CD0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012D00  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012D20  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012D40  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012D60  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012D80  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012DA0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012DC0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012DE0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012E00  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012E20  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012E40  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012E60  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012E80  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012EA0  0000000000000000000000000000000000000000000000000000000000000000")
Put_Bin_Data ("20012EC0  0000000000000000000000000000000000000000000000000000000000000000")

BinSaved = False
Display_EEPROM_Info
MsgBox "The EEPROM has been cleaned", vbInformation, "Finished Cleaning"
End Sub
Private Sub clean_card_menu_Click()
Dim CleanAddr As Integer
Dim LongCardKey8 As String
Dim LongCardKey16 As String
Dim LongCardKey32 As String

NotInThisBeta
Exit Sub





LongCardKey8 = CardKey(0) & CardKey(1) & CardKey(2) & CardKey(3) & CardKey(4) & CardKey(5) & CardKey(6) & CardKey(7)
LongCardKey16 = LongCardKey8 & LongCardKey8
LongCardKey32 = LongCardKey16 & LongCardKey16


MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 1 of 15"
CleanAddr = &H2030
Do
WDTMR
HU_Write ("25E29F" & HexString(CleanAddr, 4) & LongCardKey32 & "00")
ReadHU (2)
cleandaddr = CleanAddr + 32
Loop Until CleanAddr > &H22D0

Call WDTMR
HU_Write ("11CE8B2024" & CardKey(4) & CardKey(5) & CardKey(6) & CardKey(7) & LongCardKey8 & "00")
ReadHU (&H2)



MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 2 of 15"
CleanAddr = &H2B00
Do
WDTMR
HU_Write ("25E29F" & HexString(CleanAddr, 4) & LongCardKey32 & "00")
ReadHU (2)
cleandaddr = CleanAddr + 32
Loop Until CleanAddr > &H2EC0






MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 3 of 15"
HU_Write ("25E29F26900000000000000000B3B8BDC2C7C7C7C7C7C7C7C7C7B3B3B3B3B3CCD1D1D1D1D100")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F26B0D1D6DB06C9DC3E1306C9DC3E2B08C9DC3E4306C9DC3E6301C9DC3E7B04C9DC3E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F26D07F01C9DC3E8F01C9DC3E9303C9DC3E97FFC8A0CE0D16F082AC8602C08158070300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F26F00000FF40000000000000000000000000DFE1F01A00DFE1003800DF83043800D500")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F271013011800D912031800D597001820D59B001820DAE50B1800D8B1812820D7AF8200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F27303800385003D000289E051C00DFE1023800DABE122860D7B30328E0D6A101286000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2750DFE2002860D7F3822860D4110828E0D883003800DF7F00380028C50D28E0DEBA00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F27700228E0D834042860D8B8082860D8DE003800D8D7043800D90B033800D93B233800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F279000D9CEF03800DAB7003860DAD0003820DAD4023860DB16043800D42A052860DB00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F27B02800181022F2F01800DFF0042860DD808D28E0D9CEF03800DB4C853860DFE10100")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 4 of 15"
HU_Write ("25E29F27D0180028A1883C002308E12860D5E7821800D667842860DB9FD52860E00282286000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F27F0DBD0813800D809D29000DFE1F09000383003F000D9608628E02FC79028A02F1000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F28108028A02ABF89D000DB4C8528E02F088428E0DE458C28E0DE548628E05507AA2400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2830B843000EAA2650130EF9D1FEFEAAFFFD8E3F3D2DF78C2F5C8E3F5812399B301200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F28503AF4EB0130F9B8C8D829D82AC5AA2AF0D007AA3F481307AB00DDC35D080FEE2200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2870A064AB00DDC35D100FF5C59A30AB00ED700130C33D060FF38C3039008CC2988C00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2890C0EC8C3EEB8C3B068C3B348C38198C39788CC27A8C3C968C393A8CE0748C2F4300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F28B08C37008CE30E8C3D128C37808C37708CE0438C3C968C3D568CD6B28C29C48C2F00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F28D0568C31818C3F378C2AC58C3B558C3B798C36EA8CC4308C33B78C2F9D8CD6F68C00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F28F031038CD3438C36F58C231E8C37738C3ED08C305C8CEC9C8C37728C377220203F00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2910EF0000000000000000000000000000000000000000000000000000000000000000")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 5 of 15"
HU_Write ("25E29F2930000000000000000000000000005CDA5EFA8F6152EA1CFED0C6043DA97745BB9800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2950231803ECF766BD3570C1DF224A8EA4599B94A5B8FF490C27663B80DE52CD7AE100")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2970134DAAF79438C92552BC617F8016EE03DB01298401005C0A3C7D919AC5AA24B800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2990AB00EDAA2650AB00F5C35D080FEFC522A064AB00DDC35D100FF58800ED2A880000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F29B0DD2C7210FD8E3EB272DD158824B02A721004E7F9C877202703757F2775EF274200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F29D02A0275F727751F02731F02D3024D04020F034204024C0204F750113215D8029800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F29F02A347780270DD105D50E322A8E283A3205000A77202703B50003AA000076402700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2A100ED0039A2AB81303D40315030206B99B2A740827C370012ADA02C7D40277082700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2A3007882AA72A8E2A9575F7273215F75011762027277780270DD105D50E32348E2800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2A503A32050003AA00007640270AD0039A341303150302059B34740827C3700134DA00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2A7002CED11577082707882AB32A8E2A9598342A7D0004020389FF45757F2775DF2700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2A9075BF27C4F9C59A2AAB00ED70012AC35D0C0FF38E00EDF9F76011F761118EE7AE00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2AB08CE799F76211F763118EE7AE8CE7998EDCBB8CD5537702120225FE8CC89E000000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2EF8A5A5A5A5A5A5A5A5A5A5A5A500FFFFFF7601D001F98CDE3A720504882ACE2A8E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2F18E6A0720C048824F42A8EE6A02202E377022701F9D5D08EE02F8824662E88240600")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2F382C8EC5078822F22E8CD8992D00F406E0938EE0F3771026034224938CE0D4722300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2F58038CC0C1062FAAFFFC2DD80628B4B4C4D50BF4D9002A0EC8322A8E2F8FC4D00E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2F78AA006043000E440E0BC3D32A3D070FE2B4B4120BF932FE5507AA24C043000EAA00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2F982658130EF97DFF6002038CD9E51217021D7202078EDA993260CD5D030B10AA2A00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2FB8D01D6102060FE6770160E27480D3F98EDC9977022745C5AA0064AB00EDC35D0C00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F2FD80FF5AA297CAB00EDC35D100FF58829412A8800ED2C7210FD8E3EB2C5AA00EDD000")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 6 of 15"
HU_Write ("25E29F2FF80BAA0064130BAB0064C35D0C0FEE8824F42A720C047264158CDC54F9E288010000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F301830E9D50BC5AA24F4D009AA2AE4130944000BC35D0C0FEE120B02032205E68CD000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F30380D225064AB00EDC35D100FF58800DD2A8800ED2C7206FD8E3EB298EE3AD42AD400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F305829C4B4F975BFCF32BEAA3073D029AA3074D02A8EC37A9E2A8C3404C358CE77C700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3078ECCFF8C358C358C358C358C358C7FBC358C358C358C358C358C358C358C358C300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F309858C358C7F5CF56C806C6A4CCC43EDCC358CF08C983C358C358C358D0EED0EE3000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F30B8143F20CE3F3710C6E4C358C358CEAD3BA1C9A0CEB83722C8A0C5498E311C9A2A00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F30D8D02B70012A9A2AD02C9E2C8ED27812088ED310D517120802088E23CED0178ED300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F30F8108CD25A7D87080FD200057D80080BF48A2ACE2D02020AF4CA2A27050603224000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3118E68CD242320855075A0788312F2A4B012A4900298CD1B03190F038202369328000")
ReadHU (&H2)
Call WDTMR
HU_Write ("24E19E3138CF382023632329D23810237C233D823800237CDFE1F038202369DFE182380000")
ReadHU (&H2)
Call WDTMR
HU_Write ("24E19E3159235982386023698E311C7D82080B258ED3AE770227058ED4079E194B17388C00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3178D3807D87080FE1000C7610B6032241E67D80080BED8CD36C220F8E32718824C800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F31983088009E32720206EB4D609E060A4261244C9F2402020314D39E4D609E060C4D00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F31B8629F0607426124D3240001F9C5AA0063AB0090C35D0C0FF5C5AA0090AB0070C300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F31D85D0C0FF5AA2931AB0090C35D100FF58829712A8800902C7210FD8E3EB2C5AA0000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F31F870D00EAA0090130EAB0090C35D100FEED72404C4D50BC5AA2EECD00EAA00904300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3218000E440E0BC35D0C0FED120B0202009B726315882EEC2A720C04E7880060308800")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 7 of 15"
HU_Write ("25E29F323824C832720206ED1217028022038E32714261FD98622A753F291260B7B7D0048E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F325832717780FD0D88006030982A32420406ED00D4726015E700CE42170BD0178ED300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3278D54C170B420B17F97440CF22038E3271126202042D040F01F98824E63088009E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F329832720206EBF4CC9F610A057D0162021206E68824CA30EFB002DE2507B34D006200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F32B806D698619F3262224CC702072231C7020222401D1706C1720C04882EF82A8EE600")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F32D8A03262D1FFC70658220C8E3271C5AA0060AB00DDC35D0C0FF5AA297CAB00DDC300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F32F85D100FF58829412A8800DD2C7208FD8E3EB2C5AA0060D00EAA00DD130EAB00DD00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3318C35D0C0FEE72DD15882EE02A720C04E7882DE02A8E337C882E002A8E337C002B00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3338C7061A22118E327188006030882AD332721106ED882E202A8E337C000E882E4000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F33582A8E337C882E602A8E337C88009E308824E632720206ED12FF8824CA30EA75BF00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3378CF89FF1422208E327188006030982A32722006EDF98824CA30EF2507F9B8726000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3398BE8E3537D4BE002512BE2D5C0BEF7640CFEB0019D7D78E338D2D030BEB000EC500")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F33B8B5AB00DAC35D260FF812D706E722908CC38F52FF8E351F120B0239002C30010000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F33D860C5AA0101AB0061C33D600FF58824E63088009E32720206EBF4CC9F6202D30000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F33F8088824CA30EFB002D48900AE768028F1F98CC27A5D0C06F9C5AA2951AB0100C300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F34185D100FF5882AD330EFD00BC5AA0063AB0100C33D0B0FF5C5AA0100AB0140C35D00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3438100FF58829612A8801002C7204FD8E3EB2223C8E3ECBD5DB32DBC2A801002C8E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3458ECA58EECA5C59A2CD009AA014013099B2CF4EB102CAB0140D32CC35D100FE7D300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3478DB7D04DB0FD28801402C8EECA58EECA5226A8E3ECBD509C5AA0140D00BAA014800")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 8 of 15"
HU_Write ("25E29F3498130BAB0140D00BA82ADC30EF130B440009C35D080FE21209020D8EDED97701B800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F34B8037217C689FF49C5AA0100D00BA82DE030EF130BAB0100C35D400FECC5A82AD400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F34D830EFAB00DDC35D080FF3882AD330EFC01260B7B76CD0248800632A4B012AC53D00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F34F8240B059A2AAB00DDD32AC35D080FF08E0100C5AA00DDD00BAA00A0130BAB00A000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3518C35D080FEE009DD50BC5AA2EE0D00EAA2EF8130E44000BC35D0C0FEE120BF98E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F35383ED68A288B0207882F042A8EE68E8824CA30EFD01625072D03061C8E36A1726000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F35580C7202128EE4098EE41A882E802A8E36C18E36A18901212D04061E8E36A1882E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3578803088010032726006EB72600C7202128EE41A8E36BD8900FF2D070259D5E92600")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F35980102D9E98E36A18829812A8EC4AEC542E9EA5D060B02D9EAAA2EE015EAAB00DD00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F35B8C35D0C0FEA222D8E3ECB8800DD2A22608EEBEF226A8E3ECBC5AA0100AB0060C300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F35D85D200FF572600C7202128EE4098EE41A8E36BD8C36907248948EED82D5DB32DB00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F35F85D400B06A82DE02A00225D480B06A82A942A00185D500B06A82A942A000E5D5100")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F36180B06A82A832A0004A82DCF2A982A30EF8EEDA4C3129502095DB10FC4C88EEE8900")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3638C4129606B9D1DB5DB10FB3C5AA0088AB00DDC35D0C0FF5AA297CAB00DDC35D1000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F36580FF58829412A8800DD2C7208FD8E3EB2C5AA0088D00EAA00DD130EAB00DDC35D00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F36780C0FEE72DD15882EF82A720C04E78E351F020852028E3EA31216B38824CA30EA00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3698B5882F042A8EE68EF9882E202A726004C5982A349A34AB0100700134C33D040F00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F36B8F38E36C4F9882E202A7260048801002C420422C59A2CAB006070012CC35D200F00")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 9 of 15"
HU_Write ("25E29F36D8F388006030982A32722006ED7C202204E2F92D080604C58E3EA38CC3A3D002A600")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F36F8013DFC80351302F97D54BE06087D400902032200E68CC1C9E2D0C18ED06A726000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3718157240048826102AE7F9760112178ED06A770125058ECEFF00288ED04D88261000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F37382A7701101172400C8EE4098EE41A8801002A7601120DC59A2AE170012AC35D4000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F37580FF5F998C3AB8837D22A8E379BC5AA0088E1C35D080FF7F9D50BF93203AB016400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3778B81202AB016CB4F92240522DAB0100C35D3F0FF81210AB01008826902A8E379F00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F37988C376576011014C59A2A7D5ABE0601B2AB00A4C370012A5D080FED7248948EED00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F37B8827D44BE020D7D56BE02088E37DA8E37DA00068E37F38E37F3F9E4442502455400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F37D814D4C5AA01008EEDA4C35D400FF5C5AA00A48EEDA4C35D080FF5F9C5A801003000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F37F8EE8EEDA4C35D2D0FF3AA01008EEDA4C35D400FF5C5AA00A48EEDA4C35D080FF500")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3818F9D513D50B7D36BE0201F972041E8E386622368E3CA000F28EDC0A88006230EE00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3838272004302987D78A2ACE27010776401E03223EE68E3866F9302987D78A2ACE2700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F38580203223DE6D51E74801E8E3866F97201D977801E037200D98E39168E38B1883800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3878912A77801E048838A12AC59A2AAB00A0C370012A5D100FF3F950E75FA407240E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3898C5A87738C1CBE7B663B3029E192FC4CF365AB16C722D1DB1BEF70038F7003AF700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F38B8803DFF5207F7083D8E38D9C704FA8839012C77801E0488390A2C8E38EE8E38D900")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F38D8F99A2AD0059A2E1305A6013DFC213070012A70012EF99A2C213270012C9A2C2100")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 10 of 15"
HU_Write ("25E29F38F83470012C9A2C213DF902622C02403402442601642D01603401422F03403C121E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F391825072704022504B2BC8826602A4B002A790029883F582E4B002E79002DF9741000")
ReadHU (&H2)
Call WDTMR
HU_Write ("07C4813938B6F900")
ReadHU (&H2)
Call WDTMR
HU_Write ("20DD9A393D2240AB0100C35D400FF88E3ED6C5AA2688D024AA3F801324AB00A400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3958C35D080FEE8E37B3C5D509E2D002AA00881302440009C35D080FF0120902BFF900")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F39788E3ED67D40BE061A8824503088009032720406EB12901491020872020688009000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F399830E58E3A8375EFB68E3AE48E3F8872970A920A8EE7D1726A0A920A520C8E3AFC00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F39B87D67080601E25208A6013DFC80358E3CA0C704F4C5AA00A02DFB0F022CFBAB0000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F39D87CC35D080FEF12D988E91F30B0020488EA3F3098302A72A30A920A12D98EE89F00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F39F8726A0A920AC5E2D007A8015C30EE1307AB0060C35D08020D7D670802E95D050F00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3A18E5D50700E4F7803DFFC5F7083DAA0060A6013DFC2130C35D070FF28839072C7700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3A38801E048839102C8E38EE1267A6013DFC2130C5A6013DFC8035AB007CC35D080F00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3A58F2982A3072A30A920A12D9D5038EE8D5726A0A920A7D0803F406C27AB0021B7700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3A78021E0552018E3EA38CDCDF5208A6013DFC80358E3C96C704F4F97410B68800B000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3A982A88003B2E7202078EDBD87D40BE06D8F7803D88390A2CF7083D8E38EEF7283D00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3AB8C5AA00A0A6013DFC2130C35D070605F7243D00EDF7283D5D0F0FE68839132C8E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3AD838EE12AFA6013DFC2130009C8839042C77801E0488390D2C8E38EE12D8A6013D00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3AF8FC2130F9B58E3CA012D8C704F8F932117D60BE06068EFFBC2317F912BE250F2D00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3B180A061112D402038CFFB67620C1038CFF9E8CFFAE7D56BE02F58CFFA67D60BE0600")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 11 of 15"
HU_Write ("25E29F3B3805882E202AF912D402058825D02AF97620C1058825502AF98825902AF97D60BE00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3B58061A8E338D2D030605882E7F2CF92D040605882E4F2CF988007F2CF988264F2C00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3B78F97D60BE061D8E338D2D030606F4CA2C2E4FF92D040606F4CA2C2E1FF9F4CA2C00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3B98005FF9F4CA2C260FF98E3ED67710B82FD508D5B87708D0087216087404B8005100")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3BB87640B54D880176308800A0327208068EE5B7D5A8D5A97401B88E3C74890096C500")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3BD8AA24F4D00BAA00A043000BAA2AE4130BAB00A0C35D0C0FE88EDED98EDF617D1700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3BF8C606037204B87708B8037402D17601B80FC5B5AB00A0AB0088C35D0A0FF5003700")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3C18C58801762CA6013DFC80358E3CA0A8017630EE13D89B2C70012CC35D0A0FE68800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3C3801762CC59A2CAB00A0AB0088B59B2CC370012C5D0A0FED7740B7038E3D90760100")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3C58B604D5A8D5A98E3C74C5AA0088AB00A0C35D080FF598D6C398A7D6F942B5AA1200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3C78B82507D0AB32C734C802057401D2D5084208ACC5AA00A0E1C35D0D0FF7F9A60100")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3C983DFC21308E3CA0F9B8C8D5DBD5DCD0D87B05DC32DBAA00A81BD8AB00A8D0DAAA00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3CB800A013DAAB00A013DC251FC0AA3CF2D0DA32DB5306AA00A813DAAB00A8B0BDD000")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3CD8DA32DB5305AA00A01CDAAB00A04300D8D3DB7D08DB0FB9C4B4F9BF12939242AF00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3CF8E7E3B2C6B89180B4E8739EF75DFDA082F96F25177D0B55970C8022678EE06F7400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3D18042522088EE06F8E3A838E3AE48E3F8872970A920A8EE7D1726A0A920A520A8E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3D383AFC8839012C8E38EEC5A6013DFC80358E3C9612D88EE06FC35D080FEDF98EFA00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3D5827B006F98800683088245832720406EDC5AA2688D007AA3F80430007AA00601300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3D7807AB0060C35D080FE87260158826902A720804E77420D1F9882460308800ED3200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3D98720406EB720407D5063206AA00A0D0045503AA00EDD0053206C35507AA00A04B00")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 12 of 15"
HU_Write ("25E29F3DB80005C85503AA00EDD00932043C00553F8E3E0843000512041309BDB0BDC08E3E00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3DD808BE1B05C4AB00A0C5D8F0AA00EDD002B0BFD003B4D8022580BE1403AB00EDC300")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3DF8770401E7B4D3067708069ED7070498F98EFFB67D00D406F78CFF9E001201012500")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3E18002008001E010124100808001A0101240602080013010125202008002D01012400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3E3808040800D0010124650108002E010124682008004E0101245C0408005801012400")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3E58E0010800F3010124A40408001901012464010800FE0101240C0408004101012100")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3E78060408C9F400000045010124881C0800F8010120240908CA360000CA750000CA00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3E98B100000044010124E80C08B8A82AD02A9A2AB302038EE68EB4F9223C8E3ECB4200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3EB804FED50E8EECA5D30E4DFD0E0FF642FE04226AD00A920AF98E3ED68CC1A4720200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3ED8058CC204E2C07604D10375BFD375F7CF8CC9597601CF1B2D7F06178E298C8EC200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3EF84C8A2F04020A882E202A72C0048EE6A0227F7D5EBE060E7D01120609D31D7D0800")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3F181D060222018CC00B770212108ED0EE8EDED97608B80375BFB48CCC4E8CCC367500")
ReadHU (&H2)
Call WDTMR
HU_Write ("15D28F3F38FBB48CD59FF4CA2CCBB90603728646F900")
ReadHU (&H2)
Call WDTMR
HU_Write ("15D28F3F5812937D04060603751F938E2856D093F900")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3F88727B0252058E3FB8722902000A520FAA00A0BCF008D0028E3FB3AA00A0823FDF00")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3FA8C522C72306724B024B02005203A40220AA00AA1B02AB00AAAA009FCAF3F91E7200")
ReadHU (&H2)
Call WDTMR
HU_Write ("25E29F3FC8CB250299A866F0DA234B00F8F5A0ABA70005009FCAB9F95203AA00A0D002AA0000")
ReadHU (&H2)
Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Cleaning EEPROM Step 13 of 15"
HU_Write ("1DDA973FE8AC4B0002AA3F9413022B5ABE236BAB00ACCAE6A3FD20F90000")
ReadHU (&H2)

End Sub



Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'If BinSaved = False Then
 '   MsgBox "The Current EEPROM has not been saved. Press OK to exit without Saving or Cancel to return to the program.", vbOKCancel + vbInformation, "EEPROM Not Saved"
    
'End If
End Sub

Private Sub Form_Unload(Cancel As Integer)
End
End Sub

Private Sub Guide_Byte_textbox_LostFocus()
Change_Guide_Byte
End Sub

Private Sub HCamSave_menu_Click()
Write_H_CamZKT
End Sub

Private Sub humap_munu_Click()
Load Form2
Form2.Show
End Sub

Private Sub load_HUCamZkt_Click()

If StoredCAM <> "" Then result = MsgBox("There is CAM/ZKT loaded in memory. Do you wish to overwirte it?", vbQuestion + vbYesNo, "Overwrte stored CAM/ZKT?")
If result = 7 Then Exit Sub
StoredCAM = Get_BIN_Data("040124D8")
StoredCAMLastByte = Get_BIN_Data("010024DC")
HUZKT = Get_BIN_Data("C0002550")
Label17.Caption = "* CAM " & GetFullCAM(StoredCAM) & " and its ZKT are stored in memory. *"
Write_HUCamZkt.Enabled = True

End Sub


Private Sub Disable_Options()

Check1.Enabled = False
ClearEEP_Pass_menu.Enabled = False
view_eeprom.Enabled = False
tierinfo_menu.Enabled = False
save_as_menu.Enabled = False
Clean_PPV_Menu.Visible = False
Clear_IRD_Menu.Enabled = False
Clean_EEPROM_Menu.Enabled = False
patch_hex_file_menu.Enabled = False
load_HUCamZkt.Enabled = False
Write_HUCamZkt.Enabled = False
camtools_menu.Enabled = False
WriteEEP_Menu.Enabled = False
Fix_4th_Byte_Menu.Enabled = False
Clear_EEP_Display

End Sub

Private Sub Enable_Options()

'Clean_PPV_Menu.Enabled = true
ClearEEP_Pass_menu.Enabled = True
Check1.Enabled = True
view_eeprom.Enabled = True
tierinfo_menu.Enabled = True
save_as_menu.Enabled = True
Clear_IRD_Menu.Enabled = True
Clean_EEPROM_Menu.Enabled = True
patch_hex_file_menu.Enabled = True
load_HUCamZkt.Enabled = True
camtools_menu.Enabled = True
WriteEEP_Menu.Enabled = True
Fix_4th_Byte_Menu.Enabled = True
If StoredCAM <> "" Then Write_HUCamZkt.Enabled = True

End Sub

Private Sub Clear_EEP_Display()

WP_StatusLabel.Caption = ""
CAM_textbox.Text = ""
IRD_textbox.Text = ""
Fusebytes_textbox.Text = ""
Ratings_Textbox.Text = ""
Guide_Byte_textbox.Text = ""
USW_TextBox.Text = ""
timezone_combo.Text = ""
zipcode_textbox.Text = ""
password_textbox.Text = ""
xor_key_textbox.Text = ""
slot1Purch_label.Caption = "$0.00"
slot1Limit_label.Caption = "$0.00"
slot2Purch_label.Caption = "$0.00"
slot2Limit_label.Caption = "$0.00"
ATR_Textbox.Text = ""


Bad_ATR = False


End Sub

Private Sub MsgWinNoClear_Menu_Click()
If MSFlexGrid1.TextMatrix(0, 1) = "Message Window" Then Exit Sub

MSFlexGrid1.Rows = 1
MSFlexGrid1.Rows = 513
MSFlexGrid1.ColWidth(1) = 7000
MSFlexGrid1.ColWidth(0) = 0
MSFlexGrid1.ScrollBars = flexScrollBarNone
MSFlexGrid1.Col = 1
MSFlexGrid1.Row = 6
MSFlexGrid1.CellForeColor = &HC000&
MSFlexGrid1.Col = 1
MSFlexGrid1.Row = 12
MSFlexGrid1.CellForeColor = &HC0&
MSFlexGrid1.TextMatrix(0, 1) = "Message Window"
    For X = 1 To 16
        MSFlexGrid1.TextMatrix(X, 1) = SavedMsgs(X)
    Next X
End Sub

Private Sub patch_hex_file_menu_Click()
patch_hex
End Sub

Private Sub prgramhlp_menu_Click()
Load Form6
Form6.Show

End Sub


Private Sub Ratings_Textbox_Click()
Change_Ratings
End Sub

Private Sub ReadDelayTMR_Timer()
ReadTimeOut = True
End Sub

Private Sub ReadEEP_Menu_Click()
Dim ReadAddr As Integer
Dim ByteString(128) As String
Dim EEP_Index As Integer
Dim WP_Check As String

Clear_EEP_Display
SetMsgWin
ReadAddr = &H2000
EEP_Index = 1



LoadBootStrap

If CheckForError = True Then Exit Sub

MSFlexGrid1.TextMatrix(7, 1) = "Reading EEPROM. Please Wait."
DoEvents
Do

Call WDTMR


HU_Write ("06C23F" & HexString(ReadAddr, 4) & "BF00")
temp1 = ReadHU(66)


ReadAddr = ReadAddr + 64
ByteString(EEP_Index) = Mid(ReturnFromLoader, 3)
EEP_Index = EEP_Index + 1

Loop Until ReadAddr > &H3FFF

    'Clean up
CloseLoader
MSFlexGrid1.TextMatrix(7, 1) = "EEPROM Read Complete."

i = 0
For X = 1 To 128
    For z = 1 To 64
    i = i + 1
    bin_file_data(i) = Asc(Mid(ByteString(X), z, 1))
    Next z
Next X

Get_Key

MSFlexGrid1.TextMatrix(9, 1) = "USW = " & Get_BIN_Data("010124C9")
MSFlexGrid1.TextMatrix(10, 1) = "Time Zone = " & Get_BIN_Data("010124E0")

WP_Check = Get_BIN_Data("03003830")
If WP_Check = "2200E6" Then MSFlexGrid1.TextMatrix(11, 1) = "Write Protection Is ON!"
If WP_Check = "8EDC0A" Then MSFlexGrid1.TextMatrix(11, 1) = "Write Protection Is OFF."

DoEvents
RemoveCard

Display_EEPROM_Info

End Sub

Private Sub RewmoceProtection_Menu_Click()
Dim UnProtectString As String

UnProtectString = FormatHUData("38308EDC0A")

SetMsgWin
LoadBootStrap
If CheckForError = True Then Exit Sub

WDTMR
HU_Write (UnProtectString)
ReadHU (2)
MSFlexGrid1.TextMatrix(7, 1) = "Write Protection Was Removed."
MSFlexGrid1.TextMatrix(8, 1) = "Operation Complete."
CloseLoader

End Sub

Private Sub Save_Normal_menu_Click()
SaveEEP_Info
Write_intel_hex
End Sub

Private Sub SaveASCII_Menu_Click()
SaveEEP_Info
Write_encoded_intel_hex
End Sub

Private Sub SaveBinFile_Menu_Click()
SaveEEP_Info
Write_HU_Bin
End Sub

Private Sub tierinfo_menu_Click()

If MSFlexGrid1.TextMatrix(0, 1) = "Message Window" Then
    For X = 1 To 16
        SavedMsgs(X) = MSFlexGrid1.TextMatrix(X, 1)
    Next X
End If

SetMsgWin
    MSFlexGrid1.Col = 1
    MSFlexGrid1.Row = 6
    MSFlexGrid1.CellForeColor = &H0&
    MSFlexGrid1.Col = 1
    MSFlexGrid1.Row = 12
    MSFlexGrid1.CellForeColor = &H0&
    MSFlexGrid1.ScrollBars = flexScrollBarVertical
ShowTeirs
End Sub



Private Sub timezone_combo_Click()
Change_TimeZone
End Sub

Private Sub view_eeprom_Click()

ViewDump
End Sub


Private Sub WrieHexToCard_menu_Click()

'NotInThisBeta
'Exit Sub

Dim patch_input(513) As String
Dim normal_hex_string As String
Dim End_of_String As Integer
Dim bytes_to_write As String
Dim Checksum_byte As String
Dim CAM_clone_check As String
Dim HexStringToWrite(512) As String
Dim WriteAddr As String
Dim ThisByte As String
Dim TempHexString As String
Dim Fname As String
Dim FuseOption As String
Dim GuideOption As String
Dim WP_Option As String

SetMsgWin

CommonDialog1.FileName = ""
CommonDialog1.Filter = "HEX Files (*.HEX)|*.HEX|All Files (*.*)|*.*"
CommonDialog1.ShowOpen      'display Open dialog box
If CommonDialog1.FileName = "" Then GoTo EndWriteHexFile
file_size = FileLen(CommonDialog1.FileName)
InputHexFile = CommonDialog1.FileName
Fname = CommonDialog1.FileTitle

Load WriteHexOptions
WriteHexOptions.Show 1
If CheckForError = True Then Exit Sub

MSFlexGrid1.TextMatrix(1, 1) = "Loading " & Fname
DoEvents

i = 1

Open InputHexFile For Input As #1
Do Until EOF(1)                                         'Open the file for reading
    Line Input #1, Patch_File
    If Left(Patch_File, 1) = ":" Then
        patch_input(i) = Patch_File
        i = i + 1
    End If
Loop
Close #1

    'check to see if this is an ascii encoded file.
    
If Asc(Mid(patch_input(1), 2, 1)) < 48 Or Asc(Mid(patch_input(1), 2, 1)) > 54 Then
    'convert file to nomal hex
    For X = 1 To i - 1
    normal_hex_string = ""
    temp1 = patch_input(X)
        For z = 2 To Len(temp1)
            Temp2 = Asc(Mid(temp1, z, 1))                                   'get the ascii code
            encoded_byte = Hex(Temp2 Xor 170)                               'XOr with 170 (Hex AA)
            If Len(encoded_byte) < 2 Then encoded_byte = "0" & encoded_byte
            encoded_byte = Right(encoded_byte, 1) & Left(encoded_byte, 1)   'Swap the digits
            Hexnumber = encoded_byte
            encoded_byte = HexToDec(Hexnumber)                              'convert to decimal
            encoded_byte = Chr(encoded_byte)                                'convert to normal Char.
            normal_hex_string = normal_hex_string & encoded_byte
        Next z
        patch_input(X) = ":" & normal_hex_string
    Next X
End If

    'check the hex file to make sure its valid
For X = 1 To i - 1
    End_of_String = Len(patch_input(X))
    End_of_String = End_of_String - 2
        'get the checksum that is in the file
    Checksum_byte = Right(patch_input(X), 2)
        'check to see if it is a good checksum. If not Abort!"
        
   If Checksum_byte <> Get_Checksum(Mid(patch_input(X), 1, End_of_String)) Then
        MSFlexGrid1.TextMatrix(12, 1) = "ERROR:  Invalid Hex File. Operation Aborted!"
        Exit Sub
    End If

Next X


    'get the cam id, so we can see if card has been cloned
'CAM_clone_check = Get_BIN_Data("040124D8")

    'assemble the data to write
Y = 0
For X = 1 To i - 2
    
    bytes_to_write = HexToDec(Mid(patch_input(X), 2, 2)) * 2
    WriteAddr = Mid(patch_input(X), 4, 4)
    data_to_write = Mid(patch_input(X), 10, bytes_to_write)
    TempHexString = WriteAddr & data_to_write
    HexStringToWrite(X) = FormatHUData(TempHexString)
MsgBox HexStringToWrite(X)
Next X

MSFlexGrid1.TextMatrix(1, 1) = "Ready to write " & Fname & " to the card."
DoEvents

result = MsgBox("You have requested to write " & Fname & " to the card. Do you wish to continue?", vbYesNo + vbQuestion, "Are You Sure?")
If result = 7 Then
    MSFlexGrid1.TextMatrix(12, 1) = "ERROR:  Operation Aborted By User."
    Exit Sub
End If

    'prepare write options
If WriteHexOptions.TurnOnFuseBytes.Value = 1 Then
    FuseOption = "25DA"
    Else: FuseOption = "20D0"
End If

If WriteHexOptions.TurnOnWP.Value = 1 Then
    WP_Option = "2200E6"
    Else: WP_Option = "8EDC0A"
End If

   

'LoadBootStrap
If CheckForError = True Then Exit Sub

    'write the data to the card
MSFlexGrid1.TextMatrix(7, 1) = "Writing " & Fname & " to card.  Please Wait...."
'For X = 1 To i - 2

'    WDTMR
 '   HU_Write (HexStringToWrite(X))
 '   ReadHU (2)

'Next X

GetKeysFromCard
HU_Write ("07C4812014" & FuseOption & "00")
ReadHU (2)

WDTMR
HU_Write ("08C5823830" & WP_Option & "00")
ReadHU (2)

WDTMR
If WriteHexOptions.TurnOnGuide.Value = 1 Then
    GuideOption = "80" & HexString(&H4D Xor HexToDec(CardKey(7)), 2)
    HU_Write ("07C481251E" & GuideOption & "00")
    ReadHU (2)
End If



MSFlexGrid1.TextMatrix(8, 1) = Fname & " Was Writen to the card."
DoEvents

CloseLoader

MSFlexGrid1.TextMatrix(9, 1) = "Write Operation Complete."
EndWriteHexFile:

End Sub

Private Sub Write_HUCamZkt_Click()

result = MsgBox("You are about to overwirte your currnt CAM/ZKT with the one that is stored in memory. Are you sure you want to do this?", vbExclamation + vbYesNo, "Change your CAM/ZKT?")
If result = 7 Then Exit Sub

Put_Bin_Data ("040124D8  " & StoredCAM)
Put_Bin_Data ("010024DC  " & StoredCAMLastByte)
Put_Bin_Data ("C0002550  " & HUZKT)

Display_EEPROM_Info
MsgBox "Your CAM and ZKT have been changed.", vbInformation, "Changed."


End Sub


Private Sub ViewDump()
Dim i As Integer
Dim dis_addr As Integer
Dim CellData As String
Dim col_addr As String

If MSFlexGrid1.TextMatrix(0, 1) = "Message Window" Then
    For X = 1 To 16
        SavedMsgs(X) = MSFlexGrid1.TextMatrix(X, 1)
    Next X
End If

Check1.Enabled = True
    MSFlexGrid1.Col = 1
    MSFlexGrid1.Row = 6
    MSFlexGrid1.CellForeColor = &H0&
    MSFlexGrid1.Col = 1
    MSFlexGrid1.Row = 12
    MSFlexGrid1.CellForeColor = &H0&
MSFlexGrid1.ScrollBars = flexScrollBarVertical

dis_addr = &H0
MSFlexGrid1.ColWidth(0) = 600
Form1.MousePointer = 11

For X = 1 To 16
MSFlexGrid1.ColWidth(X) = 330
If Len(Hex(dis_addr)) < 2 Then col_addr = " " & Hex(dis_addr)
MSFlexGrid1.TextMatrix(0, X) = col_addr
dis_addr = dis_addr + &H1
Next X
dis_addr = &H2000
For X = 1 To 512
MSFlexGrid1.TextMatrix(X, 0) = Hex(dis_addr)
dis_addr = dis_addr + &H10
Next X

If Check1.Value = 1 Then
    Check1_Click
    Exit Sub
End If
MSFlexGrid1.ScrollBars = flexScrollBarVertical
LoadBinData
End Sub

Sub LoadBinData()
i = 1
For X = 1 To 512

    For Y = 1 To 16
    CellData = Hex(bin_file_data(i))
    If Len(CellData) < 2 Then CellData = "0" & CellData
    MSFlexGrid1.CellAlignment = flexAlignLeftCenter
    MSFlexGrid1.TextMatrix(X, Y) = CellData
    i = i + 1
    Next Y
Next X
Form1.MousePointer = 0
End Sub

Sub Check_HU_ATR()
InsertCard
If CheckForError = True Then Exit Sub
Form1.MSFlexGrid1.TextMatrix(3, 1) = ""
HU_Write ("A1")
For X = 1 To 10
HU_Write ("06100E10019300")
ReturnData = ReadHU(22)
If Len(ReturnData) > 4 Then
        If Len(Mid(ReturnData, 5)) = 40 Then
            Form1.MSFlexGrid1.TextMatrix(4, 1) = "ATR: " & Mid(ReturnData, 5)
            Exit Sub
        End If
        If Len(Mid(ReturnData, 5)) = 2 Then
            Form1.MSFlexGrid1.TextMatrix(4, 1) = "ATR: " & Mid(ReturnData, 5)
            Exit Sub
            Else: Form1.MSFlexGrid1.TextMatrix(4, 1) = "ATR: " & Mid(ReturnData, 5)
        
        End If
    End If
Next X


End Sub

Sub SetMsgWin()
Check1.Enabled = False
MSFlexGrid1.Rows = 1
MSFlexGrid1.Rows = 513
MSFlexGrid1.ColWidth(1) = 7000
MSFlexGrid1.ColWidth(0) = 0
MSFlexGrid1.ScrollBars = flexScrollBarNone


MSFlexGrid1.TextMatrix(0, 1) = "Message Window"
For X = 1 To 25
MSFlexGrid1.TextMatrix(X, 1) = ""
Next X
    MSFlexGrid1.Col = 1
    MSFlexGrid1.Row = 6
    MSFlexGrid1.CellForeColor = &HC000&
    MSFlexGrid1.Col = 1
    MSFlexGrid1.Row = 12
    MSFlexGrid1.CellForeColor = &HC0&
End Sub

Sub ShowTeirs()

Dim TierData As String
Dim Tier As String
Dim DateCode As String
Dim TierDay As Integer
Dim TierDayText As String
Dim Tiermonth As Integer
Dim TierYear As Integer
Dim TierAddress As Integer
Dim TierNumber As String

TierAddress = &H2106
MSFlexGrid1.TextMatrix(0, 1) = "Tier Information"

For X = 1 To 20

TierData = Get_BIN_Data("0401" & Hex(TierAddress))
Tier = Left(TierData, 4)
Tier = Left(Tier, 2) & " " & Right(Tier, 2)
DateCode = Mid(TierData, 5, 4)
TierDay = HexToDec(Right(DateCode, 2)) - &HC0
If TierDay < 1 Then TierDayText = "00"
If TierDay > 1 And TierDay < 10 Then TierDayText = "0" & TierDay
If TierDay > 10 And TierDay < 31 Then TierDayText = TierDay

Tiermonth = HexToDec(Left(DateCode, 2)) Mod 12
TierYear = HexToDec(Left(DateCode, 2)) - Tiermonth
TierYear = (TierYear / 12) + 1992
TierNumber = X
If Len(TierNumber) < 2 Then TierNumber = " " & TierNumber
TierNumber = " " & TierNumber & ".  "


MSFlexGrid1.TextMatrix(X, 1) = TierNumber & Tier & "  " & TierMonthText(Tiermonth) & " " & TierYear & " Day " & TierDayText & "  (M=" & Left(DateCode, 2) & ", D=" & Right(DateCode, 2) & ")"
TierAddress = TierAddress + 6

Next X
End Sub

Private Sub LoadBootStrap()
    Dim RetValue As String
    Dim Length As Integer
    Dim GotInput As Boolean
    Dim DAC As String
    Dim ATRDAC As String
    Dim delay As String
    Dim Counter As Integer
    Dim Counter2 As Integer
    Dim Counter3 As Integer
    Dim counter4 As Integer
    Dim counter5 As Integer
    Dim Byte1 As String
    Dim Byte2 As String
    Dim Byte3 As String
    Dim Byte4 As String
    Dim Byte5 As String
    Dim Byte6 As String
    Dim Byte7 As String
    Dim Byte8 As String
    Dim Byte9 As String
    Dim XORedByte4 As String
    Dim XORedByte5 As String
    Dim XORedByte6 As String
    Dim XORedByte7 As String
    Dim XORedByte8 As String
    Dim XORedByte9 As String
    Dim ReturnString As String
    Dim ReturnData As String
    Dim OrigWrtDelay As Integer
    Dim GettingResponse As Boolean
    
    If Form7.AutoAdjust.Value = 1 Then Form7.WrtDly.Text = "40"
    OrigWrtDelay = Form7.WrtDly.Text
    conuter5 = 1
    
StartGlitching:

    GettingResponse = False
    Counter = 0
    Counter2 = 0
    Counter3 = 0
    counter4 = 0
    
    ATRDAC = &H70
    DAC = &H8C
    delay = &H1A
    
If CheckLoader = False Then Exit Sub

InsertCard
If CheckForError = True Then Exit Sub

Do
Form1.ChangeLoaderSettings.Visible = False
Form1.CraysStopButton.Visible = True
Form1.CraysStopButton.SetFocus
HU_Write ("A1")
GotInput = False

If Counter = 30 Then
Counter = 0
DAC = &H8C
delay = &H1A
End If

If Counter = 1 Then
GettingResponse = True
DAC = &H8C
delay = &H8E
End If
If Counter = 2 Then
DAC = &H8A
delay = &H1A
End If
If Counter = 3 Then
DAC = &H8A
delay = &H8E
End If
If Counter = 4 Then
DAC = &H88
delay = &H1A
End If
If Counter = 5 Then
DAC = &H88
delay = &H8E
End If
If Counter = 6 Then
DAC = &H86
delay = &H1A
End If
If Counter = 7 Then
DAC = &H86
delay = &H8E
End If
If Counter = 8 Then
DAC = &H84
delay = &H1A
End If
If Counter = 9 Then
DAC = &H84
delay = &H8E
End If
If Counter = 10 Then
DAC = &H82
delay = &H1A
End If
If Counter = 11 Then
DAC = &H82
delay = &H8E
End If
If Counter = 10 Then
DAC = &H82
delay = &H1A
End If
If Counter = 11 Then
DAC = &H82
delay = &H8E
End If
If Counter = 12 Then
DAC = &H80
delay = &H1A
End If
If Counter = 13 Then
DAC = &H80
delay = &H8E
End If
If Counter = 14 Then
DAC = &H7E
delay = &H1A
End If
If Counter = 15 Then
DAC = &H7E
delay = &H8E
End If
If Counter = 16 Then
DAC = &H7C
delay = &H1A
End If
If Counter = 17 Then
DAC = &H7C
delay = &H8E
End If
If Counter = 18 Then
DAC = &H7A
delay = &H1A
End If
If Counter = 19 Then
DAC = &H7A
delay = &H8E
End If
If Counter = 20 Then
DAC = &H78
delay = &H1A
End If
If Counter = 21 Then
DAC = &H78
delay = &H8E
End If
If Counter = 22 Then
DAC = &H76
delay = &H1A
End If
If Counter = 23 Then
DAC = &H76
delay = &H8E
End If
If Counter = 24 Then
DAC = &H74
delay = &H1A
End If
If Counter = 25 Then
DAC = &H74
delay = &H8E
End If
If Counter = 26 Then
DAC = &H72
delay = &H1A
End If
If Counter = 27 Then
DAC = &H72
delay = &H8E
End If
If Counter = 28 Then
DAC = &H70
delay = &H1A
End If
If Counter = 29 Then
DAC = &H70
delay = &H8E
Counter2 = Counter2 + 1
End If

If Counter2 = 5 Then
Counter2 = 0
ATRDAC = &H70
End If

If Counter2 = 2 Then
ATRDAC = &H78
End If
If Counter2 = 3 Then
ATRDAC = &H80
End If
If Counter2 = 4 Then
ATRDAC = &H88
End If



Do


counter4 = counter4 + 1

MSFlexGrid1.TextMatrix(3, 1) = "Trying Glitch Setting: " & HexString(DAC, 2) & " " & HexString(delay, 2) & "  Attempt: " & counter4
Form1.MSFlexGrid1.TextMatrix(2, 1) = "Write Delay = " & Form7.WrtDly.Text

If counter4 = 80 And Form7.AutoAdjust.Value = 0 Then
    Form1.MSFlexGrid1.TextMatrix(15, 1) = "The program is having trouble glitching your"
    Form1.MSFlexGrid1.TextMatrix(16, 1) = "card.  You may want to try changing the "
    Form1.MSFlexGrid1.TextMatrix(17, 1) = "Write Delay option."
End If

If counter4 = 50 And Form7.AutoAdjust.Value = 1 And counter5 < 6 Then
    Form7.WrtDly.Text = Form7.WrtDly.Text + 1
    Form1.MSFlexGrid1.TextMatrix(16, 1) = "Adjusted Write Delay to " & Form7.WrtDly.Text
    counter5 = counter5 + 1
    GoTo StartGlitching
End If

If counter4 = 50 And Form7.AutoAdjust.Value = 1 And counter5 >= 6 Then
        If counter5 = 6 Then Form7.WrtDly.Text = OrigWrtDelay
    Form7.WrtDly.Text = Form7.WrtDly.Text - 1
    Form1.MSFlexGrid1.TextMatrix(16, 1) = "Adjusted Write Delay to " & Form7.WrtDly.Text
    counter5 = counter5 + 1
    GoTo StartGlitching
End If

If counter5 = 12 Then
    Form1.MSFlexGrid1.TextMatrix(12, 1) = "ERROR:  Could Not Load Boot Mode!"
    Form1.MSFlexGrid1.TextMatrix(16, 1) = ""
    CloseLoader
    Exit Sub
End If


DoEvents
HU_Write ("A1")

If Counter3 = 40 Then
ATRDAC = &H70
Counter = 0
End If

If Counter3 = 10 Then
ATRDAC = &H78
End If
If Counter3 = 20 Then
ATRDAC = &H80
End If
If Counter3 = 30 Then
ATRDAC = &H88
End If
If Counter3 = 49 Then
    CloseLoader
    Form1.CraysStopButton.Visible = False
    If GettingResponse = False Then
        MSFlexGrid1.TextMatrix(12, 1) = "ERROR:" & "   Can't get good ATR from card!"
        Else
        MSFlexGrid1.TextMatrix(12, 1) = "ERROR:" & "   Cant Load Boot Mode!"
    End If
Exit Sub
End If

HU_Write ("B0")
HU_Write (HexString(ATRDAC, 2)) '70, 78, 80, 88

    'reset the card
HU_Write ("06100E10019300")
WriteDelay
ReturnData = ReadHU(22)

If Cray_Stop = True Then
    MSFlexGrid1.TextMatrix(12, 1) = "ERROR:" & "   Stop Button Pressed By User."
    MSFlexGrid1.TextMatrix(13, 1) = "It is now safe to remove the card."
    Form1.CraysStopButton.Visible = False
    Form1.ChangeLoaderSettings.Visible = True
    CloseLoader
    Exit Sub
End If

MSFlexGrid1.TextMatrix(4, 1) = "ATR: " & Mid(ReturnData, 5)

DoEvents

HU_Write ("0B100E03018520004209BF00")
WriteDelay
ReadHU (&H48)

        RetValue = GetByteFromHU(1)  ' see how many bytes the loader returned

        If RetValue = &H46 Then   ' needs to be &H46
        Byte4 = GetByteFromHU(61 + 2)
        Byte5 = GetByteFromHU(62 + 2)
        Byte6 = GetByteFromHU(63 + 2)
        Byte7 = GetByteFromHU(64 + 2)
        Byte8 = GetByteFromHU(65 + 2)
        GotInput = True
        Else
        GotInput = False
        Counter3 = Counter3 + 1
        End If
        Loop Until GotInput = True
        GotInput = False

HU_Write ("02BF00")
WriteDelay
ReadHU (&H42)
        

HU_Write ("02BF00")
WriteDelay
ReadHU (&H42)
        RetValue = GetByteFromHU(1)
        If RetValue = &H40 Then     ' see how many bytes the loader returned
        Byte1 = GetByteFromHU(44 + 2)
        Byte2 = GetByteFromHU(45 + 2)
        Byte3 = GetByteFromHU(46 + 2)
        Byte9 = Byte1
        Else
        End If


HU_Write ("02BF00")
WriteDelay
ReadHU (&H42)


HU_Write ("028700")
WriteDelay
ReadHU (10)


HU_Write ("B0")
HU_Write (HexString(DAC, 2))
HU_Write ("0F1AC4485E000A01822000230C" & HexString(delay, 2) & "8100")
WriteDelay
ReadHU (7)


HU_Write ("0915C4484C0000098000")
WriteDelay
ReadHU (3)



On Error GoTo NotYet
XORedByte4 = HexString(Byte4 Xor &HC4, 2)
XORedByte5 = HexString(Byte5 Xor &HF, 2)
XORedByte6 = HexString(Byte6 Xor &HC0, 2)
XORedByte7 = HexString(Byte7 Xor &HDC, 2)
XORedByte8 = HexString(Byte8 Xor &HC4, 2)
XORedByte9 = HexString(Byte9 Xor &H26, 2)

HU_Write ("0CC9" & HexString(Byte1, 2) & HexString(Byte2, 2) & HexString(Byte3, 2) & XORedByte4 & XORedByte5 & XORedByte6 & XORedByte7 & XORedByte8 & XORedByte9 & "0000")
WriteDelay
ReadHU (2)

    'clear buffer of any data
If Form1.MSComm1.InBufferCount > 0 Then
ClearBuffer
Else
End If

HU_Write ("34F00000000069FFFFFFFF523FFD2284E172400772FF14C5E2AB0100C3DA07F88C0100000000000000000000000000000000008000")
WriteDelay
ReadHU (3)
        If GetByteFromHU(&H0) = &H34 Then
            If GetByteFromHU(&H1) = &H1 Then
                If GetByteFromHU(&H2) = &H84 Then
                    GotInput = True
                    MSFlexGrid1.TextMatrix(6, 1) = "Boot Strap Has Been Loaded......"
                    Else
                    GotInput = False
                End If
                
            End If
        End If
NotYet: Counter = Counter + 1
        Loop Until GotInput = True

HU_Write ("42FF225272FF14E1E2D007E2D029E2D02A77800718753F07D307D807C5E2AB0060C3DA07F8726015D404E700D57640070DD3078ECEFB70012ADA07F700C49E2A00FA00")
WriteDelay
ReadHU (2)
ClearBuffer
Form1.CraysStopButton.Visible = False
Form1.ChangeLoaderSettings.Visible = True
Form1.MSFlexGrid1.TextMatrix(15, 1) = ""
Form1.MSFlexGrid1.TextMatrix(16, 1) = ""
Form1.MSFlexGrid1.TextMatrix(17, 1) = ""




End Sub

Sub RemoveCard()

If IsCardPresent <> "FF" Then Exit Sub
MSFlexGrid1.TextMatrix(13, 1) = "Please Remove Card To Continue."
MSFlexGrid1.TextMatrix(14, 1) = "You will automaticly be switched to"
MSFlexGrid1.TextMatrix(15, 1) = "the EEPROM Display once card is removed."
DoEvents
Do
'wait for card to be pulled
DoEvents
Loop Until IsCardPresent <> "FF"


End Sub

Sub InsertCard()
Dim CardTimeOut As Integer

MSFlexGrid1.TextMatrix(2, 1) = "Please Insert Card."
DoEvents
CardTimeOut = 0

Do
CardTimeOut = CardTimeOut + 1

Loop Until IsCardPresent = "FF" Or CardTimeOut = 2000
DoEvents
If CardTimeOut = 2000 Then MSFlexGrid1.TextMatrix(12, 1) = "ERROR:   Time Out While Waiting For Card"
DoEvents
End Sub


Private Sub WriteEEP_Menu_Click()

Dim HexStringToWrite(256) As String
Dim WriteAddr As Integer
Dim EEP_Index As Integer
Dim ThisByte As String
Dim TempHexString As String

SaveEEP_Info

SetMsgWin

result = MsgBox("You have requested to write the current EEPROM to the card. Do you wish to continue?", vbYesNo + vbQuestion, "Are You Sure?")
If result = 7 Then
    MSFlexGrid1.TextMatrix(12, 1) = "ERROR:  Operation Aborted By User."
    Exit Sub
End If

EEP_Index = 0
TempHexString = ""
WriteAddr = &H2000

MSFlexGrid1.TextMatrix(1, 1) = "Preparing The Data."

For i = 1 To 256
    For X = 1 To 32
        ThisByte = Hex(bin_file_data(EEP_Index + X))
        If Len(ThisByte) < 2 Then ThisByte = "0" & ThisByte
        TempHexString = TempHexString & ThisByte
    Next X
    EEP_Index = EEP_Index + 32
    addr = Hex(addr_hex)
    TempHexString = "25E29F" & HexString(WriteAddr, 2) & TempHexString & "00"
    HexStringToWrite(i) = TempHexString
    WriteAddr = WriteAddr + &H20
    TempHexString = ""

Next i


WriteAddr = &H2000



LoadBootStrap
If CheckForError = True Then Exit Sub

MSFlexGrid1.TextMatrix(7, 1) = "Writing EEPROM. Please Wait..."
DoEvents

For i = 1 To 256

Call WDTMR

HU_Write (HexStringToWrite(i))
WriteDelay
'MSFlexGrid1.TextMatrix(7, 1) = "Writing 32 Bytes at Address: " & HexString(WriteAddr, 4)
ReadHU (2)
WriteAddr = WriteAddr + &H20
Next i

    
    'Clean up
CloseLoader
MSFlexGrid1.TextMatrix(7, 1) = "EEPROM Write Complete."

End Sub

Sub GetKeysFromCard()

Dim Byte1a As Integer
Dim Byte1b As Integer
Dim Byte2a As Integer
Dim Byte2b As Integer
Dim Byte3a As Integer
Dim Byte3b As Integer
Dim Byte4a As Integer
Dim Byte4b As Integer
Dim Byte5a As Integer
Dim Byte5b As Integer
Dim Byte6a As Integer
Dim Byte6b As Integer
Dim Byte7a As Integer
Dim Byte7b As Integer
Dim Byte8a As Integer
Dim Byte8b As Integer

Call WDTMR
MSFlexGrid1.TextMatrix(7, 1) = "Extracting Keys."
HU_Write ("06C20724C08800")
ReadHU (10)

        Byte1a = GetByteFromHU(2)
        Byte2a = GetByteFromHU(3)
        Byte3a = GetByteFromHU(4)
        Byte4a = GetByteFromHU(5)
        Byte5a = GetByteFromHU(6)
        Byte6a = GetByteFromHU(7)
        Byte7a = GetByteFromHU(8)
        Byte8a = GetByteFromHU(9)

HU_Write ("06C20726588800")
ReadHU (10)

        Byte1b = GetByteFromHU(2)
        Byte2b = GetByteFromHU(3)
        Byte3b = GetByteFromHU(4)
        Byte4b = GetByteFromHU(5)
        Byte5b = GetByteFromHU(6)
        Byte6b = GetByteFromHU(7)
        Byte7b = GetByteFromHU(8)
        Byte8b = GetByteFromHU(9)

CardKey(0) = HexString(Byte1a Xor Byte1b, 2)
CardKey(1) = HexString(Byte2a Xor Byte2b, 2)
CardKey(2) = HexString(Byte3a Xor Byte3b, 2)
CardKey(3) = HexString(Byte4a Xor Byte4b, 2)
CardKey(4) = HexString(Byte5a Xor Byte5b, 2)
CardKey(5) = HexString(Byte6a Xor Byte6b, 2)
CardKey(6) = HexString(Byte7a Xor Byte7b, 2)
CardKey(7) = HexString(Byte8a Xor Byte8b, 2)
CardKeyString = CardKey(0) & CardKey(0) & CardKey(1) & CardKey(2) & CardKey(3) & CardKey(4) & CardKey(5) & CardKey(6) & CardKey(7)


MSFlexGrid1.TextMatrix(8, 1) = "XOR Key = " & CardKeyString


End Sub

Sub UpdateStatus()

MSFlexGrid1.TextMatrix(7, 1) = MSFlexGrid1.TextMatrix(7, 1) & "."
DoEvents
WDTMR
End Sub

