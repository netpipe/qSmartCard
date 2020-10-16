VERSION 5.00
Begin VB.Form Form9 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Chage Area Info"
   ClientHeight    =   2790
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4035
   Icon            =   "Form9.frx":0000
   LinkTopic       =   "Form9"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2790
   ScaleWidth      =   4035
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command2 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   2280
      TabIndex        =   5
      Top             =   2280
      Width           =   1335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Write To Card"
      Height          =   375
      Left            =   360
      TabIndex        =   4
      Top             =   2280
      Width           =   1335
   End
   Begin VB.Frame Frame1 
      Caption         =   "Area Options"
      Height          =   1845
      Left            =   225
      TabIndex        =   0
      Top             =   240
      Width           =   3570
      Begin VB.TextBox CardZip_TextBox 
         BackColor       =   &H8000000F&
         Height          =   285
         Left            =   1440
         MaxLength       =   5
         TabIndex        =   3
         Text            =   "58801"
         Top             =   1320
         Width           =   855
      End
      Begin VB.ComboBox timezone_combo 
         BackColor       =   &H8000000F&
         Height          =   315
         ItemData        =   "Form9.frx":0442
         Left            =   1440
         List            =   "Form9.frx":0458
         MousePointer    =   1  'Arrow
         TabIndex        =   2
         Text            =   "A6 - Eastern"
         Top             =   840
         Width           =   1830
      End
      Begin VB.ComboBox LocalsComboBox 
         BackColor       =   &H8000000F&
         Height          =   315
         ItemData        =   "Form9.frx":04B7
         Left            =   1440
         List            =   "Form9.frx":04B9
         TabIndex        =   1
         Text            =   "00 - No Locals"
         Top             =   360
         Width           =   1830
      End
      Begin VB.Label Label3 
         Caption         =   "Zip Code"
         Height          =   255
         Left            =   300
         TabIndex        =   8
         Top             =   1335
         Width           =   975
      End
      Begin VB.Label Label2 
         Caption         =   "Time Zone"
         Height          =   255
         Left            =   300
         TabIndex        =   7
         Top             =   855
         Width           =   975
      End
      Begin VB.Label Label1 
         Caption         =   "Locals Byte"
         Height          =   255
         Left            =   300
         TabIndex        =   6
         Top             =   375
         Width           =   1095
      End
   End
End
Attribute VB_Name = "Form9"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Form9.Hide
End Sub

Private Sub Command2_Click()
Form1.Text2.Text = "ERROR:  Operation Canceled By User."
Form9.Hide
End Sub


Private Sub Form_Unload(Cancel As Integer)
Form1.Text2.Text = "ERROR:  Operation Canceled By User."
End Sub
