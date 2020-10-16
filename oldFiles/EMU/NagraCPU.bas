Attribute VB_Name = "NagraCPU"
'********************************************
'*  NagraCPU.bas Opcode Simulator by BigJx  *
'********************************************
Option Explicit
Public Memory(&HFFFF&) As Byte
Public TopStack As Single
Public PC As Double
Public SP As Byte
Public A As Byte
Public X As Byte
Public Y As Byte
Public CCR As Byte

Public Function StepCPU() As String
Dim OpCode As Byte, Pram1 As Byte, Pram2 As Byte, Pram12 As Double
Dim bTmp As Boolean, Tst1 As Boolean, Tst2 As Boolean, X2Y As Boolean
Dim Reg As Byte, XY As Byte, Target As Double, Prefix As Integer
Dim Addr As Double, tCCR As Byte, tMath As Integer, OpHI As Byte, OpLO As Byte
Dim sAddr As String, sOP As String, sOP1 As String
sAddr = Right("000" & Hex(PC), 4)
X2Y = False
start:
OpCode = Memory(PC)
PC = PC + 1
OpHI = "&H" & Left(Right("0" & Hex(OpCode), 2), 1)
OpLO = "&H" & Right(Hex(OpCode), 1)
Pram1 = Memory(PC)
Pram2 = Memory(PC + 1)
Pram12 = (CDbl(Pram1) * 256) + Pram2
sOP = sOP & " " & Right("0" & Hex(OpCode), 2)
Select Case OpHI
    Case 0 'handle 0x opcodes
        sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & " " & Right("0" & Hex(Pram2), 2) & Space(13), 14)
        PC = PC + 2
        'test bit
        bTmp = ((2 ^ ((OpLO And &HE) / 2)) And (Memory(Pram1)))
        If Pram2 > &H7F Then
            'branch backward
            Target = PC - (Not (Pram2 - 1) And &HFF)
        Else
            'branch foreward
            Target = PC + Pram2
        End If
        If (OpLO And 1) = 0 Then
            'op is BRSET
            sOP = sOP & "BRSET" & ((OpLO And &HE) / 2) & " $" & Right("0" & Hex(Pram1), 2) & ",$" & Right("000" & Hex(Target), 4)
            If bTmp Then
                'bit is set
                PC = Target
            End If
        Else
            'op is BRCLR
            sOP = sOP & "BRCLR" & ((OpLO And &HE) / 2) & " $" & Right("0" & Hex(Pram1), 2) & ",$" & Right("000" & Hex(Target), 4)
            If Not bTmp Then
                'bit is clear
                PC = Target
            End If
        End If
    Case 1 'handle 1x opcodes
        PC = PC + 1
        sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & Space(13), 14)
        If (OpLO And 1) = 0 Then
            'Set Bit
            sOP = sOP & "BSET" & ((OpLO And &HE) / 2) & " $" & Right("0" & Hex(Pram1), 2)
            Memory(Pram1) = (2 ^ ((OpLO And &HE) / 2)) Or Memory(Pram1)
        Else
            'Clear bit
            sOP = sOP & "BCLR" & ((OpLO And &HE) / 2) & " $" & Right("0" & Hex(Pram1), 2)
            Memory(Pram1) = (Not (2 ^ ((OpLO And &HE) / 2)) And &HFF) And Memory(Pram1)
        End If
    Case 2 'handle 2x opcodes
        PC = PC + 1
        sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & Space(13), 14)
        If Pram1 > &H7F Then
            Target = PC - (Not (Pram1 - 1) And &HFF)
        Else
            Target = PC + Pram1
        End If
        Select Case OpLO
            Case 0
                'BRA
                sOP = sOP & "BRA $"
                bTmp = True
            Case 1
                'BRN
                sOP = sOP & "BRN $"
                bTmp = False
            Case 2
                'BHI
                sOP = sOP & "BHI $"
                Tst1 = CCR And 1 'test C flag
                Tst2 = CCR And 2 'test Z flag
                If Not ((Not (Tst1 And Tst2)) And (Tst1 Or Tst2)) Then bTmp = True 'Not C XOR Z = 1
            Case 3
                'BLS
                sOP = sOP & "BLS $"
                Tst1 = CCR And 1 'test C flag
                Tst2 = CCR And 2 'test Z flag
                If ((Not (Tst1 And Tst2)) And (Tst1 Or Tst2)) Then bTmp = True 'C XOR Z =1
            Case 4
                'BCC
                sOP = sOP & "BCC $"
                If (CCR And 1) = 0 Then bTmp = True
            Case 5
                'BCS
                sOP = sOP & "BCS $"
                If (CCR And 1) = 1 Then bTmp = True
            Case 6
                'BNE
                sOP = sOP & "BNE $"
                If (CCR And 2) = 0 Then bTmp = True
            Case 7
                'BEQ
                sOP = sOP & "BEQ $"
                If (CCR And 2) = 2 Then bTmp = True
            Case 8
                'BHCC
                sOP = sOP & "BHCC $"
                If (CCR And 16) = 0 Then bTmp = True
            Case 9
                'BHCS
                sOP = sOP & "BHCS $"
                If (CCR And 16) = 16 Then bTmp = True
            Case &HA
                'BPL
                sOP = sOP & "BPL $"
                If (CCR And 4) = 0 Then bTmp = True
            Case &HB
                'BMI
                sOP = sOP & "BMI $"
                If (CCR And 4) = 4 Then bTmp = True
            Case &HC, &HE
                'BMC, BIL
                sOP = sOP & "BIL $"
                If (CCR And 8) = 0 Then bTmp = True
            Case &HD, &HF
                'BMS, BIH
                sOP = sOP & "BIH $"
                If (CCR And 8) = 8 Then bTmp = True
        End Select
        sOP = sOP & Right("000" & Hex(Target), 4)
        If bTmp Then
            PC = Target
        End If
    Case 3, 6, 7 'handle 3x, 6x, 7x opcodes
        'set Adressing Mode
        If OpHI = 3 Then
            '3x Direct Adressing
            PC = PC + 1
            sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & Space(13), 14)
            If Prefix = &H91 Or Prefix = &H92 Then
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & "]"
                Addr = Memory(Pram1)
            Else
                sOP1 = " $" & Right("0" & Hex(Pram1), 2)
                Addr = Pram1
            End If
        ElseIf OpHI = 6 Then
            '6x Indexed Adressing (8-bit offset)
            PC = PC + 1
            sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & Space(13), 14)
            If Prefix = &H90 Then
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & "],Y"
                Addr = CLng(Pram1) + Y
            ElseIf Prefix = &H91 Then
                sOP1 = " " & Right("0" & Hex(Pram1), 2) & ",Y"
                Addr = Memory(Pram1) + Y
            ElseIf Prefix = &H92 Then
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & "],X"
                Addr = Memory(Pram1) + X
            Else
                sOP1 = " " & Right("0" & Hex(Pram1), 2) & ",X"
                Addr = CLng(Pram1) + X
            End If
        Else
            '7x Indexed Adressing
             sOP = Left(sOP & Space(13), 14)
             If Prefix = &H90 Or Prefix = &H91 Then
                sOP1 = " ,Y"
                Addr = Y
            Else
                sOP1 = " ,X"
                Addr = X
            End If
        End If
        Prefix = 0
        Select Case OpLO
            Case 0
                'NEG
                sOP = sOP & "NEG" & sOP1
                Memory(Addr) = (Not (Memory(Addr) - 1) And &HFF)
                If Memory(Addr) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR And (Not (&H1) And &HFF) Else CCR = CCR Or &H1
            Case 3
                'COM
                sOP = sOP & "COM" & sOP1
                Memory(Addr) = (Not (Memory(Addr)) And &HFF)
                If Memory(Addr) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
                CCR = CCR Or &H1
            Case 4
                'LSR
                sOP = sOP & "LSR" & sOP1
                If (Memory(Addr) And &H1) = &H1 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Memory(Addr) = (Memory(Addr) / 2) And &HFF
                CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 6
                'ROR
                sOP = sOP & "ROR" & sOP1
                tCCR = CCR
                If (Memory(Addr) And &H1) = &H1 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Memory(Addr) = (Memory(Addr) / 2) And &HFF
                If tCCR And &H1 Then Memory(Addr) = Memory(Addr) Or &H80
                If Memory(Addr) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 7
                'ASR
                sOP = sOP & "ASR" & sOP1
                If (Memory(Addr) And &H1) = &H1 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Memory(Addr) = (Memory(Addr) / 2) And &HFF
                If Memory(Addr) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 8
                'LSL
                sOP = sOP & "LSL" & sOP1
                If (Memory(Addr) And &H80) = &H80 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Memory(Addr) = (Memory(Addr) * 2) And &HFF
                CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 9
                'ROL
                sOP = sOP & "ROL" & sOP1
                tCCR = CCR
                If (Memory(Addr) And &H80) = &H80 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Memory(Addr) = (Memory(Addr) * 2) And &HFF
                If tCCR And &H1 Then Memory(Addr) = Memory(Addr) Or &H1
                If Memory(Addr) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HA
                'DEC
                sOP = sOP & "DEC" & sOP1
                Memory(Addr) = (Not ((Not Memory(Addr)) + 1)) And &HFF
                If Memory(Addr) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HC
                'INC
                sOP = sOP & "INC" & sOP1
                Memory(Addr) = ((Memory(Addr) + 1) And &HFF)
                If Memory(Addr) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HD
                'TST
                sOP = sOP & "TST" & sOP1
                If Memory(Addr) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Memory(Addr) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HE
                'SWAP
                sOP = sOP & "SWAP" & sOP1
                Memory(Addr) = (((Memory(Addr) And &HF0) / 16) + ((Memory(Addr) And &HF) * 16))
            Case &HF
                'CLR
                sOP = sOP & "CLR" & sOP1
                Memory(Addr) = 0
                CCR = (CCR Or &H2) And &HFA
            Case Else
                'Unknown
                 sOP = Left(sOP & Space(11), 14) & "?UNKOWN?"
        End Select
    Case 4, 5 'handle 4x, 5x opcodes
        If OpHI = 4 Then
            '4x
            sOP1 = " A"
            Reg = A
        Else
            '5x
            If X2Y Then
                sOP1 = " Y"
                Reg = Y
            Else
                sOP1 = " X"
                Reg = X
            End If
        End If
        If OpCode = &H51 Then OpLO = 3
        Select Case OpLO
            Case 0
                'NEG A or X
                sOP = Left(sOP & Space(11), 14) & "NEG" & sOP1
                Reg = (Not (Reg - 1)) And &HFF
                If Reg And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
                If Reg = 0 Then CCR = CCR And (Not (&H1) And &HFF) Else CCR = CCR Or &H1
            Case 2
                'MUL
                sOP = Left(sOP & Space(11), 14) & "MUL"
                Dim tMUL As Single
                If X2Y Then Reg = Y Else Reg = X
                tMUL = (CLng(A) * CLng(Reg)) And &HFFFF
                Reg = "&H" & Left(Right("000" & Hex(tMUL), 4), 2)
                A = "&H" & Right("0" & Hex(tMUL), 2)
                CCR = CCR And (Not (&H10) And &HFF)
                CCR = CCR And (Not (&H1) And &HFF)
                If X2Y Then Y = Reg Else X = Reg
                bTmp = True
            Case 3
                'COM A or X
                sOP = Left(sOP & Space(11), 14) & "COM" & sOP1
                Reg = (Not Reg) And &HFF
                If Reg And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
                CCR = CCR Or &H1
            Case 4
                'LSR A or X
                sOP = Left(sOP & Space(11), 14) & "LSR" & sOP1
                If (Reg And &H1) = &H1 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Reg = (Reg / 2) And &HFF
                CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 6
                'ROR A or X
                sOP = Left(sOP & Space(11), 14) & "ROR" & sOP1
                tCCR = CCR
                If (Reg And &H1) = &H1 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Reg = (Reg / 2) And &HFF
                If tCCR And &H1 Then Reg = Reg Or &H80
                If Reg And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 7
                'ASR A or X
                sOP = Left(sOP & Space(11), 14) & "ASR" & sOP1
                If (Reg And &H1) = &H1 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Reg = (Reg / 2) And &HFF
                If Reg And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 8
                'LSL A or X
                sOP = Left(sOP & Space(11), 14) & "LSL" & sOP1
                If (Reg And &H80) = &H80 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Reg = (Reg * 2) And &HFF
                CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 9
                'ROL A or X
                sOP = Left(sOP & Space(11), 14) & "ROL" & sOP1
                tCCR = CCR
                If (Reg And &H80) = &H80 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                Reg = (Reg * 2) And &HFF
                If tCCR And &H1 Then Reg = Reg Or &H1
                If Reg And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HA
                'DEC A or X
                sOP = Left(sOP & Space(11), 14) & "DEC" & sOP1
                Reg = (Not ((Not Reg) + 1) And &HFF)
                If Reg And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HC
                'INC A or X
                sOP = Left(sOP & Space(11), 14) & "INC" & sOP1
                Reg = ((Reg + 1) And &HFF)
                If Reg And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HD
                'TST A or X
                sOP = Left(sOP & Space(11), 14) & "TST" & sOP1
                If Reg And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If Reg = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HE
                'SWAP A or X
                sOP = Left(sOP & Space(11), 14) & "SWAP" & sOP1
                Reg = (((Reg And &HF0) / 16) + ((Reg And &HF) * 16))
            Case &HF
                'CLR A or X
                sOP = Left(sOP & Space(11), 14) & "CLR" & sOP1
                Reg = 0
                CCR = (CCR Or &H2) And &HFA
            Case Else
                'Unknown
                 sOP = Left(sOP & Space(11), 14) & "?UNKOWN?"
        End Select
        If Not bTmp Then
            If OpHI = 4 Then
                A = Reg
            ElseIf OpHI = 5 Then
                If X2Y Then Y = Reg Else X = Reg
            End If
        End If
    Case 8 'handle 8x opcodes
        If X2Y Then sOP1 = "Y" Else sOP1 = "X"
        Select Case OpLO
            Case 0
                'RTI
                sOP = Left(sOP & Space(11), 14) & "RTI"
                SP = SP + 1
                CCR = Memory((TopStack And &HFF00) Or SP)
                SP = SP + 1
                A = Memory((TopStack And &HFF00) Or SP)
                SP = SP + 1
                X = Memory((TopStack And &HFF00) Or SP)
                SP = SP + 1
                PC = (CDbl(Memory((TopStack And &HFF00) Or SP)) * 256) + Memory(((TopStack And &HFF00) Or SP) + 1)
                SP = SP + 1
            Case 1
                'RTS
                sOP = Left(sOP & Space(11), 14) & "RTS"
                SP = SP + 1
                PC = (CDbl(Memory((TopStack And &HFF00) Or SP)) * 256) + Memory(((TopStack And &HFF00) Or SP) + 1)
                SP = SP + 1
            Case 3
                'SWI
                sOP = Left(sOP & Space(11), 14) & "SWI"
                Memory((TopStack And &HFF00) Or SP) = (PC And &HFF)
                SP = SP - 1
                Memory((TopStack And &HFF00) Or SP) = (PC And &HFF00) / 256
                SP = SP - 1
                Memory((TopStack And &HFF00) Or SP) = X
                SP = SP - 1
                Memory((TopStack And &HFF00) Or SP) = A
                SP = SP - 1
                Memory((TopStack And &HFF00) Or SP) = CCR
                SP = SP - 1
                CCR = CCR Or &H8
                PC = &H4004
            Case 4
                'POPA
                sOP = Left(sOP & Space(11), 14) & "POP A"
                If Not SP = &HFF Then SP = SP + 1
                A = Memory((TopStack And &HFF00) Or SP)
            Case 5
                'POPX
                sOP = Left(sOP & Space(11), 14) & "POP " & sOP1
                SP = SP + 1
                If X2Y Then Y = Memory((TopStack And &HFF00) Or SP) Else X = Memory((TopStack And &HFF00) Or SP)
            Case 6
                'POPCCR
                sOP = Left(sOP & Space(11), 14) & "POP CCR"
                SP = SP + 1
                CCR = Memory((TopStack And &HFF00) Or SP)
            Case 8
                'PUSHA
                sOP = Left(sOP & Space(11), 14) & "PUSH A"
                Memory((TopStack And &HFF00) Or SP) = A
                SP = SP - 1
            Case 9
                'PUSHX
                sOP = Left(Left(sOP & Space(11), 14), 14) & "PUSH " & sOP1
                If X2Y Then Memory((TopStack And &HFF00) Or SP) = Y Else Memory((TopStack And &HFF00) Or SP) = X
                SP = SP - 1
            Case &HA
                'PUSHCCR
                sOP = Left(sOP & Space(11), 14) & "PUSH CCR"
                Memory((TopStack And &HFF00) Or SP) = CCR
                SP = SP - 1
            Case &HE
                'STOP
                sOP = Left(sOP & Space(11), 14) & "STOP"
            Case &HF
                'WAIT
                sOP = Left(sOP & Space(11), 14) & "WAIT"
            Case Else
                'Unknown
                 sOP = Left(sOP & Space(11), 14) & "?UNKOWN?"
        End Select
    Case 9 'handle 9x opcodes
        If X2Y Then sOP1 = "Y" Else sOP1 = "X"
        Select Case OpLO
            Case 0
                X2Y = True
                Prefix = OpCode
                GoTo start
            Case 1, 2
                Prefix = OpCode
                GoTo start
            Case 3
                If X2Y Then
                    'TXY
                    sOP = Left(sOP & Space(11), 14) & "TXY"
                    Y = X
                Else
                    'TYX
                    sOP = Left(sOP & Space(11), 14) & "TYX"
                    X = Y
                End If
            Case 4
                If X2Y Then
                    'TSX
                    sOP = Left(sOP & Space(11), 14) & "TSX"
                    X = SP
                Else
                    'TXS
                    sOP = Left(sOP & Space(11), 14) & "TXS"
                    SP = X
                End If
            Case 5
                'TAS
                sOP = Left(sOP & Space(11), 14) & "TAS"
                SP = A
            Case 6
                'TSX
                sOP = Left(sOP & Space(11), 14) & "TS" & sOP1
                If X2Y Then Y = SP Else X = SP
            Case 7
                'TAX
                sOP = Left(sOP & Space(11), 14) & "TA" & sOP1
                If X2Y Then Y = A Else X = A
            Case 8
                'CLC
                sOP = Left(sOP & Space(11), 14) & "CLC"
                CCR = CCR And (Not (&H1) And &HFF)
            Case 9
                'SEC
                sOP = Left(sOP & Space(11), 14) & "SEC"
                CCR = CCR Or &H1
            Case &HA
                'CLI
                sOP = Left(sOP & Space(11), 14) & "CLI"
                CCR = CCR And (Not (&H8) And &HFF)
            Case &HB
                'SEI
                sOP = Left(sOP & Space(11), 14) & "SEI"
                CCR = CCR Or &H8
            Case &HC
                'RSP
                sOP = Left(sOP & Space(11), 14) & "RSP"
                SP = TopStack And &HFF
            Case &HD
                'NOP
                sOP = Left(sOP & Space(11), 14) & "NOP"
            Case &HE
                'TSA
                sOP = Left(sOP & Space(11), 14) & "TSA"
                A = SP
            Case &HF
                'TXA
                sOP = Left(sOP & Space(11), 14) & "T" & sOP1 & "A"
                If X2Y Then A = Y Else A = X
            Case Else
                'Unknown
                 sOP = Left(sOP & Space(11), 14) & "?UNKOWN?"
        End Select
    Case &HA
        PC = PC + 1
        If X2Y Then XY = Y Else XY = X
        sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & Space(13), 14)
        Select Case OpLO
            Case 0
                'SUB
                sOP = sOP & "SUB #$" & Right("0" & Hex(Pram1), 2)
                If Pram1 > A Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                A = (256 + A - Pram1) And &HFF
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 1
                'CMP
                sOP = sOP & "CMP #$" & Right("0" & Hex(Pram1), 2)
                If Pram1 > A Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                If ((256 + A - Pram1) And &HFF) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If ((256 + A - Pram1) And &HFF) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 2
                'SBC
                sOP = sOP & "SBC #$" & Right("0" & Hex(Pram1), 2)
                Reg = (CCR And &H1) + Pram1
                If Reg > A Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                A = (256 + A - Reg) And &HFF
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 3
                'CPX
                sOP = sOP & "CPX #$" & Right("0" & Hex(Pram1), 2)
                If Pram1 > XY Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                If ((256 + XY - Pram1) And &HFF) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If ((256 + XY - Pram1) And &HFF) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 4
                'AND
                sOP = sOP & "AND #$" & Right("0" & Hex(Pram1), 2)
                A = (A And Pram1)
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 5
                'BIT
                sOP = sOP & "BIT #$" & Right("0" & Hex(Pram1), 2)
                If (A And Pram1) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If (A And Pram1) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 6
                'LDA
                sOP = sOP & "LDA #$" & Right("0" & Hex(Pram1), 2)
                A = Pram1
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 8
                'EOR
                sOP = sOP & "EOR #$" & Right("0" & Hex(Pram1), 2)
                A = ((A Or Pram1) And (Not (A And Pram1) And &HFF))
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 9
                'ADC
                sOP = sOP & "ADC #$" & Right("0" & Hex(Pram1), 2)
                tMath = A + (CCR And &H1) + Pram1
                Reg = (A And &HF) + (Pram1 And &HF) + (CCR And &H1)
                A = tMath And &HFF
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
                If tMath > &H100 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                If Reg >= &H10 Then CCR = CCR Or &H16 Else CCR = CCR And (Not (&H16) And &HFF)
            Case &HA
                'ORA
                sOP = sOP & "ORA #$" & Right("0" & Hex(Pram1), 2)
                A = (A Or Pram1)
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HB
                'ADD
                sOP = sOP & "ADD #$" & Right("0" & Hex(Pram1), 2)
                tMath = CLng(A) + Pram1
                Reg = (A And &HF) + (Pram1 And &HF) + (CCR And &H1)
                A = tMath And &HFF
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
                If tMath > &H100 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                If Reg >= &H10 Then CCR = CCR Or &H16 Else CCR = CCR And (Not (&H16) And &HFF)
            Case &HD
                'BSR
                If Pram1 > &H7F Then
                    'branch backward
                    Target = PC - (Not (Pram1 - 1) And &HFF)
                Else
                    'branch foreward
                    Target = PC + Pram1
                End If
                sOP = sOP & "BSR $" & Right("000" & Hex(Target), 4)
                Memory((TopStack And &HFF00) Or SP) = (&HFF And PC)
                SP = SP - 1
                Memory((TopStack And &HFF00) Or SP) = ((PC And &HFF00) / 256)
                SP = SP - 1
                PC = Target
            Case &HE
                'LDX
                sOP = sOP & "LDX #$" & Right("0" & Hex(Pram1), 2)
                XY = Pram1
                If XY And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If XY = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case Else
                'Unknown
                 sOP = Left(sOP & Space(11), 14) & "?UNKOWN?"
        End Select
        If X2Y Then Y = XY Else X = XY
    Case Else
        'set Adressing Mode
        If OpHI = &HB Then
            'Bx Direct Adressing
            PC = PC + 1
            sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & Space(13), 14)
            If Prefix = &H91 Or Prefix = &H92 Then
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & "]"
                Addr = Memory(Pram1)
            Else
                sOP1 = " $" & Right("0" & Hex(Pram1), 2)
                Addr = Pram1
            End If
        ElseIf OpHI = &HC Then
            'Cx Extended Adressing
            If Prefix = &H91 Or Prefix = &H92 Then
                sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & Space(13), 14)
                Addr = (CDbl(Memory(Pram1)) * 256) + Memory(Pram1 + 1)
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & ":" & Right("0" & Hex(Pram1 + 1), 2) & "]"
                PC = PC + 1
            Else
                sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & " " & Right("0" & Hex(Pram2), 2) & Space(13), 14)
                sOP1 = " $" & Right("000" & Hex(Pram12), 4)
                Addr = Pram12
                PC = PC + 2
            End If
        ElseIf OpHI = &HD Then
            'Dx Indexed Adressing (16-bit offset)
            If Prefix = &H90 Then
                PC = PC + 2
                sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & " " & Right("0" & Hex(Pram2), 2) & Space(13), 14)
                Addr = Pram12 + Y
                sOP1 = " $" & Right("000" & Hex(Pram12), 4) & ",Y"
            ElseIf Prefix = &H91 Then
                Addr = (CDbl(Memory(Pram1)) * 256) + Memory(Pram1 + 1) + Y
                sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & Space(13), 14)
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & ":" & Right("0" & Hex(Pram1 + 1), 2) & "],Y"
                PC = PC + 1
            ElseIf Prefix = &H92 Then
                Addr = (CDbl(Memory(Pram1)) * 256) + Memory(Pram1 + 1) + X
                sOP = Left(sOP & " $" & Right("0" & Hex(Pram1), 2) & Space(13), 14)
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & ":" & Right("0" & Hex(Pram1 + 1), 2) & "],X"
                PC = PC + 1
            Else
                PC = PC + 2
                sOP = Left(sOP & " " & Right("0" & Hex(Pram1), 2) & " " & Right("0" & Hex(Pram2), 2) & Space(13), 14)
                Addr = Pram12 + X
                sOP1 = " $" & Right("000" & Hex(Pram12), 4) & ",X"
            End If
        ElseIf OpHI = &HE Then
            'Ex Indexed Adressing (8-bit offset)
            PC = PC + 1
            sOP = Left(sOP & Space(13), 14)
            If Prefix = &H90 Then
                sOP1 = " $" & Right("0" & Hex(Pram1), 2) & ",Y"
                Addr = CLng(Pram1) + Y
            ElseIf Prefix = &H91 Then
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & "],Y"
                Addr = Memory(Pram1) + Y
            ElseIf Prefix = &H92 Then
                sOP1 = " [$" & Right("0" & Hex(Pram1), 2) & "],X"
                Addr = Memory(Pram1) + X
            Else
                 sOP1 = " $" & Right("0" & Hex(Pram1), 2) & ",X"
                 Addr = CLng(Pram1) + X
            End If
        Else
            'Fx Indexed Adressing
            sOP = Left(sOP & Space(13), 14)
            If Prefix = &H90 Or Prefix = &H91 Then
                sOP1 = " ,Y"
                Addr = Y
            Else
                sOP1 = " ,X"
                Addr = X
            End If
        End If
        If X2Y Then XY = Y Else XY = X
        Select Case OpLO
            Case 0
                'SUB
                sOP = sOP & "SUB" & sOP1
                If Memory(Addr) > A Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                A = (256 + A - Memory(Addr)) And &HFF
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 1
                'CMP
                sOP = sOP & "CMP" & sOP1
                If Memory(Addr) > A Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                If ((256 + A - Memory(Addr)) And &HFF) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If ((256 + A - Memory(Addr)) And &HFF) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 2
                'SBC
                sOP = sOP & "SBC" & sOP1
                Reg = (CCR And &H1) + Memory(Addr)
                If Reg > A Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                A = (256 + A - Reg) And &HFF
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 3
                'CPX
                If X2Y Then sOP = sOP & "CPY" & sOP1 Else sOP = sOP & "CPX" & sOP1
                If Memory(Addr) > XY Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                If ((256 + XY - Memory(Addr)) And &HFF) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If ((256 + XY - Memory(Addr)) And &HFF) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 4
                'AND
                sOP = sOP & "AND" & sOP1
                A = (A And Memory(Addr))
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 5
                'BIT
                sOP = sOP & "BIT" & sOP1
                If (A And Memory(Addr)) And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If (A And Memory(Addr)) = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 6
                'LDA
                sOP = sOP & "LDA" & sOP1
                A = Memory(Addr)
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 7
                'STA
                sOP = sOP & "STA" & sOP1
                Memory(Addr) = A
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 8
                'EOR
                sOP = sOP & "EOR" & sOP1
                A = ((A Or Memory(Addr)) And (Not (A And Memory(Addr)) And &HFF))
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case 9
                'ADC
                sOP = sOP & "ADC" & sOP1
                tMath = CLng(A) + (CCR And &H1) + Memory(Addr)
                Reg = (A And &HF) + (Memory(Addr) And &HF) + (CCR And &H1)
                A = tMath And &HFF
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
                If tMath > &H100 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                If Reg >= &H10 Then CCR = CCR Or &H16 Else CCR = CCR And (Not (&H16) And &HFF)
            Case &HA
                'ORA
                sOP = sOP & "ORA" & sOP1
                A = (A Or Memory(Addr))
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HB
                'ADD
                sOP = sOP & "ADD" & sOP1
                tMath = CLng(A) + Memory(Addr)
                Reg = (A And &HF) + (Memory(Addr) And &HF) + (CCR And &H1)
                A = tMath And &HFF
                If A And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If A = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
                If tMath > &H100 Then CCR = CCR Or &H1 Else CCR = CCR And (Not (&H1) And &HFF)
                If Reg >= &H10 Then CCR = CCR Or &H16 Else CCR = CCR And (Not (&H16) And &HFF)
            Case &HC
                'JMP
                sOP = sOP & "JMP" & sOP1
                PC = Addr
            Case &HD
                'JSR
                sOP = sOP & "JSR" & sOP1
                Memory((TopStack And &HFF00) Or SP) = (&HFF And PC)
                SP = SP - 1
                Memory((TopStack And &HFF00) Or SP) = ((PC And &HFF00) / 256)
                SP = SP - 1
                PC = Addr
            Case &HE
                'LDX
                If X2Y Then sOP = sOP & "LDY" & sOP1 Else sOP = sOP & "LDX" & sOP1
                XY = Memory(Addr)
                If XY And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If XY = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
            Case &HF
                'STX
                If X2Y Then sOP = sOP & "STY" & sOP1 Else sOP = sOP & "STX" & sOP1
                Memory(Addr) = XY
                If XY And &H80 Then CCR = CCR Or &H4 Else CCR = CCR And (Not (&H4) And &HFF)
                If XY = 0 Then CCR = CCR Or &H2 Else CCR = CCR And (Not (&H2) And &HFF)
        End Select
        If X2Y Then Y = XY Else X = XY
End Select
StepCPU = sAddr & sOP
Randomize Timer
Memory(&H5) = Rnd * &HFF
Memory(&H6) = Rnd * &HFF
End Function

Public Sub GenIRQ(ByVal Vector As Double)
Memory((TopStack And &HFF00) Or SP) = (PC And &HFF)
SP = SP - 1
Memory((TopStack And &HFF00) Or SP) = (PC And &HFF00) / 256
SP = SP - 1
Memory((TopStack And &HFF00) Or SP) = X
SP = SP - 1
Memory((TopStack And &HFF00) Or SP) = A
SP = SP - 1
Memory((TopStack And &HFF00) Or SP) = CCR
SP = SP - 1
CCR = CCR Or &H8
PC = Vector
End Sub
