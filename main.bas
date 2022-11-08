DEFINT A-Z
'--- DECLARE ---
DECLARE SUB mouse (Funk)
DECLARE SUB Taskmgr ()
DECLARE SUB Refresh (col%)
DECLARE SUB Desktop ()
DECLARE SUB Button (bx, by, bwidth, bheight, btext$, bcolor)
DECLARE SUB Form (wx, wy, wwidth, wheight)
DECLARE SUB MsgBox (prompt$, x, y, buttontext$, PID)
DECLARE SUB DrawIcon (x%, y%, name$)
DECLARE SUB wrint (txt$, x, y, c, FontFile$, Attribs%)
DECLARE SUB BMLoad (bitmap$, x, y, z, w)

'--- CONSTANTS ---
CONST ATTRIB.BOLD = 1, ATTRIB.UNDERLINE = 2, ATTRIB.ITALICS = 4
CONST ALIGN.CENTER = -1, ALIGN.RIGHT = -2

'--- COMMON VARS ---
COMMON SHARED B, H, V
COMMON SHARED GiveControl%, ProcNum%
DIM SHARED Drawn(10) AS INTEGER

SCREEN 9, , 1, 0
Refresh 3

'--- MAIN LOOP ---
DO
    mouse 3 'Track mouse
    MsgBox "$bProton 0.23$b reporting on duty.", 120, 100, "Acknowledged", 1
    Taskmgr 'Run the task manager
LOOP UNTIL INKEY$ = "q" ' Temporary escape

'--- MAIN CODE ENDS HERE ---

'--- SUBS ---

TYPE FontCharInfo
    CharWidth AS INTEGER
    CharHeight AS INTEGER
    FileOffset AS LONG
END TYPE

SUB BMLoad (bitmap$, x, y, z, w)
    bsaveSize = z * w / 2
    DIM load(bsaveSize) AS INTEGER
    DEF SEG = VARSEG(load(0))
    BLOAD bitmap$ + ".put", VARPTR(load(0))
    PUT (x, y), load, PSET
    DEF SEG
END SUB

SUB Button (bx, by, bwidth, bheight, btext$, bcolor)
    LINE (bx, by)-(bx + bwidth, by + bheight), bcolor, BF
    LINE (bx, by)-(bx + bwidth, by + bheight), 0, B
    LINE (bx + 1, by)-(bx + bwidth - 1, by + bheight - 1), 8, B
    IF btext$ <> "" THEN
        wrint btext$, bx + 8, by, 0, "arial", 0
    END IF
END SUB

SUB Desktop
    'Bitmap for testing purposes
    BMLoad "logo", 272, 72, 88, 206
    'Icons
    DrawIcon 8, 308, "comp"
    DrawIcon 48, 308, "i"
END SUB

SUB DrawIcon (x%, y%, name$)
    VIEW (x, y)-(x + 31, y + 31)
    SELECT CASE name$
        CASE "i"
            CIRCLE (15, 15), 12, 0, , , .7
            LINE (21, 23)-(26, 25), 0
            LINE (25, 21)-(26, 25), 0
            PAINT (16, 16), 15, 0: PAINT (24, 23), 15, 0
            LINE (21, 22)-(24, 21), 7
            LINE (10, 22)-(20, 22), 7
            LINE (14, 14)-(16, 19), 3, BF
            LINE (14, 11)-(16, 12), 3, BF
            LINE (13, 19)-(17, 19), 3
            PSET (13, 14), 3
        CASE "comp"
            LINE (10, 3)-(25, 4), 8, BF
            LINE -(26, 16), 8, BF
            LINE (8, 5)-(24, 17), 7, BF
            LINE (8, 5)-(9, 4), 8
            PSET (24, 5), 8
            LINE (9, 18)-(23, 18), 7
            LINE (24, 18)-(25, 17), 8
            LINE (7, 20)-(25, 24), 7, BF
            PSET (8, 22), 2: PSET (10, 22), 6
            LINE (19, 22)-(24, 22), 8
            LINE (8, 19)-(27, 19), 8: LINE (24, 18)-(27, 18), 8
            LINE (7, 19)-(26, 19), 0, , &H5555: LINE (24, 18)-(27, 18), 0, , &H5555
            LINE (26, 20)-(27, 22), 8, BF
            PSET (26, 23), 8
            FOR i = 0 TO 3
                LINE (6 - i, 26 + i)-(24 - i, 26 + i), 7: PSET (25 - i, 26 + i), 8
            NEXT i
            LINE (6, 27)-(21, 27), 8, , &H5555: LINE (5, 28)-(21, 28), 8, , &H5555
            LINE (11, 7)-(21, 16), 0, BF: LINE (10, 8)-(10, 15), 0: LINE (22, 8)-(22, 15), 0
            LINE (11, 10)-(11, 9), 8: LINE (12, 8)-(13, 8), 8: LINE (20, 15)-(21, 14), 8
            PSET (12, 9), 7
    END SELECT
    VIEW (0, 0)-(639, 349)
END SUB

