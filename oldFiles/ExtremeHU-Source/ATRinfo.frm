VERSION 5.00
Begin VB.Form Form3 
   Caption         =   "ATR Info"
   ClientHeight    =   5790
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   6990
   Icon            =   "ATRinfo.frx":0000
   LinkTopic       =   "Form3"
   ScaleHeight     =   5790
   ScaleWidth      =   6990
   StartUpPosition =   1  'CenterOwner
   Begin VB.Label Label11 
      Caption         =   "ATR =  Answer To Reset"
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
      Left            =   360
      TabIndex        =   16
      Top             =   120
      Width           =   2775
   End
   Begin VB.Label Label10 
      Caption         =   $"ATRinfo.frx":030A
      Height          =   975
      Left            =   120
      TabIndex        =   15
      Top             =   4680
      Width           =   6735
   End
   Begin VB.Label Label18 
      Caption         =   "These bytes are retrieved from ROM address C2E2 - C2E3"
      Height          =   255
      Left            =   1320
      TabIndex        =   14
      Top             =   3360
      Width           =   5055
   End
   Begin VB.Label Label17 
      Caption         =   "These bytes are sent from the ROM "
      Height          =   255
      Left            =   1320
      TabIndex        =   13
      Top             =   3000
      Width           =   5055
   End
   Begin VB.Label Label16 
      Caption         =   "These bytes are retrieved form ROM address C2DF - C2E1"
      Height          =   255
      Left            =   1320
      TabIndex        =   12
      Top             =   2640
      Width           =   5055
   End
   Begin VB.Label Label15 
      Caption         =   "This byte is retrieved form EEPROM address 2010"
      Height          =   255
      Left            =   1320
      TabIndex        =   11
      Top             =   2280
      Width           =   5055
   End
   Begin VB.Label Label14 
      Caption         =   "This byte is some how calculated using the data at 2465 - 2467"
      Height          =   255
      Left            =   1320
      TabIndex        =   10
      Top             =   1920
      Width           =   5055
   End
   Begin VB.Label Label13 
      Caption         =   "These bytes are sent form the ROM "
      Height          =   255
      Left            =   1320
      TabIndex        =   9
      Top             =   1560
      Width           =   4935
   End
   Begin VB.Label Label9 
      Caption         =   $"ATRinfo.frx":0425
      Height          =   615
      Left            =   120
      TabIndex        =   8
      Top             =   3960
      Width           =   6735
   End
   Begin VB.Label Label8 
      Caption         =   "00 00 29 48 55 54 00 00"
      ForeColor       =   &H00008000&
      Height          =   255
      Left            =   240
      TabIndex        =   7
      Top             =   3720
      Width           =   1935
   End
   Begin VB.Label Label7 
      Alignment       =   1  'Right Justify
      Caption         =   "4A 50"
      ForeColor       =   &H00008000&
      Height          =   255
      Left            =   360
      TabIndex        =   6
      Top             =   3360
      Width           =   615
   End
   Begin VB.Label Label6 
      Alignment       =   1  'Right Justify
      Caption         =   "FF FF"
      ForeColor       =   &H00008000&
      Height          =   255
      Left            =   480
      TabIndex        =   5
      Top             =   3000
      Width           =   495
   End
   Begin VB.Label Label5 
      Alignment       =   1  'Right Justify
      Caption         =   "38 B0 04"
      ForeColor       =   &H00008000&
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   2640
      Width           =   735
   End
   Begin VB.Label Label4 
      Alignment       =   1  'Right Justify
      Caption         =   "03"
      ForeColor       =   &H00008000&
      Height          =   255
      Left            =   600
      TabIndex        =   3
      Top             =   2280
      Width           =   375
   End
   Begin VB.Label Label3 
      Alignment       =   1  'Right Justify
      Caption         =   "25"
      ForeColor       =   &H00008000&
      Height          =   255
      Left            =   600
      TabIndex        =   2
      Top             =   1920
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Right Justify
      Caption         =   "3F 7F 13"
      ForeColor       =   &H00008000&
      Height          =   255
      Left            =   240
      TabIndex        =   1
      Top             =   1560
      Width           =   735
   End
   Begin VB.Label Label1 
      Caption         =   $"ATRinfo.frx":04D3
      Height          =   975
      Left            =   360
      TabIndex        =   0
      Top             =   480
      Width           =   6375
   End
End
Attribute VB_Name = "Form3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
