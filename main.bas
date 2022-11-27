DefInt A-Z
'$DYNAMIC
'$INCLUDE: '.\types.bi'

'--- DECLARE ---
DECLARE SUB mouse (Funk)
DECLARE SUB Taskmgr ()
DECLARE SUB Refresh (col%, curshow%)
DECLARE SUB Desktop ()
DECLARE SUB Button (bx, by, bwidth%, bheight%, btext$, bcolor%)
DECLARE SUB DrawForm (this AS Form)
DECLARE SUB MsgBox (prompt$, addwidth%, buttontext$, title$)
DECLARE SUB wrint (txt$, x, y, c, FontFile$, Attribs%)
DECLARE SUB BMPLoad (bitmap$, x, y, transparency%)

'--- CONSTANTS ---
Const ATTRIB.BOLD = 1, ATTRIB.UNDERLINE = 2, ATTRIB.ITALICS = 4
Const ALIGN.CENTER = -1, ALIGN.RIGHT = -2
Const SCREENX = 640, SCREENY = 480

'--- COMMON VARS ---
Common Shared B, h, V
Common Shared dcolor As Integer
Common Shared tbcolor As Integer
tbcolor = 1: dcolor = 3 ' Titlebar and desktop colors

Screen 12: Color 15

Refresh dcolor, 0
'Testing window management
Dim test As Form
test.x = 100: test.y = 50: test.w = 400: test.h = 300: test.title = "Test window"
DrawForm test
BMPLoad ".\logo.bmp", test.x + 2, test.y + 21, 63
mouse 1 'Show cursor - after everything else is drawn

Taskmgr 'Contains the main loop
mouse 2 'Hide cursor
MsgBox "You can now turn the computer off", 0, "Thank you", "System termination"
mouse 2 'Show again
Do: Loop Until InKey$ <> ""
End

'--- MAIN CODE ENDS HERE ---

'--- SUBS ---

Sub BMPLoad (bitmap$, x, y, transparency%)
    Dim BmpHeader As BMPHeaderType: hdl& = FreeFile
    Open bitmap$ For Binary As hdl&
    Get #1, , BmpHeader
    Pixel$ = Space$(BmpHeader.wid) 'Loading a whole line at once
    iHeight% = BmpHeader.hei - 1
    iWidth% = BmpHeader.wid - 1
    View (x, y)-(x + iWidth%, y + iHeight%) 'Coordinates for the specific icon area
    For y% = iHeight% To 0 Step -1
        Get #1, , Pixel$
        For x% = 0 To iWidth%
            c% = Asc(Mid$(Pixel$, x% + 1, 1))
            If c% <> transparency% Then
                PSet (x%, y%), c%
            Else
                'just do nothing, because it's transparent
            End If
    Next x%, y%: Close hdl&
    View (0, 0)-(SCREENX - 1, SCREENY - 1) 'Reset the coordinates
    Exit Sub
End Sub

Sub Button (bx, by, bwidth%, bheight%, btext$, bcolor%)
    Line (bx, by)-(bx + bwidth%, by + bheight%), bcolor%, BF
    Line (bx, by)-(bx + bwidth%, by + bheight%), 0, B
    Line (bx + 1, by)-(bx + bwidth% - 1, by + bheight% - 1), 8, B
    wrint btext$, ((bx + bwidth% / 2) - (Len(btext$) * 7 / 2)), (by + bheight% / 2) - 8, 0, "arial", 1
    Exit Sub
End Sub

Sub Desktop
    'Icons
    BMPLoad ".\comp.bmp", 12, SCREENY - 48, 13
    BMPLoad ".\dos.bmp", 12 + 32 + 16, SCREENY - 48, 13
    Exit Sub
End Sub

