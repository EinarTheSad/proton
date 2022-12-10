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
SCREENX = 800: SCREENY = 600 'Default resolution

'--- BOOT ROUTINE ---
Cls
Print "Starting Proton..."
Print "Provided by EinarTheSad, 2022"

'--- MAIN CODE ---
Cls
ScreenRes SCREENX, SCREENY, 32
'Dim Shared As Byte Ptr sbuffer: sbuffer = ScreenPtr

'Load the wallpaper into memory
wlp = ImageCreate(800,600)
Bload "./sky.bmp", wlp

Refresh
Dim Shared foobar As Form
foobar = Form (100,50,400,300,"Test window",1)
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
    View (SCREENX-92, 18)-(SCREENX-17, 36)
    ScreenLock()
    Cls: wrint (Time$, 2, 2, &H00FF00, "digital", 0)
    ScreenUnlock()
    View (0,0)-(SCREENX, SCREENY)
End Sub

Sub mouse (Funk as byte)
    SetMouse(,, Funk)
End Sub

Sub Refresh ()
    ScreenLock()
    Put (0, 0-(600-SCREENY)), wlp, pset
    'Icon placeholders
    BMPLoad ".\comp.bmp", 12, SCREENY - 48
    BMPLoad ".\dos.bmp", 12 + 32 + 16, SCREENY - 48
    ScreenUnlock()
    Exit Sub
End Sub

Sub Taskmgr
    Do
        If (ScreenEvent(@handler)) Then
        Select Case As Const handler.Type
        Case EVENT_MOUSE_BUTTON_PRESS
            foobar.Hide ()
        Case Else
            'foobar
        End Select
        End If
        Clock ()
        sleep 10, 1 'only for modern PCs, turn off in DOSBOX
    Loop Until InKey$ = "q"
    Exit Sub
End Sub
