Type FontCharInfo
    CharWidth As Integer
    CharHeight As Integer
    FileOffset As Long
End Type

Sub wrint (txt$, x%, y%, c%, FontFile$, Attribs%)
    'WinFontsQB by Josh Heaton
    'font: displays a string of text.


    ' $b toggles bold
    ' $u toggles underlining
    ' $i toggles italics
    ' $$ prints 1 $
    ' $c changes text color at draw-time

    '--- CONSTANTS ---
    Const ATTRIB.BOLD = 1, ATTRIB.UNDERLINE = 2, ATTRIB.ITALICS = 4
    Const ALIGN.CENTER = -1, ALIGN.RIGHT = -2

    Dim Char As FontCharInfo
    OrgAttribs% = Attribs%

    a% = InStr(FontFile$, ".")
    If a% = 0 Then FontFile$ = FontFile$ + ".fnt"

    Handle = FreeFile
    Open FontFile$ For Binary As #Handle
    If LOF(Handle) = 0 Then
        Close #Handle
        Kill FontFile$
        Exit Sub
    End If

    Version% = 0
    Get #Handle, , Version%
    If (Version% Mod 256 <> 0) Or (Version% \ 256 <> 1) Then
        'Incorrect version
        Close #Handle
        Exit Sub
    End If

    ty& = y%
     
    If x% = ALIGN.CENTER Then
        tx& = 0
        Widest& = 0
        FixLR% = 0
        For i% = 1 To Len(txt$)
            CharCnt% = Asc(Mid$(txt$, i%, 1)) - 32
            If CharCnt% = -19 Then
                If tx& > Widest& Then Widest& = tx&: tx& = 0
                FixLR% = 1
            ElseIf CharCnt% = Asc("$") - 32 Then
                'Special formatting code
                i% = i% + 1
                Code$ = LCase$(Mid$(txt$, i%, 1))
                'IF code$ = "b" THEN GOSUB ToggleBold       ' Don't run these
                'IF code$ = "u" THEN GOSUB ToggleUnderline  ' on centering
                'IF code$ = "i" THEN GOSUB ToggleItalics    ' just yet...
                If Code$ = "$" Then
                    'Crank out a dollar sign on the screen
                    CharCnt% = Asc("$") - 32
                    GoTo CountCharWidthForCentering:
                          
                End If
            Else
                CountCharWidthForCentering:
                Seek #Handle, (2 + 2 + 4) * CharCnt% + 1 + 2
                Get #Handle, , Char
                tx& = tx& + Char.CharWidth
            End If
        Next
        If tx& > Widest& Then Widest& = tx&
        tx& = (screenresx \ 2) - (tx& \ 2)
    ElseIf x% = ALIGN.RIGHT Then
        tx& = 0
        Widest& = 0
        FixLR% = 0
        For i% = 1 To Len(txt$)
            CharCnt% = Asc(Mid$(txt$, i%, 1)) - 32
            If CharCnt% = -19 Then
                If tx& > Widest& Then Widest& = tx&: tx& = 0
                FixLR% = 1
            ElseIf CharCnt% = Asc("$") - 32 Then
                'Special formatting code
                i% = i% + 1
                Code$ = LCase$(Mid$(txt$, i%, 1))
                If Code$ = "$" Then
                    'Crank out a dollar sign on the screen
                    CharCnt% = Asc("$") - 32
                    GoTo CountCharWidthForRight:
                End If
            Else
                CountCharWidthForRight:
                Seek #Handle, (2 + 2 + 4) * CharCnt% + 1 + 2
                Get #Handle, , Char
                tx& = tx& + Char.CharWidth
            End If
        Next
        If tx& > Widest& Then Widest& = tx&
        tx& = screenresx - tx&
    Else
        tx& = x%
    End If
    ttx& = tx&
    For i% = 1 To Len(txt$)
        CharCnt% = Asc(Mid$(txt$, i%, 1))
        FixLR% = 0
        If CharCnt% = 13 Then
            'Line return, fix it
            FixLR% = 1
            CharCnt% = Asc("A") - 32
        ElseIf CharCnt% = Asc("$") Then
            'Special formatting code
            i% = i% + 1
            Code$ = LCase$(Mid$(txt$, i%, 1))
            If Code$ = "b" Then GoSub ToggleBold: CharCnt% = -1
            If Code$ = "u" Then GoSub ToggleUnderline: CharCnt% = -1
            If Code$ = "i" Then GoSub ToggleItalics: CharCnt% = -1
            If Code$ = "c" Then GoSub SetTempColor: CharCnt% = -1
       
            If Code$ = "$" Then
                'Crank out a dollar sign on the screen
                CharCnt% = Asc("$") - 32
            End If
        ElseIf CharCnt% < 32 Or CharCnt% > 126 Then
            CharCnt% = 127
        Else
            CharCnt% = CharCnt% - 32
        End If
        If CharCnt% > -1 Then
            Seek #Handle, (2 + 2 + 4) * CharCnt% + 1 + 2
            Get #Handle, , Char
            Seek #Handle, Char.FileOffset
            ReDim CharDat&(Char.CharHeight)
            If FixLR% <> 0 Then
                'Do a line return
                ttx& = tx&
                ty& = ty& + Char.CharHeight
                FixLR% = 0
            Else
                'Draw char on screen
                If CharCnt% <> 0 Then
                    'Don't draw a space because there is a bug for some reason.
                    For cty% = 0 To Char.CharHeight - 1
                        t% = 0
                        Get #Handle, , t%
                        CharDat&(cty%) = t%
                        offset% = 0
                        If (Attribs% And ATTRIB.ITALICS) <> 0 Then offset% = -cty% / 3
                        Line (ttx& + offset%, ty& + cty%)-(ttx& + 16 + offset%, ty& + cty%), c%, , CharDat&(cty%) ' MOD 32767
                        If (Attribs% And ATTRIB.BOLD) <> 0 Then
                            Line (ttx& + offset% + 1, ty& + cty%)-(ttx& + 17 + offset%, ty& + cty%), c%, , CharDat&(cty%) ' MOD 32767
                        End If
                    Next
                End If
                If (Attribs% And ATTRIB.UNDERLINE) <> 0 Then Line (ttx&, Char.CharHeight - 2 + ty&)-(ttx& + Char.CharWidth, Char.CharHeight - 2 + ty&), c%
                ttx& = ttx& + Char.CharWidth
            End If
        End If
    Next

    Close #Handle

    Attribs% = OrgAttribs%

    Exit Sub

    ToggleBold:

    If (Attribs% And ATTRIB.BOLD) <> 0 Then
        Attribs% = Attribs% - ATTRIB.BOLD
    Else
        Attribs% = Attribs% + ATTRIB.BOLD
    End If

    Return

    ToggleUnderline:

    If (Attribs% And ATTRIB.UNDERLINE) <> 0 Then
        Attribs% = Attribs% - ATTRIB.UNDERLINE
    Else
        Attribs% = Attribs% + ATTRIB.UNDERLINE
    End If

    Return

    ToggleItalics:

    If (Attribs% And ATTRIB.ITALICS) <> 0 Then
        Attribs% = Attribs% - ATTRIB.ITALICS
    Else
        Attribs% = Attribs% + ATTRIB.ITALICS
    End If

    Return

    SetTempColor:

    clr$ = ""

    i% = i% + 1 'Get past the "c"

    While InStr("0123456789", Mid$(txt$, i%, 1))
        clr$ = clr$ + Mid$(txt$, i%, 1)
        i% = i% + 1
    Wend

    i% = i% - 1 'Back up one char

    c% = Val(clr$)

    Return

End Sub
