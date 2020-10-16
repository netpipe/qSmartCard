VERSION 5.00
Begin VB.Form Form5 
   Caption         =   "About"
   ClientHeight    =   2835
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   3480
   Icon            =   "About.frx":0000
   LinkTopic       =   "Form5"
   ScaleHeight     =   2835
   ScaleWidth      =   3480
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   375
      Left            =   1080
      TabIndex        =   0
      Top             =   2400
      Width           =   1455
   End
   Begin VB.Label Label4 
      Caption         =   "#dssware #echoware #hu helper"
      Height          =   255
      Left            =   360
      TabIndex        =   4
      Top             =   2040
      Width           =   2415
   End
   Begin VB.Label Label3 
      Caption         =   "Server = Nechat.cjb.com"
      Height          =   255
      Left            =   600
      TabIndex        =   3
      Top             =   1680
      Width           =   2535
   End
   Begin VB.Label Label2 
      Caption         =   "Come and chat with us on mirc"
      Height          =   255
      Left            =   480
      TabIndex        =   2
      Top             =   1320
      Width           =   2295
   End
   Begin VB.Label Label1 
      Caption         =   "This is a remake of the program basic hu for h cards but i made it for p3 HU  cards"
      Height          =   735
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   3255
   End
End
Attribute VB_Name = "Form5"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Form5.Hide
End Sub

