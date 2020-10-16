VERSION 5.00
Begin VB.Form Form2 
   BackColor       =   &H80000013&
   Caption         =   "HU EEPROM MAP"
   ClientHeight    =   6855
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8250
   Icon            =   "humap.frx":0000
   LinkTopic       =   "Form2"
   ScaleHeight     =   6855
   ScaleWidth      =   8250
   StartUpPosition =   2  'CenterScreen
   Begin VB.Label Label36 
      Caption         =   "2EEC - 2EF7 = USW 12 Byte Write Key"
      Height          =   330
      Left            =   4440
      TabIndex        =   35
      Top             =   4800
      Width           =   3855
   End
   Begin VB.Label Label35 
      Caption         =   "2511 - 2511 = Locals Byte"
      ForeColor       =   &H00FF0000&
      Height          =   285
      Left            =   4440
      TabIndex        =   34
      Top             =   2640
      Width           =   3855
   End
   Begin VB.Label Label34 
      Caption         =   "2464 - 2464 = Rating Limit"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   33
      Top             =   6600
      Width           =   3855
   End
   Begin VB.Label Label15 
      Caption         =   "2465 - 2465 = 00  Used to calc. 4th byte of ATR"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   4440
      TabIndex        =   32
      Top             =   120
      Width           =   3855
   End
   Begin VB.Label Label33 
      Caption         =   "2010 - 2010 = 03  (5th byte of ATR)"
      Height          =   255
      Left            =   120
      TabIndex        =   31
      Top             =   1200
      Width           =   3900
   End
   Begin VB.Label Label32 
      Caption         =   "2018 - 201F = Data used to calc. last 8 bytes of ATR"
      Height          =   255
      Left            =   120
      TabIndex        =   30
      Top             =   1920
      Width           =   3855
   End
   Begin VB.Label Label31 
      Caption         =   "Blue = Encrypted Data"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   4290
      TabIndex        =   29
      Top             =   6495
      Width           =   3855
   End
   Begin VB.Label Label21 
      Caption         =   "24DC - 24DC = CAM Checksum Byte"
      Height          =   255
      Left            =   4440
      TabIndex        =   28
      Top             =   1920
      Width           =   3855
   End
   Begin VB.Label Label30 
      Caption         =   "241E - 241F = PPV Spending Limit"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   27
      Top             =   5520
      Width           =   3855
   End
   Begin VB.Label Label29 
      Caption         =   "Black = Unencrypted Data"
      Height          =   255
      Left            =   4290
      TabIndex        =   26
      Top             =   6255
      Width           =   3855
   End
   Begin VB.Label Label28 
      Caption         =   $"humap.frx":030A
      Height          =   855
      Left            =   4290
      TabIndex        =   25
      Top             =   5295
      Width           =   3855
   End
   Begin VB.Label Label27 
      Caption         =   "2658 - 265F = Eeprom Decrypt Key 2"
      Height          =   255
      Left            =   4440
      TabIndex        =   24
      Top             =   4440
      Width           =   3855
   End
   Begin VB.Label Label26 
      Caption         =   "25D0 - 260F = Tertiary ZKT Table"
      Height          =   255
      Left            =   4440
      TabIndex        =   23
      Top             =   4080
      Width           =   3855
   End
   Begin VB.Label Label25 
      Caption         =   "2590 - 25CF = Secondary ZKT Table"
      Height          =   255
      Left            =   4440
      TabIndex        =   22
      Top             =   3720
      Width           =   3855
   End
   Begin VB.Label Label24 
      Caption         =   "2550 - 258F = Primary ZKT Table"
      Height          =   255
      Left            =   4440
      TabIndex        =   21
      Top             =   3360
      Width           =   3855
   End
   Begin VB.Label Label23 
      Caption         =   "251F - 251F = Guide Byte"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   4425
      TabIndex        =   20
      Top             =   3000
      Width           =   3855
   End
   Begin VB.Label Label22 
      Caption         =   "24E0 - 24E0 = Time Zone"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   4440
      TabIndex        =   19
      Top             =   2280
      Width           =   3855
   End
   Begin VB.Label Label20 
      Caption         =   "24D8 - 24DB = CAM ID number "
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   4440
      TabIndex        =   18
      Top             =   1560
      Width           =   3855
   End
   Begin VB.Label Label19 
      Caption         =   "24C8 - 24C9 = USW  "
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   4440
      TabIndex        =   17
      Top             =   1200
      Width           =   3855
   End
   Begin VB.Label Label18 
      Caption         =   "24C0 - 24C7 = Eeprom Decrypt Key 1"
      Height          =   255
      Left            =   4440
      TabIndex        =   16
      Top             =   840
      Width           =   3855
   End
   Begin VB.Label Label17 
      Caption         =   "24A4 - 24A7 = IRD Number (Location 2)"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   4440
      TabIndex        =   15
      Top             =   480
      Width           =   3855
   End
   Begin VB.Label Label16 
      Caption         =   "2460 - 2463 = IRD number (Location 1)"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   14
      Top             =   6240
      Width           =   3855
   End
   Begin VB.Label Label14 
      Caption         =   "2420 - 2425 = More PPV Info ??"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   13
      Top             =   5880
      Width           =   3855
   End
   Begin VB.Label Label13 
      Caption         =   "241C - 241D = PPV Amount Purchased "
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   5160
      Width           =   3855
   End
   Begin VB.Label Label12 
      Caption         =   "241B - 241B = PPV Slot 1 Purchace Option "
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   4800
      Width           =   3855
   End
   Begin VB.Label Label11 
      Caption         =   "2418 - 241A = PPV Slot 1 GUIDE 00 01 00"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   4440
      Width           =   3855
   End
   Begin VB.Label Label10 
      Caption         =   "2410 - 2415 = 55 and Zip Code"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   4080
      Width           =   3855
   End
   Begin VB.Label Label9 
      Caption         =   "240C - 240F = Password"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   3720
      Width           =   3855
   End
   Begin VB.Label Label8 
      Caption         =   "2406 - 2407 = Spending Limit"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   3360
      Width           =   3855
   End
   Begin VB.Label Label7 
      Caption         =   "2106 - 22F1 = Tier area"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   3000
      Width           =   3855
   End
   Begin VB.Label Label6 
      Caption         =   "2024 - 2105 = PPV area "
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   2640
      Width           =   3855
   End
   Begin VB.Label Label5 
      Caption         =   "2020 - 2023 = Data, same for each cam"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   2280
      Width           =   3855
   End
   Begin VB.Label Label4 
      Caption         =   "2014 - 2015 = Fuse Bytes"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   1560
      Width           =   3855
   End
   Begin VB.Label Label3 
      Caption         =   "2007 - 200F = Data, same for each cam"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   840
      Width           =   3855
   End
   Begin VB.Label Label2 
      Caption         =   "2002 - 2006 = Data, not the same on each CAM."
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   480
      Width           =   3855
   End
   Begin VB.Label Label1 
      Caption         =   "2000 - 2001 = 00 00"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   3855
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
