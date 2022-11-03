Sub Button (bx, by, bwidth, bheight, btext$, bcolor)
    Line (bx, by)-(bx + bwidth, by + bheight), bcolor, BF
    Line (bx, by)-(bx + bwidth, by + bheight), 0, B
    Line (bx + 1, by)-(bx + bwidth - 1, by + bheight - 1), 8, B
    If btext$ <> "" Then
        wrint btext$, bx + 8, by, 0, "arial", 0
    End If
End Sub

Sub Form (wx, wy, wwidth, wheight)
    Line (wx, wy)-(wx + wwidth, wy + wheight), 15, BF
    Line (wx, wy)-(wx + wwidth, wy + wheight), 8, B
    Line (wx + 1, wy + 1)-(wx + wwidth - 1, wy + wheight - 1), 7, B
End Sub

Sub MsgBox (prompt$, x, y, buttontext$)
    windowlength = Len(prompt$) * 5.58 + 60
    buttonlength = Len(buttontext$) * 5.58 + 32
    Form x, y, windowlength, 65
    DrawIcon x + 10, y + 5, "i"
    wrint prompt$, x + 46, y + 13, 0, "arial", 0
    'Button
    Button ((x + windowlength / 2) - buttonlength / 2), y + 40, buttonlength, 16, buttontext$, 7
    PID = "MsgBox"
    pcopy 1,0
End Sub

Sub DrawIcon (x%, y%, name$)
    View (x, y)-(x + 31, y + 31)
    Select Case name$
        Case "i"
            Circle (15, 15), 12, 0, , , .7
            Line (21, 23)-(26, 25), 0
            Line (25, 21)-(26, 25), 0
            Paint (16, 16), 15, 0: Paint (24, 23), 15, 0
            Line (21, 22)-(24, 21), 7
            Line (10, 22)-(20, 22), 7
            Line (14, 14)-(16, 19), 3, BF
            Line (14, 11)-(16, 12), 3, BF
            Line (13, 19)-(17, 19), 3
            PSet (13, 14), 3
        Case "comp"
            Line (10, 3)-(25, 4), 8, BF
            Line -(26, 16), 8, BF
            Line (8, 5)-(24, 17), 7, BF
            Line (8, 5)-(9, 4), 8
            PSet (24, 5), 8
            Line (9, 18)-(23, 18), 7
            Line (24, 18)-(25, 17), 8
            Line (7, 20)-(25, 24), 7, BF
            PSet (8, 22), 2: PSet (10, 22), 6
            Line (19, 22)-(24, 22), 8
            Line (8, 19)-(27, 19), 8: Line (24, 18)-(27, 18), 8
            Line (7, 19)-(26, 19), 0, , &H5555: Line (24, 18)-(27, 18), 0, , &H5555
            Line (26, 20)-(27, 22), 8, BF
            PSet (26, 23), 8
            For i = 0 To 3
                Line (6 - i, 26 + i)-(24 - i, 26 + i), 7: PSet (25 - i, 26 + i), 8
            Next i
            Line (6, 27)-(21, 27), 8, , &H5555: Line (5, 28)-(21, 28), 8, , &H5555
            Line (11, 7)-(21, 16), 0, BF: Line (10, 8)-(10, 15), 0: Line (22, 8)-(22, 15), 0
            Line (11, 10)-(11, 9), 8: Line (12, 8)-(13, 8), 8: Line (20, 15)-(21, 14), 8
            PSet (12, 9), 7
    End Select
    View (0, 0)-(639, 349)
End Sub
