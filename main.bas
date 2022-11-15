DefInt A-Z
'--- DECLARE ---
DECLARE SUB mouse (Funk)
DECLARE SUB Taskmgr ()
DECLARE SUB Refresh (col%)
DECLARE SUB Desktop ()
DECLARE SUB Button (bx, by, bwidth, bheight, btext$, bcolor)
DECLARE SUB Form (wx, wy, wwidth, wheight)
DECLARE SUB MsgBox (prompt$, x, y, addwidth, buttontext$, PID)
DECLARE SUB DrawIcon (x%, y%, name$)
DECLARE SUB wrint (txt$, x, y, c, FontFile$, Attribs%)
DECLARE SUB BMPLoad (bitmap$, x, y, transparency%)

'--- CONSTANTS ---
Const ATTRIB.BOLD = 1, ATTRIB.UNDERLINE = 2, ATTRIB.ITALICS = 4
Const ALIGN.CENTER = -1, ALIGN.RIGHT = -2
Const SCREENX = 640, SCREENY = 480

'--- COMMON VARS ---
Common Shared B, H, V
Common Shared GiveControl%, ProcNum%
Dim Shared Drawn(10) As Integer
Common Shared dcolor As Integer: dcolor = 3

Screen 12

Refresh dcolor
mouse 1 'Show cursor
MsgBox "$bProton 0.23$b has booted. Welcome to the system!", 145, 208, 32, "Close", 1

'--- MAIN LOOP ---
Do
    Taskmgr 'Run the task manager
Loop Until InKey$ = "q" ' Temporary escape

'--- MAIN CODE ENDS HERE ---

'--- SUBS ---

Type FontCharInfo
    CharWidth As Integer
    CharHeight As Integer
    FileOffset As Long
End Type

Type BMPHeaderType
    id As String * 2 'Should be "BM"
    size As Long 'Size of the data
    rr1 As Integer '
    rr2 As Integer '
    offset As Long 'Position of start of pixel data
    horz As Long '
    wid As Long 'Image width
    hei As Long 'Image height
    planes As Integer '
    bpp As Integer 'Should read 8 for a 256 colour image
    pakbyte As Long '
    imagebytes As Long 'Width*Height
    xres As Long '
    yres As Long '
    colch As Long '
    ic As Long '
    pal As String * 1024
End Type

Sub BMPLoad (bitmap$, x, y, transparency%)
    Dim BmpHeader As BMPHeaderType: hdl& = FreeFile
    Open bitmap$ For Binary As hdl&
    Get #1, , BmpHeader
    Pixel$ = Space$(BmpHeader.wid)
    iHeight% = BmpHeader.hei - 1
    iWidth% = BmpHeader.wid - 1
    View (x, y)-(x + iWidth%, y + iHeight%)
    For y% = iHeight% To 0 Step -1
        Get #1, , Pixel$
        For x% = 0 To iWidth%
            c% = Asc(Mid$(Pixel$, x% + 1, 1))
            If c% <> transparency% Then
                PSet (x%, y%), c%
            Else
                'just do nothing
            End If
    Next x%, y%: Close hdl&
    View (0, 0)-(SCREENX - 1, SCREENY - 1)
End Sub

Sub Button (bx, by, bwidth, bheight, btext$, bcolor)
    Line (bx, by)-(bx + bwidth, by + bheight), bcolor, BF
    Line (bx, by)-(bx + bwidth, by + bheight), 0, B
    Line (bx + 1, by)-(bx + bwidth - 1, by + bheight - 1), 8, B
    If btext$ <> "" Then
        wrint btext$, bx + 8, by, 0, "arial", 1
    End If
End Sub

Sub Desktop
    'Bitmaps for testing purposes
    BMPLoad ".\logo.bmp", 272, 137, 63
    'Icons
    BMPLoad ".\comp.bmp", 12, SCREENY - 48, 13
    BMPLoad ".\dos.bmp", 12 + 32 + 16, SCREENY - 48, 13
End Sub

Sub Form (wx, wy, wwidth, wheight)
    Line (wx, wy)-(wx + wwidth, wy + wheight), 15, BF
    Line (wx, wy)-(wx + wwidth, wy + wheight), 8, B
    Line (wx + 1, wy + 1)-(wx + wwidth - 1, wy + wheight - 1), 7, B
End Sub

Sub mouse (Funk) Static
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
    H = (Peek(&HBBB) + Peek(&HBBC) * 256)
    V = (Peek(&HCCC) + Peek(&HCCD) * 256)
End Sub

Sub MsgBox (prompt$, x, y, addwidth, buttontext$, PID)
    If Drawn(PID) = 0 Then
        windowlength = (Len(prompt$) * 5) + 60 + addwidth
        buttonlength = Len(buttontext$) * 5 + 32
        Form x, y, windowlength, 65
        BMPLoad ".\info.bmp", x + 10, y + 5, 13
        wrint prompt$, x + 46, y + 13, 0, "arial", 0
        Button ((x + windowlength / 2) - buttonlength / 2), y + 40, buttonlength, 16, buttontext$, 7
        Drawn(PID) = 1
    Else
        'Task manager part
        If GiveControl = PID Then
            If B = 1 Then
                Refresh 3
            End If
        End If
    End If
End Sub

Sub Refresh (col%)
    'Any code that draws the desktop shall be put here
    Cls: Paint (1, 1), col
    Desktop
    
End Sub

Sub Taskmgr
    mouse 3 'Track mouse
    If ProcNum < 10 Then
        GiveControl = ProcNum
        ProcNum = ProcNum + 1
    Else
        ProcNum = 0
    End If
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

