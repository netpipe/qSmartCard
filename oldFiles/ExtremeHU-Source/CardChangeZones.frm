VERSION 5.00
Begin VB.Form CardChangeZones 
   Caption         =   "Change Time Zone"
   ClientHeight    =   2205
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4290
   Icon            =   "CardChangeZones.frx":0000
   LinkTopic       =   "Form7"
   ScaleHeight     =   2205
   ScaleWidth      =   4290
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command2 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   2640
      TabIndex        =   3
      Top             =   1560
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   375
      Left            =   2640
      TabIndex        =   2
      Top             =   960
      Width           =   1095
   End
   Begin VB.ComboBox timezone_combo 
      BackColor       =   &H8000000F&
      Height          =   315
      ItemData        =   "CardChangeZones.frx":0442
      Left            =   240
      List            =   "CardChangeZones.frx":0458
      MousePointer    =   1  'Arrow
      TabIndex        =   0
      Text            =   "A6 - Eastern"
      Top             =   960
      Width           =   1815
   End
   Begin VB.Label Label1 
      Caption         =   "Select the Time Zone you wish to write to the card."
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   3975
      WordWrap        =   -1  'True
   End
End
Attribute VB_Name = "CardChangeZones"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
CardChangeZones.Hide
End Sub

Private Sub Command2_Click()
Text2.Text = "ERROR:  Operation Aborted By User."
CardChangeZones.Hide
End Sub
