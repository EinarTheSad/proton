'--- DECLARE ---
DECLARE SUB Refresh (x, y, z, w, col)
DECLARE SUB Desktop ()
'$INCLUDE: 'vars.bas'

Screen 9, , 1, 0
Refresh 0, 0, 639, 349, 3
mouse 1 'Show the cursor
PCopy 1, 0 'Initial empty screen, so we know it's loading

'--- MAIN LOOP ---
Do
    mouse 3 'Track mouse
    MsgBox "$bProton 0.23$b reporting on duty.", 120, 100, "Acknowledged", 1
    Taskmgr 'Run the task manager
Loop Until InKey$ = "q" ' Temporary escape

'--- MAIN CODE ENDS HERE ---

'--- SUB INCLUDES (for QB64 debug purposes) ---
' Remember to load all the files in QB.EXE when
' compiling for MS-DOS.

'$INCLUDE: 'gui.bas'

'--- SUBS ---
'#####################################
'# Warning! Vital subs here ONLY!    #
'# All other subs should be put into #
'# separate files in a humane way!   #
'#####################################

Sub Taskmgr
    If ProcNum < 10 Then
        GiveControl = ProcNum
        ProcNum = ProcNum + 1
    Else
        ProcNum = 0
    End If
    PCopy 1, 0
End Sub
