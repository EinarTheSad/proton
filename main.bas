#include "types.bi"
#include "fbgfx.bi"
Using FB

'--- DECLARE ---
DECLARE FUNCTION colfont (ByVal source_pixel As ulong, ByVal destination_pixel As ulong, ByVal parameter As Any Ptr) As ulong
DECLARE SUB mouse (Funk as byte)
DECLARE SUB Taskmgr
DECLARE SUB Refresh
DECLARE SUB DrawButton (this As Button)
DECLARE SUB DrawForm (this As Form)
DECLARE SUB MsgBox (prompt as string, addwidth as integer, buttontext as string, title as string)
DECLARE SUB wrint (txt as string, x as integer, y as integer, c as integer, FontName as string, isBold As integer)
DECLARE SUB BMPLoad (bitmap As String, x As integer, y as integer)

'--- CONSTANTS ---
Const SCREENX = 640, SCREENY = 480

'--- COMMON VARS ---
Dim Shared As Integer B, H, V, dcolor, tbcolor, cfnt
Dim Shared As Event handler
tbcolor = &H0000AA: dcolor = &H007482 ' Titlebar and desktop colors

ScreenRes SCREENX, SCREENY, 32
width 80, 30
Cls

Refresh
Dim test As Form
test.x = 100: test.y = 50: test.w = 400: test.h = 300: test.title = "Test window"
DrawForm(test)
BMPLoad(".\logo.bmp", test.x + 2, test.y + 20)
mouse(1) 'Show cursor - after everything else is drawn

Taskmgr 'Contains the main loop
mouse(0) 'Hide cursor
MsgBox "This will end your Proton session", -10, "OK", "System termination"
mouse(1) 'Show again
Do:Loop Until inkey$ = "q"
End

'--- MAIN CODE ENDS HERE ---

'--- SUBS ---

Sub BMPLoad (bitmap As String, x As integer, y as integer)
    Dim As Long hdl
    Dim As Integer w, h
    Dim As Any Ptr BMP

    hdl = FreeFile()
    Open bitmap For Binary Access Read As #hdl
    ' Get bitmap dimensions from the file
    Get #hdl, 19, w
    Get #hdl, 23, h
    Close #hdl
    
    BMP = ImageCreate(w, Abs(h))

    BLoad bitmap, BMP
    Put (x, y), BMP, Trans
    ImageDestroy(BMP)
End Sub

Sub DrawButton (this As Button)
    Line (this.x, this.y)-(this.x + this.w, this.y + this.h), &HAAAAAA, BF 'main area
    Line (this.x, this.y)-(this.x + this.w, this.y + this.h), 0, B 'initial black outline
    Line (this.x + 1, this.y+1)-(this.x + this.w - 1, this.y + this.h - 1), &H555555, B 'dark gray frame
    Line (this.x + 2, this.y+1)-(this.x + this.w - 2, this.y + 1), &HDCDCDC 'light features
    Line (this.x + 1, this.y+1)-(this.x + 1, this.y + this.h - 2), &HDCDCDC 'to make it 3D
    wrint (this.label, this.x + this.w/2-len(this.label)*5, (this.y + this.h / 2) - 4, 0, "arial", 1) 'caption
    Exit Sub
End Sub

Sub DrawForm (this As Form)
    Line (this.x, this.y)-(this.x + this.w, this.y + 19), tbcolor, BF 'titlebar
    Line ((this.x + this.w - 17), this.y + 4)-((this.x + this.w - 4), this.y + 17), &HAAAAAA, BF 'x button
    Line ((this.x + this.w - 18), this.y + 3)-((this.x + this.w - 3), this.y + 18), &H555555, B 'or rather 3.1 kind of thing
    Line ((this.x + this.w - 13), this.y + 11)-((this.x + this.w - 6), this.y + 12), &H555555, B 'some shadow
    Line ((this.x + this.w - 14), this.y + 10)-((this.x + this.w - 7), this.y + 11), &HFFFFFF, BF 'and the - sign
    wrint (this.title, this.x + 6, this.y + 6, &HFFFFFF, "arial", 1) 'title, of course
    Line (this.x, this.y + 20)-(this.x + this.w, this.y + this.h), &HFFFFFF, BF 'main area
    Line (this.x, this.y)-(this.x + this.w, this.y + this.h), &H555555, B 'frame 1
    Line (this.x + 1, this.y + 1)-(this.x + this.w - 1, this.y + this.h - 1), &HAAAAAA, B 'frame 2
    Exit Sub
End Sub

Sub mouse (Funk as byte)
    SetMouse(,, Funk)
End Sub

Sub MsgBox (prompt as string, addwidth as integer, buttontext as string, title as string)
    'Okay, this is an absolute mess.
    'All the math is here to center the layout
    Dim As Integer windowlength, buttonlength
    windowlength = (Len(prompt) * 6) + 60 + addwidth '60 is an eyeballed value, 6 is mean character width
    buttonlength = 64 'Len(buttontext) * 6 + 17
    Dim MsgBoxForm As Form
    MsgBoxForm.x = SCREENX / 2 - windowlength / 2
    MsgBoxForm.y = SCREENY / 2 - 40
    MsgBoxForm.w = windowlength
    MsgBoxForm.h = 82 'arbitrary
    MsgBoxForm.title = title
    DrawForm MsgBoxForm
    BMPLoad ".\info.bmp", MsgBoxForm.x + 10, MsgBoxForm.y + 23
    wrint prompt, ((MsgBoxForm.x + 50)), MsgBoxForm.y + 34, 0, "arial", 0
    Dim MsgButton As Button
    MsgButton.x = ((MsgBoxForm.x + windowlength / 2) - buttonlength / 2)
    MsgButton.y = MsgBoxForm.y + 57
    MsgButton.w = buttonlength
    MsgButton.h = 19 'arbitrary
    MsgButton.label = buttontext
    DrawButton MsgButton
    Exit Sub
    'Forgive me, and if you know better - by all means, be my guest!
End Sub

Sub Refresh ()
    Cls: Paint(1,1),dcolor
	BMPLoad ".\logo.bmp", (SCREENX/2)-44, (SCREENY/2)-103
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
        'Test zegara
        Locate 2, 71: Color &H00FF00: Print Time$
        sleep 1
    Loop Until InKey$ = "q"
    Color 7
    Exit Sub
End Sub

Sub wrint (txt as string, x as integer, y as integer, c as integer, FontName as string, isBold As Integer)
    
    Dim As String FontPath = "./" + FontName + ".bmp"
	Dim As Long hdl = FreeFile()
	Dim As Integer w, h
    Open FontPath For Binary Access Read As #hdl
    ' Get bitmap dimensions from the file
    Get #hdl, 19, w
    Get #hdl, 23, h
    Close #hdl
    Dim as any ptr raw = ImageCreate(w, h)
    bload FontPath, raw
    cfnt = c
    If isBold = 0 Then
        Draw String (x,y), txt ,, raw, custom, @colfont
    Else
        Draw String (x,y), txt ,, raw, custom, @colfont
        Draw String (x+1,y), txt ,, raw, custom, @colfont 'Making the font bolder by printing the same string two times, shifted one pixel
    End If
    ImageDestroy(raw)
    Exit Sub    
End Sub

Function colfont (ByVal source_pixel As ulong, ByVal destination_pixel As ulong, ByVal parameter As Any Ptr) As ulong
    If source_pixel = RGB(0,0,0) Then
        Return destination_pixel
    Else
        Return cfnt
    End If
End Function