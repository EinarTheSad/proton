DEFINT A-Z
'--- DECLARE ---
DECLARE SUB Refresh (x, y, z, w, col)
DECLARE SUB sub Desktop ()
'$INCLUDE: 'logo.bi'

'--- CONSTANTS ---
Const ATTRIB.BOLD = 1, ATTRIB.UNDERLINE = 2, ATTRIB.ITALICS = 4
Const ALIGN.CENTER = -1, ALIGN.RIGHT = -2

'--- COMMON VARS ---
Common Shared B, H, V
Common Shared PID As String

Screen 9, , 1, 0
Refresh 0, 0, 639, 349, 3

MsgBox "$bEinar's DOS Development Platform$b reporting on duty.", 90, 80, "Acknowledged"
mouse 1

'--- MAIN LOOP ---
Do
    mouse 3 'Track mouse
    Select Case PID
        Case "MsgBox"
            If B = 1 Then
                End
            End If
    End Select
Loop Until InKey$ = "q"

End
'--- MAIN CODE ENDS HERE ---

'--- SUBS ---
'#####################################
'# Warning! Vital subs here ONLY!    #
'# All other subs should be put into #
'# separate files in a humane way!   #
'#####################################

Sub Desktop
	'Bitmap for testing purposes
    For j = 0 To 205
        For i = 0 To 87
            Read c
            PSet (i, j), c
        Next i
    Next j

    DrawIcon 8, 308, "comp"
    DrawIcon 48, 308, "i"
End Sub

Sub Refresh (x, y, z, w, col)
    'Any code that draws the desktop shall be put here
    View (x, y)-(z, w)
    Cls
    Paint (1, 1), col
    Desktop
    PCopy 1, 0
    View (0, 0)-(639, 349)
End Sub

'--- SUB INCLUDES (for QB64 debug purposes) ---
' Remember to load all the files in QB.EXE when
' compiling for MS-DOS.

'$INCLUDE: 'mouse.bas'
'$INCLUDE: 'gui.bas'
