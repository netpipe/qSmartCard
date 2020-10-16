VERSION 5.00
Begin VB.Form Form6 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Help for HU EEPROM Utility"
   ClientHeight    =   6000
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6795
   Icon            =   "help.frx":0000
   LinkTopic       =   "Form6"
   MaxButton       =   0   'False
   ScaleHeight     =   6000
   ScaleWidth      =   6795
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox Text1 
      Height          =   4575
      Left            =   240
      MultiLine       =   -1  'True
      TabIndex        =   1
      Text            =   "help.frx":0442
      Top             =   240
      Width           =   6255
   End
   Begin VB.CommandButton C 
      Caption         =   "OK"
      Height          =   495
      Left            =   2760
      TabIndex        =   0
      Top             =   5160
      Width           =   1095
   End
End
Attribute VB_Name = "Form6"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub C_Click()
Form6.Hide
End Sub

Private Sub Form_Load()
Text1.Text = "Hello and welcome to Basic HU" & vbCrLf & "this is a test" & vbCrLf & vbCrLf & " i think it might work"

End Sub

