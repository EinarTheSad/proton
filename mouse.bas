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