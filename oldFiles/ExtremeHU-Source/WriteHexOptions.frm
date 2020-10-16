VERSION 5.00
Begin VB.Form WriteHexOptions 
   Caption         =   "Hex File Options"
   ClientHeight    =   2670
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   3030
   Icon            =   "WriteHexOptions.frx":0000
   LinkTopic       =   "Form7"
   ScaleHeight     =   2670
   ScaleWidth      =   3030
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command2 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   1830
      TabIndex        =   5
      Top             =   2160
      Width           =   975
   End
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   375
      Left            =   240
      TabIndex        =   4
      Top             =   2160
      Width           =   975
   End
   Begin VB.Frame Frame1 
      Caption         =   "Write Options"
      Height          =   1740
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   2655
      Begin VB.CheckBox Key12ByteWrite_Check 
         Caption         =   "Write 12 Byte Key"
         Height          =   255
         Left            =   240
         TabIndex        =   6
         Top             =   1080
         Value           =   1  'Checked
         Width           =   1935
      End
      Begin VB.CheckBox TurnOnWP 
         Caption         =   "Turn Write Protection ON"
         Height          =   255
         Left            =   225
         TabIndex        =   3
         Top             =   1440
         Visible         =   0   'False
         Width           =   2415
      End
      Begin VB.CheckBox TurnOnGuide 
         Caption         =   "Turn Guide ON"
         Height          =   255
         Left            =   240
         TabIndex        =   2
         Top             =   720
         Value           =   1  'Checked
         Width           =   1935
      End
      Begin VB.CheckBox TurnOnFuseBytes 
         Caption         =   "Turn Fuse Bytes ON"
         Height          =   255
         Left            =   240
         TabIndex        =   1
         Top             =   360
         Value           =   1  'Checked
         Width           =   2055
      End
   End
End
Attribute VB_Name = "WriteHexOptions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
WriteHexOptions.Hide
CancelError = False
End Sub

Private Sub Command2_Click()
'Form1.MSFlexGrid1.TextMatrix(12, 1) = "ERROR:  Operation Aborted By User."
CancelError = True

WriteHexOptions.Hide

End Sub


Private Sub Form_Activate()
WriteHexOptions.TurnOnFuseBytes.Value = 1
WriteHexOptions.TurnOnGuide.Value = 1
WriteHexOptions.Key12ByteWrite_Check.Value = 1
WriteHexOptions.TurnOnWP.Value = 0
End Sub

