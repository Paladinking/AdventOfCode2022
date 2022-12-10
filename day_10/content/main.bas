Open "../input/input10.txt" For Input As #1

Dim input_line As String

Dim cycle As Uinteger = 0
Dim xreg As Integer = 1
Dim signal_sum As Integer = 0
Dim CRT(0 To 5, 0 To 39) As String

Sub DoCycle(Byval delta As Integer, Byref cycle as Uinteger, Byref xreg as Integer, Byref signal_sum as Integer, CRT() As String)
	Dim col  As Integer = cycle Mod 40
	Dim row As Integer = (cycle \ 40) Mod 6
	cycle += 1
	If abs(col - xreg) <= 1 Then
		CRT(row, col) = "#"
	Else
		CRT(row, col) = "."
	End If
	If (cycle + 20) Mod 40 = 0 Then
		signal_sum += cycle * xreg
	End If
	xreg += delta
End Sub

Do
	Line Input #1, input_line
	If Len(input_line) = 0 Then Exit Do
	DoCycle(0, cycle, xreg, signal_sum, CRT())
	If Left(input_line, 4) = "addx" Then
		DoCycle(ValInt(Mid(input_line, 5)), cycle, xreg, signal_sum, CRT())
	End If
Loop
Print Using "&"; signal_sum

For i As Integer = 0 To 5
	For j As Integer = 0 To 39
		Print Using "&"; CRT(i, j);
	Next j
	Print ""
Next i

Close #1