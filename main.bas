'+-------------------------+
'| PROTON MAIN SOURCE FILE |
'|    EinarTheSad, 2022    |
'+-------------------------+
'| Since it's FreeBasic, we|
'| can keep the code tidy  |
'| by moving subroutines to|
'| separate modules!       |
'+-------------------------+

#include "fbgfx.bi"
#include "types.bi"

Using FB

'--- DECLARE ---
DECLARE SUB mouse (Funk as byte)
DECLARE SUB Taskmgr
DECLARE SUB Refresh ()

'--- COMMON VARS ---
Common Shared As Event handler
tbcolor = &H0000AA: dcolor = &H007482 ' Titlebar and desktop colors
SCREENX = 640: SCREENY = 480 'Default resolution

'--- BOOT ROUTINE ---
Cls
Print "Starting Proton..."
Print "Provided by EinarTheSad, 2022"

'--- MAIN CODE ---
Cls
ScreenRes SCREENX, SCREENY, 32 : width 80,30
Dim Shared As Byte Ptr sbuffer: sbuffer = ScreenPtr

'Load the wallpaper into memory
Dim Shared As Image ptr wlp
wlp = ImageCreate(800,600)
Bload "./sky.bmp", wlp

Refresh
Dim foobar As Form = Form (100,50,400,300,"Test window",1)
foobar.Show()
BMPLoad(".\logo.bmp", foobar.x + 2, foobar.y + 20)
Taskmgr 'Contains the main loop
'If we're out of Taskmgr, it means we are finishing
ImageDestroy(wlp) 'Tidying up
MsgBox "This will end your Proton session", -10, "OK", "System termination"
Do
    If (ScreenEvent(@handler)) Then
        Select Case As Const handler.Type
        Case EVENT_MOUSE_BUTTON_PRESS
            End
        End Select
    End If
Loop
'--- MAIN CODE ENDS HERE ---

'--- SUBS (DON'T PUT LONG ROUTINES HERE) ---

Sub Clock ()
    line (SCREENX-92, 18)-(SCREENX-17,36), 0, bf
    wrint (Time$, SCREENX-90, 20, &H00FF00, "digital", 0)
    Exit Sub
End Sub

Sub mouse (Funk as byte)
    SetMouse(,, Funk)
End Sub

Sub Refresh ()
    'Dim As Long x, y: ScreenInfo( , y, , , x )
    'ScreenLock(): Clear *sbuffer, 0, x*y : ScreenUnlock() 'This is a faster version of CLS, filling the buffer with color byte
    Put (0, 0-(600-SCREENY)), wlp, pset
    BMPLoad ".\comp.bmp", 12, SCREENY - 48
    BMPLoad ".\dos.bmp", 12 + 32 + 16, SCREENY - 48
    Exit Sub
End Sub

Sub Taskmgr
    Do
        If (ScreenEvent(@handler)) Then
        Select Case As Const handler.Type
        Case EVENT_MOUSE_BUTTON_PRESS
            Refresh
        Case Else
            'foobar
        End Select
        End If
        Clock ()
        sleep 10, 1
    Loop Until InKey$ = "q"
    Exit Sub
End Sub