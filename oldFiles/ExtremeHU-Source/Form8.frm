VERSION 5.00
Begin VB.Form Form8 
   Caption         =   "Line Edit"
   ClientHeight    =   1575
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7380
   Icon            =   "Form8.frx":0000
   LinkTopic       =   "Form8"
   ScaleHeight     =   1575
   ScaleWidth      =   7380
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   1
      Left            =   1680
      MaxLength       =   2
      TabIndex        =   1
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.CommandButton EditDown_Button 
      Height          =   375
      Left            =   120
      Picture         =   "Form8.frx":0442
      Style           =   1  'Graphical
      TabIndex        =   37
      Top             =   480
      Width           =   375
   End
   Begin VB.CommandButton EditUp_Button 
      Height          =   375
      Left            =   120
      Picture         =   "Form8.frx":074C
      Style           =   1  'Graphical
      TabIndex        =   36
      Top             =   120
      Width           =   375
   End
   Begin VB.CommandButton CancelEdit_Button 
      Caption         =   "Close Edit Window"
      Height          =   375
      Left            =   2760
      TabIndex        =   18
      Top             =   960
      Width           =   1695
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Write Current Line"
      Height          =   375
      Left            =   720
      TabIndex        =   17
      Top             =   960
      Width           =   1695
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   15
      Left            =   6720
      MaxLength       =   2
      TabIndex        =   15
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   14
      Left            =   6360
      MaxLength       =   2
      TabIndex        =   14
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   13
      Left            =   6000
      MaxLength       =   2
      TabIndex        =   13
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   12
      Left            =   5640
      MaxLength       =   2
      TabIndex        =   12
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   11
      Left            =   5280
      MaxLength       =   2
      TabIndex        =   11
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   10
      Left            =   4920
      MaxLength       =   2
      TabIndex        =   10
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   9
      Left            =   4560
      MaxLength       =   2
      TabIndex        =   9
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   8
      Left            =   4200
      MaxLength       =   2
      TabIndex        =   8
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   7
      Left            =   3840
      MaxLength       =   2
      TabIndex        =   7
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   6
      Left            =   3480
      MaxLength       =   2
      TabIndex        =   6
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   5
      Left            =   3120
      MaxLength       =   2
      TabIndex        =   5
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   4
      Left            =   2760
      MaxLength       =   2
      TabIndex        =   4
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   3
      Left            =   2400
      MaxLength       =   2
      TabIndex        =   3
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   2
      Left            =   2040
      MaxLength       =   2
      TabIndex        =   2
      Text            =   " "
      Top             =   360
      Width           =   380
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   300
      Index           =   0
      Left            =   1320
      MaxLength       =   2
      TabIndex        =   0
      Top             =   360
      Width           =   380
   End
   Begin VB.Frame Frame1 
      Height          =   675
      Left            =   4890
      TabIndex        =   38
      Top             =   735
      Width           =   2235
      Begin VB.CheckBox Edit3m_checkbox 
         Caption         =   "Turn Off Automatic Encoding/Decoding"
         Height          =   450
         Left            =   90
         TabIndex        =   39
         Top             =   165
         Width           =   2055
      End
   End
   Begin VB.Label Label3 
      Alignment       =   1  'Right Justify
      Caption         =   "2000"
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
      Left            =   600
      TabIndex        =   35
      Top             =   405
      Width           =   615
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " F"
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
      Index           =   15
      Left            =   6720
      TabIndex        =   34
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " E"
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
      Index           =   14
      Left            =   6360
      TabIndex        =   33
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " D"
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
      Index           =   13
      Left            =   6000
      TabIndex        =   32
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " C"
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
      Index           =   12
      Left            =   5640
      TabIndex        =   31
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " B"
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
      Index           =   11
      Left            =   5280
      TabIndex        =   30
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " A"
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
      Index           =   10
      Left            =   4920
      TabIndex        =   29
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 9"
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
      Index           =   9
      Left            =   4560
      TabIndex        =   28
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 8"
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
      Index           =   8
      Left            =   4200
      TabIndex        =   27
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 7"
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
      Index           =   7
      Left            =   3840
      TabIndex        =   26
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 6"
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
      Index           =   6
      Left            =   3480
      TabIndex        =   25
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 5"
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
      Index           =   5
      Left            =   3120
      TabIndex        =   24
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 4"
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
      Index           =   4
      Left            =   2760
      TabIndex        =   23
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 3"
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
      Index           =   3
      Left            =   2400
      TabIndex        =   22
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 2"
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
      Index           =   2
      Left            =   2040
      TabIndex        =   21
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 1"
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
      Index           =   1
      Left            =   1680
      TabIndex        =   20
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   " 0"
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
      Index           =   0
      Left            =   1320
      TabIndex        =   19
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label1 
      Caption         =   "Address:"
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
      Left            =   600
      TabIndex        =   16
      Top             =   120
      Width           =   615
   End