SUB Form (wx, wy, wwidth, wheight)
    LINE (wx, wy)-(wx + wwidth, wy + wheight), 15, BF
    LINE (wx, wy)-(wx + wwidth, wy + wheight), 8, B
    LINE (wx + 1, wy + 1)-(wx + wwidth - 1, wy + wheight - 1), 7, B
END SUB

SUB mouse (Funk) STATIC
    STATIC Crsr
    IF Funk = 1 THEN Crsr = 1
    IF Funk = 2 AND Crsr = 0 THEN EXIT SUB
    IF Funk = 2 AND Crsr = 1 THEN : Crsr = 0
    POKE 100, 184: POKE 101, Funk: POKE 102, 0
    POKE 103, 205: POKE 104, 51: POKE 105, 137
    POKE 106, 30: POKE 107, 170: POKE 108, 10
    POKE 109, 137: POKE 110, 14: POKE 111, 187
    POKE 112, 11: POKE 113, 137: POKE 114, 22
    POKE 115, 204: POKE 116, 12: POKE 117, 203
    CALL Absolute(100)
    B = PEEK(&HAAA)
    H = (PEEK(&HBBB) + PEEK(&HBBC) * 256)
    V = (PEEK(&HCCC) + PEEK(&HCCD) * 256)
END SUB

SUB MsgBox (prompt$, x, y, buttontext$, PID)
    IF Drawn(PID) = 0 THEN
        windowlength = (LEN(prompt$) * 5.58) + 60
        buttonlength = LEN(buttontext$) * 5.58 + 32
        Form x, y, windowlength, 65
        DrawIcon x + 10, y + 5, "i"
        wrint prompt$, x + 46, y + 13, 0, "arial", 0
        Button ((x + windowlength / 2) - buttonlength / 2), y + 40, buttonlength, 16, buttontext$, 7
        Drawn(PID) = 1
    ELSE
        'Task manager part
        IF GiveControl = PID THEN
            IF B = 1 THEN
                Refresh 3
            END IF
        END IF
    END IF
END SUB

SUB Refresh (col%)
    'Any code that draws the desktop shall be put here
    mouse 2
    CLS : PAINT (1, 1), col
    Desktop
    PCOPY 1, 0
    mouse 1
END SUB

SUB Taskmgr
    IF ProcNum < 10 THEN
        GiveControl = ProcNum
        ProcNum = ProcNum + 1
    ELSE
        ProcNum = 0
    END IF
    PCOPY 1, 0
END SUB

SUB wrint (txt$, x, y, c, FontFile$, Attribs%)
    'WinFontsQB by Josh Heaton
    'font: displays a string of text.


    ' $b toggles bold
    ' $u toggles underlining
    ' $i toggles italics
    ' $$ prints 1 $
    ' $c changes text color at draw-time

    DIM Char AS FontCharInfo
    OrgAttribs% = Attribs%

    a% = INSTR(FontFile$, ".")
    IF a% = 0 THEN FontFile$ = FontFile$ + ".fnt"

    Handle = FREEFILE
    OPEN FontFile$ FOR BINARY AS #Handle
    IF LOF(Handle) = 0 THEN
        CLOSE #Handle
        KILL FontFile$
        EXIT SUB
    END IF

    Version% = 0
    GET #Handle, , Version%
    IF (Version% MOD 256 <> 0) OR (Version% \ 256 <> 1) THEN
        'Incorrect version
        CLOSE #Handle
        EXIT SUB
    END IF

    ty& = y%
     
    IF x% = ALIGN.CENTER THEN
        tx& = 0
        Widest& = 0
        FixLR% = 0
        FOR i% = 1 TO LEN(txt$)
            CharCnt% = ASC(MID$(txt$, i%, 1)) - 32
            IF CharCnt% = -19 THEN
                IF tx& > Widest& THEN Widest& = tx&: tx& = 0
                FixLR% = 1
            ELSEIF CharCnt% = ASC("$") - 32 THEN
                'Special formatting code
                i% = i% + 1
                Code$ = LCASE$(MID$(txt$, i%, 1))
                'IF code$ = "b" THEN GOSUB ToggleBold       ' Don't run these
                'IF code$ = "u" THEN GOSUB ToggleUnderline  ' on centering
                'IF code$ = "i" THEN GOSUB ToggleItalics    ' just yet...
                IF Code$ = "$" THEN
                    'Crank out a dollar sign on the screen
                    CharCnt% = ASC("$") - 32
                    GOTO CountCharWidthForCentering:
                          
                END IF
            ELSE
CountCharWidthForCentering:
                SEEK #Handle, (2 + 2 + 4) * CharCnt% + 1 + 2
                GET #Handle, , Char
                tx& = tx& + Char.CharWidth
            END IF
        NEXT
        IF tx& > Widest& THEN Widest& = tx&
        tx& = (screenresx \ 2) - (tx& \ 2)
    ELSEIF x% = ALIGN.RIGHT THEN
        tx& = 0
        Widest& = 0
        FixLR% = 0
        FOR i% = 1 TO LEN(txt$)
            CharCnt% = ASC(MID$(txt$, i%, 1)) - 32
            IF CharCnt% = -19 THEN
                IF tx& > Widest& THEN Widest& = tx&: tx& = 0
                FixLR% = 1
            ELSEIF CharCnt% = ASC("$") - 32 THEN
                'Special formatting code
                i% = i% + 1
                Code$ = LCASE$(MID$(txt$, i%, 1))
                IF Code$ = "$" THEN
                    'Crank out a dollar sign on the screen
                    CharCnt% = ASC("$") - 32
                    GOTO CountCharWidthForRight:
                END IF
            ELSE
