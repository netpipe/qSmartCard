VERSION 5.00
Begin VB.Form Form2 
   Caption         =   "Time Zone"
   ClientHeight    =   4530
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   6630
   LinkTopic       =   "Form2"
   ScaleHeight     =   4530
   ScaleWidth      =   6630
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame3 
      Caption         =   "Card Status"
      Height          =   855
      Left            =   3360
      TabIndex        =   30
      Top             =   2160
      Width           =   3135
      Begin VB.Label WP_StatusLabel 
         Caption         =   "Write Protection:"
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
         Left            =   120
         TabIndex        =   34
         Top             =   240
         Width           =   1695
      End
      Begin VB.Label CMD90Label 
         Caption         =   "Cmd90 Blocking:"
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
         Left            =   120
         TabIndex        =   33
         Top             =   480
         Width           =   1695
      End
      Begin VB.Label WP_OnOffLabel 
         Caption         =   "OFF"
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
         Left            =   1800
         TabIndex        =   32
         Top             =   240
         Width           =   975
      End
      Begin VB.Label cmd90Status 
         Caption         =   "OFF"
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
         Left            =   1800
         TabIndex        =   31
         Top             =   480
         Width           =   975
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "PPV Purchase Info"
      Height          =   1935
      Left            =   3360
      TabIndex        =   23
      Top             =   120
      Width           =   3135
      Begin VB.CommandButton Command1 
         Caption         =   "OK"
         Height          =   345
         Left            =   1560
         TabIndex        =   36
         Top             =   1440
         Width           =   1155
      End
      Begin VB.TextBox chage_ppv_limt_textbox 
         BackColor       =   &H8000000F&
         Height          =   345
         Left            =   240
         TabIndex        =   35
         Text            =   "Text1"
         Top             =   1440
         Width           =   780
      End
      Begin VB.Label Label1 
         Caption         =   "Your current PPV purchase limit is listed below. The dollar amount can be set from $10 to $80."
         Height          =   420
         Left            =   240
         TabIndex        =   37
         Top             =   960
         Width           =   2535
      End
      Begin VB.Label Label10 
         Caption         =   "Slot 1"
         Height          =   255
         Left            =   240
         TabIndex        =   29
         Top             =   480
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
         Left            =   1080
         TabIndex        =   28
         Top             =   240
         Width           =   975
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
         Left            =   2280
         TabIndex        =   27
         Top             =   240
         Width           =   615
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
         Left            =   240
         TabIndex        =   26
         Top             =   240
         Width           =   495
      End
      Begin VB.Label slot2Purch_label 
         Caption         =   "$0.00"
         Height          =   255
         Left            =   1080
         TabIndex        =   25
         Top             =   465
         Width           =   855
      End
      Begin VB.Label slot2Limit_label 
         Caption         =   "$0.00"
         Height          =   255
         Left            =   2280
         TabIndex        =   24
         Top             =   480
         Width           =   735
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "EEPROM Info"
      Height          =   4305
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   3135
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
         TabIndex        =   11
         Top             =   3600
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
         TabIndex        =   10
         Top             =   360
         Width           =   1815
      End
      Begin VB.TextBox IRD_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   9
         Top             =   720
         Width           =   1815
      End
      Begin VB.TextBox Fusebytes_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   8
         Top             =   1080
         Width           =   1815
      End
      Begin VB.ComboBox timezone_combo 
         BackColor       =   &H8000000F&
         Height          =   315
         ItemData        =   "Form2.frx":0000
         Left            =   1200
         List            =   "Form2.frx":0016
         MousePointer    =   1  'Arrow
         TabIndex        =   7
         Top             =   2880
         Width           =   1830
      End
      Begin VB.TextBox zipcode_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         MaxLength       =   5
         TabIndex        =   6
         ToolTipText     =   "To change zip code enter the new zip here."
         Top             =   3240
         Width           =   1815
      End
      Begin VB.TextBox USW_TextBox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   5
         Top             =   2520
         Width           =   1830
      End
      Begin VB.TextBox Guide_Byte_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         MaxLength       =   2
         TabIndex        =   4
         ToolTipText     =   "To change the guide byte, enter the new guide byte here."
         Top             =   1800
         Width           =   1815
      End
      Begin VB.TextBox xor_key_textbox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         MousePointer    =   1  'Arrow
         TabIndex        =   3
         Top             =   3960
         Width           =   1815
      End
      Begin VB.ComboBox Ratings_Textbox 
         BackColor       =   &H8000000F&
         Height          =   315
         ItemData        =   "Form2.frx":0075
         Left            =   1200
         List            =   "Form2.frx":0094
         MousePointer    =   1  'Arrow
         TabIndex        =   2
         Top             =   1440
         Width           =   1815
      End
      Begin VB.ComboBox LocalsComboBox 
         BackColor       =   &H8000000F&
         Height          =   315
         ItemData        =   "Form2.frx":0102
         Left            =   1200
         List            =   "Form2.frx":0104
         TabIndex        =   1
         Top             =   2145
         Width           =   1830
      End
      Begin VB.Label C 
         Caption         =   "Card ID"
         Height          =   255
         Left            =   120
         TabIndex        =   22
         Top             =   375
         Width           =   855
      End
      Begin VB.Label T 
         Caption         =   "Time Zone"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   2895
         Width           =   855
      End
      Begin VB.Label Label3 
         Caption         =   "Password"
         Height          =   255
         Left            =   120
         TabIndex        =   20
         Top             =   3600
         Width           =   855
      End
      Begin VB.Label Label4 
         Caption         =   "IRD Number"
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   735
         Width           =   975
      End
      Begin VB.Label Label5 
         Caption         =   "Fuse Bytes"
         Height          =   255
         Left            =   120
         TabIndex        =   18
         Top             =   1095
         Width           =   855
      End
      Begin VB.Label Label7 
         Caption         =   "Zip Code"
         Height          =   255
         Left            =   120
         TabIndex        =   17
         Top             =   3240
         Width           =   855
      End
      Begin VB.Label Label6 
         Caption         =   "USW"
         Height          =   255
         Left            =   120
         TabIndex        =   16
         Top             =   2550
         Width           =   855
      End
      Begin VB.Label Label8 
         Caption         =   "Guide Byte"
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   1815
         Width           =   1065
      End
      Begin VB.Label Label14 
         Caption         =   "XOR Key"
         Height          =   255
         Left            =   105
         TabIndex        =   14
         Top             =   3990
         Width           =   975
      End
      Begin VB.Label Label15 
         Caption         =   "Ratings Limit"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   1470
         Width           =   975
      End
      Begin VB.Label L 
         Caption         =   "Locals Byte"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   2190
         Width           =   1020
      End
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()

If changed = True Then
    
    
    If PPV_Limit_Change < 10 Then PPV_Limit_Change = 10
    PPV_Limit_Change = Hex(PPV_Limit_Change * 100 + 1)
    If Len(PPV_Limit_Change) < 4 Then PPV_Limit_Change = "0" & PPV_Limit_Change
    If Len(PPV_Limit_Change) < 4 Then PPV_Limit_Change = "0" & PPV_Limit_Change
    
    LimitByte1 = Left(PPV_Limit_Change, 2)
    LimitByte2 = Right(PPV_Limit_Change, 2)
    
    Put_Bin_Data ("0201241E  " & LimitByte1 & LimitByte2)
    
    Else:
End If




Finished_with_limits:

End Sub

Private Sub Form_Load()
changed = False
PPV_Limit_Change = ""
chage_ppv_limt_textbox.Text = Form2.slot2Limit_label.Caption
End Sub

Sub UpDown1_Change()

Dim temp_limit As String
changed = True
temp_limit = chage_ppv_limt_textbox.Text
temp_limit = "$" & temp_limit & ".00"
chage_ppv_limt_textbox.Text = temp_limit

PPV_Limit_Change = UpDown1.Value
End Sub