End
Attribute VB_Name = "Form8"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub CancelEdit_Button_Click()
Form8.Hide
Form8.Edit3m_checkbox.Value = 0
End Sub

Private Sub EditDown_Button_Click()
Dim EditData(15) As String
Dim EditAddr As Integer

Form8.EditUp_Button.Enabled = True
EditAddr = Form1.MSFlexGrid1.Row + 1

Form1.MSFlexGrid1.TopRow = EditAddr
Form1.MSFlexGrid1.Row = EditAddr
Form1.MSFlexGrid1.Col = 0
Form1.MSFlexGrid1.ColSel = 16
Form8.Label3.Caption = Form1.MSFlexGrid1.TextMatrix(EditAddr, 0)


For X = 1 To 16
    EditData(X - 1) = Form1.MSFlexGrid1.TextMatrix(EditAddr, X)
    Form8.Text1(X - 1) = EditData(X - 1)
    Text1(X - 1).Locked = False
Next X
If Form8.Edit3m_checkbox.Value = 1 Then Edit3m_checkbox_Click
If EditAddr = 512 Then Form8.EditDown_Button.Enabled = False

End Sub

Private Sub EditUp_Button_Click()
Dim EditData(15) As String
Dim EditAddr As Integer

Form8.EditDown_Button.Enabled = True
EditAddr = Form1.MSFlexGrid1.Row - 1

Form1.MSFlexGrid1.TopRow = EditAddr
Form1.MSFlexGrid1.Row = EditAddr
Form1.MSFlexGrid1.Col = 0
Form1.MSFlexGrid1.ColSel = 16
Form8.Label3.Caption = Form1.MSFlexGrid1.TextMatrix(EditAddr, 0)

    For X = 1 To 16
        EditData(X - 1) = Form1.MSFlexGrid1.TextMatrix(EditAddr, X)
        Form8.Text1(X - 1) = EditData(X - 1)
    Next X

If Form8.Edit3m_checkbox.Value = 1 Then Edit3m_checkbox_Click

If EditAddr = 1 Then
    Form8.EditUp_Button.Enabled = False
    For X = 2 To 15
    Text1(X).Locked = True
    Next X
End If
End Sub


Private Sub Text1_GotFocus(Index As Integer)
Text1(Index).SelStart = 0
Text1(Index).SelLength = 2
End Sub



Private Sub Text1_KeyUp(Index As Integer, KeyCode As Integer, Shift As Integer)


If KeyCode = 37 Then
    If Index = 0 Then
        Index = 15
        
        Else:
        Index = Index - 1
        
    End If
    Text1(Index).SetFocus
    Exit Sub
End If
If Len(Text1(Index).SelText) = 2 Then Exit Sub
If Len(Text1(Index).Text) = 2 Then
    If Index = 15 Then
        Index = 0
        Else: Index = Index + 1
    End If
    Text1(Index).SetFocus
End If
End Sub
