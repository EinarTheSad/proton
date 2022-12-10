#include "fbgfx.bi"
Using FB
DECLARE FUNCTION colfont (ByVal source_pixel As ulong, ByVal destination_pixel As ulong, ByVal parameter As Any Ptr) As ulong
DECLARE SUB BMPLoad (bitmap As String, x As integer, y as integer)
DECLARE SUB MsgBox (prompt as string, addwidth as integer, buttontext as string, title as string)
DECLARE SUB wrint (txt as string, x as integer, y as integer, c as integer, FontName as string, isBold As integer)

Common Shared As Integer SCREENX, SCREENY, dcolor, tbcolor, cfnt
Common Shared As Image ptr wlp, forewindow
Common Shared As Byte pid

TYPE Button
	x AS INTEGER
    y AS INTEGER
    w AS INTEGER
    h AS INTEGER
	label AS STRING
	isClicked AS BYTE
    Declare Constructor (As Integer, As Integer, As Integer, As Integer, As String)
    Declare Sub Show ()
END TYPE

Constructor Button (x As Integer, y As Integer, w As Integer, h As Integer, label As String)
    this.x = x
    this.y = y
    this.w = w
    this.h = h
    this.label = label
    Show ()
End Constructor

Sub Button.Show ()
    ScreenLock()
    Line (x, y)-(x + w, y + h), &HAAAAAA, BF 'main area
    Line (x, y)-(x + w, y + h), 0, B 'initial black outline
    Line (x + 1, y+1)-(x + w - 1, y + h - 1), &H555555, B 'dark gray frame
    Line (x + 2, y+1)-(x + w - 2, y + 1), &HDCDCDC 'light features
    Line (x + 1, y+1)-(x + 1, y + h - 2), &HDCDCDC 'to make it 3D
    wrint (label, x + w/2-len(label)*5, (y + h / 2) - 4, 0, "arial", 1) 'caption
    ScreenUnlock()
    Exit Sub
End Sub

TYPE Form
    x AS INTEGER
    y AS INTEGER
    w AS INTEGER
    h AS INTEGER
    title AS STRING
    isFocus AS BYTE
    isShown AS BYTE
    Declare Constructor ()
    'Declare Destructor ()
    Declare Constructor (As Integer, As Integer, As Integer, As Integer, As String, As Byte)
    Declare Sub Show ()
    Declare Sub Hide ()
END TYPE

Constructor Form ()
End Constructor

Constructor Form (x As Integer, y As Integer, w As Integer, h As Integer, title As String, isShown As Byte)
    this.x = x
    this.y = y
    this.w = w
    this.h = h
    this.title = title
    this.isShown = isShown
    If isShown = 1 Then Show()
End Constructor

'Destructor Form ()
'    Hide ()
'End Destructor

Sub Form.Show ()
    ScreenLock()
    forewindow = ImageCreate(x+w,y+h) : Get (x,y)-(x+w,y+h), forewindow
    Line (x, y)-(x + w, y + 19), tbcolor, BF 'titlebar
    Line ((x + w - 17), y + 4)-((x + w - 4), y + 17), &HAAAAAA, BF 'x button
    Line ((x + w - 18), y + 3)-((x + w - 3), y + 18), &H555555, B 'or rather 3.1 kind of thing
    Line ((x + w - 13), y + 11)-((x + w - 6), y + 12), &H555555, B 'some shadow
    Line ((x + w - 14), y + 10)-((x + w - 7), y + 11), &HFFFFFF, BF 'and the - sign
    wrint (title, x + 6, y + 6, &HFFFFFF, "arial", 1) 'title, of course
    Line (x, y + 20)-(x + w, y + h), &HFFFFFF, BF 'main area
    Line (x, y)-(x + w, y + h), &H555555, B 'frame 1
    Line (x + 1, y + 1)-(x + w - 1, y + h - 1), &HAAAAAA, B 'frame 2
    ScreenUnlock()
    isShown = 1
    Exit Sub
End Sub

Sub Form.Hide ()
    View (x,y)-(x+w,y+h)
    ScreenLock(): Put (0, 0), forewindow, pset
    ScreenUnlock()
    View (0,0)-(SCREENX, SCREENY)
    isShown = 0
    Exit Sub
End Sub

TYPE Task
    number AS BYTE
    isRunning AS BYTE
END TYPE

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
    Exit Sub
End Sub

Sub MsgBox (prompt as string, addwidth as integer, buttontext as string, title as string)
    'Okay, but is an absolute mess.
    'All the math is here to center the layout
    Dim As Integer windowlength, buttonlength
    windowlength = (Len(prompt) * 6) + 60 + addwidth '60 is an eyeballed value, 6 is mean character width
    buttonlength = 64 'Len(buttontext) * 6 + 17
    Dim MsgBoxForm As Form = Form (SCREENX / 2 - windowlength / 2, SCREENY / 2 - 40, windowlength, 82, title, 1)
    MsgBoxForm.Show()
    BMPLoad ".\info.bmp", MsgBoxForm.x + 10, MsgBoxForm.y + 23
    wrint prompt, ((MsgBoxForm.x + 50)), MsgBoxForm.y + 34, 0, "arial", 0
    Dim MsgButton As Button = Button (((MsgBoxForm.x + windowlength / 2) - buttonlength / 2), MsgBoxForm.y + 57, buttonlength, 19, buttontext)
    Exit Sub
    'Forgive me, and if you know better - by all means, be my guest!
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