Sub DrawForm (this As Form)
    Line (this.x, this.y)-(this.x + this.w, this.y + 20), tbcolor, BF 'titlebar
    Line ((this.x + this.w - 18), this.y + 4)-((this.x + this.w - 4), this.y + 18), 7, BF 'x button
    Line ((this.x + this.w - 19), this.y + 3)-((this.x + this.w - 3), this.y + 19), 8, B 'or rather 3.1 kind of thing
    Line ((this.x + this.w - 14), this.y + 11)-((this.x + this.w - 6), this.y + 13), 8, B 'some shadow
    Line ((this.x + this.w - 15), this.y + 10)-((this.x + this.w - 7), this.y + 12), 15, BF 'and the - sign
    wrint this.title, this.x + 5, this.y + 3, 15, "arial", 1 'title, of course
    Line (this.x, this.y + 21)-(this.x + this.w, this.y + this.h), 15, BF 'main area
    Line (this.x, this.y)-(this.x + this.w, this.y + this.h), 8, B 'frame 1
    Line (this.x + 1, this.y + 1)-(this.x + this.w - 1, this.y + this.h - 1), 7, B 'frame 2
    Exit Sub
End Sub

Sub mouse (Funk) Static
    'This is the standard routine for mouse access
    'See QuickBasic help for the same example
    Static Crsr
    If Funk = 1 Then Crsr = 1
    If Funk = 2 And Crsr = 0 Then Exit Sub
    If Funk = 2 And Crsr = 1 Then: Crsr = 0
    Poke 100, 184: Poke 101, Funk: Poke 102, 0
    Poke 103, 205: Poke 104, 51: Poke 105, 137
    Poke 106, 30: Poke 107, 170: Poke 108, 10
    Poke 109, 137: Poke 110, 14: Poke 111, 187
    Poke 112, 11: Poke 113, 137: Poke 114, 22
    Poke 115, 204: Poke 116, 12: Poke 117, 203
    Call Absolute(100)
    B = Peek(&HAAA)
    h = (Peek(&HBBB) + Peek(&HBBC) * 256)
    V = (Peek(&HCCC) + Peek(&HCCD) * 256)
End Sub

Sub MsgBox (prompt$, addwidth%, buttontext$, title$)
    'Okay, this is an absolute mess.
    'All the math is here to center the layout
    windowlength% = (Len(prompt$) * 6) + 60 + addwidth% '60 is an eyeballed value
    buttonlength% = Len(buttontext$) * 8 + 15 'Why the varying character length? Eyeballed too!
    Dim MsgBoxForm As Form
    MsgBoxForm.x = SCREENX / 2 - windowlength% / 2
    MsgBoxForm.y = SCREENY / 2 - 40
    MsgBoxForm.w = windowlength
    MsgBoxForm.h = 82 'arbitrary
    MsgBoxForm.title = title$
    DrawForm MsgBoxForm
    BMPLoad ".\info.bmp", MsgBoxForm.x + 10, MsgBoxForm.y + 23, 13
    wrint prompt$, ((MsgBoxForm.x + 47)), MsgBoxForm.y + 31, 0, "arial", 0
    Button ((MsgBoxForm.x + windowlength% / 2) - buttonlength% / 2), MsgBoxForm.y + 57, buttonlength%, 16, buttontext$, 7
    Exit Sub
    'Forgive me, and if you know better - by all means, be my guest!
End Sub

Sub Refresh (col%, curshow%)
    Line (0, 0)-(SCREENX, SCREENY), col%, BF
    Desktop
    If curshow% = 1 Then mouse 1
    Exit Sub
End Sub

Sub Taskmgr
    Do
        mouse 3 'Track mouse
        Select Case B
            Case 1: Refresh dcolor, 1
        End Select
        'Test zegara
        Locate 2, 71: Color 10: Print Time$
    Loop Until InKey$ = "q"
    Color 7
    Exit Sub
End Sub

Sub wrint (txt$, x, y, c, FontFile$, Attribs%)
    'WinFontsQB by Josh Heaton
    'font: displays a string of text.


    ' $b toggles bold
    ' $u toggles underlining
    ' $i toggles italics
    ' $$ prints 1 $
    ' $c changes text color at draw-time

    Dim Char As FontCharInfo
    OrgAttribs% = Attribs%

    FontFile$ = ".\" + FontFile$ + ".fnt"

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
        tx& = (SCREENX \ 2) - (tx& \ 2)
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
        tx& = SCREENX - tx&
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
    Exit Sub
End Sub

