VERSION 5.00
Begin VB.Form Form4 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "PPV Info"
   ClientHeight    =   1665
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4680
   Icon            =   "PPVLIMIT.frx":0000
   LinkTopic       =   "Form4"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1665
   ScaleWidth      =   4680
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox chage_ppv_limt_textbox 
      BackColor       =   &H8000000F&
      Height          =   345
      Left            =   1920
      TabIndex        =   1
      Text            =   "Text1"
      Top             =   600
      Width           =   780
   End
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   345
      Left            =   1680
      TabIndex        =   0
      Top             =   1200
      Width           =   1155
   End
   Begin VB.Label Label1 
      Caption         =   "Your current PPV purchase limit is listed below. The dollar amount can be set from $10 to $80."
      Height          =   420
      Left            =   240
      TabIndex        =   2
      Top             =   120
      Width           =   4335
   End
End
Attribute VB_Name = "Form4"
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

Form4.Hide
Unload Form4
End Sub

Private Sub Form_Load()

changed = False
PPV_Limit_Change = ""



End Sub



Sub UpDown1_Change()

Dim temp_limit As String
changed = True
temp_limit = chage_ppv_limt_textbox.Text
temp_limit = "$" & temp_limit & ".00"
chage_ppv_limt_textbox.Text = temp_limit

PPV_Limit_Change = UpDown1.Value
End Sub

