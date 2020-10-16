VERSION 5.00
Begin VB.Form Form7 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Loader Settings"
   ClientHeight    =   2895
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3225
   Icon            =   "ChangeLoaderSettings.frx":0000
   LinkTopic       =   "Form7"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2895
   ScaleWidth      =   3225
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton SetDefaults 
      Caption         =   "Defaults"
      Height          =   375
      Left            =   1920
      TabIndex        =   11
      Top             =   2400
      Width           =   855
   End
   Begin VB.CommandButton SaveLoaderSettings 
      Caption         =   "Save"
      Height          =   375
      Left            =   360
      TabIndex        =   0
      Top             =   2400
      Width           =   855
   End
   Begin VB.ComboBox COMPort_Box 
      Height          =   315
      ItemData        =   "ChangeLoaderSettings.frx":0442
      Left            =   1680
      List            =   "ChangeLoaderSettings.frx":0452
      TabIndex        =   2
      Text            =   "COM1:"
      Top             =   840
      Width           =   975
   End
   Begin VB.TextBox WrtDly 
      Alignment       =   2  'Center
      Height          =   285
      Left            =   1695
      MaxLength       =   3
      TabIndex        =   1
      Text            =   "80"
      Top             =   360
      Width           =   405
   End
   Begin VB.Frame Frame1 
      Caption         =   "Settings"
      Height          =   2190
      Left            =   150
      TabIndex        =   3
      Top             =   105
      Width           =   2895
      Begin VB.TextBox GlitchAttempts_txtbox 
         Alignment       =   2  'Center
         BeginProperty DataFormat 
            Type            =   1
            Format          =   "0"
            HaveTrueFalseNull=   0
            FirstDayOfWeek  =   0
            FirstWeekOfYear =   0
            LCID            =   1033
            SubFormatType   =   1
         EndProperty
         Height          =   315
         Left            =   1515
         MaxLength       =   2
         TabIndex        =   10
         Text            =   "7"
         Top             =   1665
         Width           =   330
      End
      Begin VB.ComboBox GlitchStart_Combo 
         Height          =   315
         ItemData        =   "ChangeLoaderSettings.frx":0472
         Left            =   1515
         List            =   "ChangeLoaderSettings.frx":04D0
         TabIndex        =   7
         Text            =   "8C  1A"
         Top             =   1200
         Width           =   975
      End
      Begin VB.CheckBox AutoAdjust 
         Caption         =   "Auto Adjust Write Delay"
         Height          =   225
         Left            =   60
         TabIndex        =   6
         Top             =   510
         Visible         =   0   'False
         Width           =   2220
      End
      Begin VB.Label Label4 
         Alignment       =   2  'Center
         Caption         =   "Attempts At Each Glitch Point"
         Height          =   420
         Left            =   180
         TabIndex        =   9
         Top             =   1635
         Width           =   1230
      End
      Begin VB.Label Label3 
         Alignment       =   1  'Right Justify
         Caption         =   "Start Glitching At:"
         Height          =   300
         Left            =   105
         TabIndex        =   8
         Top             =   1245
         Width           =   1305
      End
      Begin VB.Label Label2 
         Alignment       =   1  'Right Justify
         Caption         =   "COM Port"
         Height          =   270
         Left            =   165
         TabIndex        =   5
         Top             =   810
         Width           =   1170
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Right Justify
         Caption         =   "Write Delay"
         Height          =   270
         Left            =   480
         TabIndex        =   4
         Top             =   285
         Width           =   900
      End
   End
End
Attribute VB_Name = "Form7"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub AutoAdjust_Click()
'If AutoAdjust.Value = 1 Then Form7.WrtDly.Enabled = False
'If AutoAdjust.Value = 0 Then Form7.WrtDly.Enabled = True
End Sub


Private Sub Form_Load()

LoadINI
AutoAdjust.Value = 0
Form7.WrtDly.Enabled = True

End Sub

Private Sub SaveLoaderSettings_Click()
Form7.WrtDly.Text = 85
Form7.COMPort_Box.Text = "COM1:"
Form7.AutoAdjust.Value = 0
Form7.GlitchStart_Combo.ListIndex = 0
Form7.GlitchAttempts_txtbox.Text = 7
On Error GoTo ComError
If Form1.MSComm1.PortOpen = True Then Form1.MSComm1.PortOpen = False
Form1.MSComm1.CommPort = Mid(Form7.COMPort_Box.Text, 4, 1)
Form1.MSComm1.PortOpen = True
Form1.MSComm1.RThreshold = ReturnBytes
GoTo CommChanged

ComError:
Text2.Text = "ERROR:  Cant Open " & Form7.COMPort_Box.Text

CommChanged:

Form7.Hide
End Sub

Private Sub SetDefaults_Click()
Form7.WrtDly.Text = 85
Form7.COMPort_Box.Text = "COM1:"
Form7.AutoAdjust.Value = 0
Form7.GlitchStart_Combo.ListIndex = 0
Form7.GlitchAttempts_txtbox.Text = 7
End Sub


Private Sub WrtDly_LostFocus()
If Form7.WrtDly.Text < 80 Then Form7.WrtDly.Text = 80
End Sub