CountCharWidthForRight:
                SEEK #Handle, (2 + 2 + 4) * CharCnt% + 1 + 2
                GET #Handle, , Char
                tx& = tx& + Char.CharWidth
            END IF
        NEXT
        IF tx& > Widest& THEN Widest& = tx&
        tx& = screenresx - tx&
    ELSE
        tx& = x%
    END IF
    ttx& = tx&
    FOR i% = 1 TO LEN(txt$)
        CharCnt% = ASC(MID$(txt$, i%, 1))
        FixLR% = 0
        IF CharCnt% = 13 THEN
            'Line return, fix it
            FixLR% = 1
            CharCnt% = ASC("A") - 32
        ELSEIF CharCnt% = ASC("$") THEN
            'Special formatting code
            i% = i% + 1
            Code$ = LCASE$(MID$(txt$, i%, 1))
            IF Code$ = "b" THEN GOSUB ToggleBold: CharCnt% = -1
            IF Code$ = "u" THEN GOSUB ToggleUnderline: CharCnt% = -1
            IF Code$ = "i" THEN GOSUB ToggleItalics: CharCnt% = -1
            IF Code$ = "c" THEN GOSUB SetTempColor: CharCnt% = -1
       
            IF Code$ = "$" THEN
                'Crank out a dollar sign on the screen
                CharCnt% = ASC("$") - 32
            END IF
        ELSEIF CharCnt% < 32 OR CharCnt% > 126 THEN
            CharCnt% = 127
        ELSE
            CharCnt% = CharCnt% - 32
        END IF
        IF CharCnt% > -1 THEN
            SEEK #Handle, (2 + 2 + 4) * CharCnt% + 1 + 2
            GET #Handle, , Char
            SEEK #Handle, Char.FileOffset
            REDIM CharDat&(Char.CharHeight)
            IF FixLR% <> 0 THEN
                'Do a line return
                ttx& = tx&
                ty& = ty& + Char.CharHeight
                FixLR% = 0
            ELSE
                'Draw char on screen
                IF CharCnt% <> 0 THEN
                    'Don't draw a space because there is a bug for some reason.
                    FOR cty% = 0 TO Char.CharHeight - 1
                        t% = 0
                        GET #Handle, , t%
                        CharDat&(cty%) = t%
                        offset% = 0
                        IF (Attribs% AND ATTRIB.ITALICS) <> 0 THEN offset% = -cty% / 3
                        LINE (ttx& + offset%, ty& + cty%)-(ttx& + 16 + offset%, ty& + cty%), c%, , CharDat&(cty%) ' MOD 32767
                        IF (Attribs% AND ATTRIB.BOLD) <> 0 THEN
                            LINE (ttx& + offset% + 1, ty& + cty%)-(ttx& + 17 + offset%, ty& + cty%), c%, , CharDat&(cty%) ' MOD 32767
                        END IF
                    NEXT
                END IF
                IF (Attribs% AND ATTRIB.UNDERLINE) <> 0 THEN LINE (ttx&, Char.CharHeight - 2 + ty&)-(ttx& + Char.CharWidth, Char.CharHeight - 2 + ty&), c%
                ttx& = ttx& + Char.CharWidth
            END IF
        END IF
    NEXT

    CLOSE #Handle

    Attribs% = OrgAttribs%

    EXIT SUB

ToggleBold:

    IF (Attribs% AND ATTRIB.BOLD) <> 0 THEN
        Attribs% = Attribs% - ATTRIB.BOLD
    ELSE
        Attribs% = Attribs% + ATTRIB.BOLD
    END IF

    RETURN

ToggleUnderline:

    IF (Attribs% AND ATTRIB.UNDERLINE) <> 0 THEN
        Attribs% = Attribs% - ATTRIB.UNDERLINE
    ELSE
        Attribs% = Attribs% + ATTRIB.UNDERLINE
    END IF

    RETURN

ToggleItalics:

    IF (Attribs% AND ATTRIB.ITALICS) <> 0 THEN
        Attribs% = Attribs% - ATTRIB.ITALICS
    ELSE
        Attribs% = Attribs% + ATTRIB.ITALICS
    END IF

    RETURN

SetTempColor:

    clr$ = ""

    i% = i% + 1 'Get past the "c"

    WHILE INSTR("0123456789", MID$(txt$, i%, 1))
        clr$ = clr$ + MID$(txt$, i%, 1)
        i% = i% + 1
    WEND

    i% = i% - 1 'Back up one char

    c% = VAL(clr$)

    RETURN

END SUB

