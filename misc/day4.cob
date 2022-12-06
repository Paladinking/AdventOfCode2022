000100* MAIN.COB GnuCOBOL
000200 IDENTIFICATION DIVISION.
000300 PROGRAM-ID. cobmain.
000300 ENVIRONMENT DIVISION.
000400 INPUT-OUTPUT SECTION.
000500 FILE-CONTROL.
000600     SELECT infile ASSIGN TO
000700          "../input/input4.txt"
000000          ORGANIZATION IS LINE SEQUENTIAL
000800          .
000800 DATA DIVISION.
000900 FILE SECTION.
001000 FD infile
001100      RECORD IS VARYING IN SIZE FROM 0 TO 20 CHARACTERS
001200		DEPENDING ON infile-record-length.
001300 01 infile-record.
001400    05 infile-data PIC X OCCURS 1 TO 20 TIMES 
001500                   DEPENDING ON infile-record-length.
001600 WORKING-STORAGE SECTION.
000000 01  infile-record-length PIC S9(07) COMP-5.
000000 01  line-index PIC S9(07) COMP-5.
000000 01  index-value PIC S9(07) COMP-5.
000000 01  low-one PIC S9(07) COMP-5.
000000 01  high-one PIC S9(07) COMP-5.
000000 01  low-two PIC S9(07) COMP-5.
000000 01  high-two PIC S9(07) COMP-5.
000000 01  sum-one PIC S9(07) COMP-5.
000000 01  sum-two PIC S9(07) COMP-5.
000000 01  out-val.
000000     05 out-data PIC X OCCURS 10 TIMES.
000700 PROCEDURE DIVISION.
000000     OPEN INPUT  INFILE
000000	   PERFORM UNTIL EXIT
000000     READ INFILE AT END 
000000          EXIT PERFORM
000000     END-READ
000000
000000     MOVE 0 TO line-index
000000     PERFORM NUMBER-GET
000000     MOVE index-value TO low-one
000000     PERFORM NUMBER-GET
000000     MOVE index-value TO high-one
000000     PERFORM NUMBER-GET
000000     MOVE index-value TO low-two
000000     PERFORM NUMBER-GET
000000     MOVE index-value TO high-two
000000     IF (low-one >=  low-two) AND (high-one <= high-two) OR
000000        (low-two >= low-one) AND (high-two <= high-one) THEN
000000     ADD 1 TO sum-one
000000     END-IF 
000000     IF NOT (high-one < low-two OR low-one > high-two) THEN
000000     ADD 1 TO sum-two
000000     END-IF
000000     END-PERFORM
000000     MOVE sum-one TO index-value
000000     PERFORM PRINT-NUMBER.
000000     MOVE sum-two TO index-value
000000     PERFORM PRINT-NUMBER
000000     CLOSE INFILE
000900     STOP RUN.
000000     NUMBER-GET.
000000     ADD 1 TO line-index
000000     MOVE line-index TO index-value
000000     PERFORM UNTIL 
000000         infile-data(line-index) = '-' or
000000         infile-data(line-index) = ',' or
000000         line-index = infile-record-length + 1
000000     ADD 1 TO line-index
000000     END-PERFORM
000000     MOVE infile-record(index-value:line-index - index-value)
000000          TO index-value
000000     EXIT PARAGRAPH.
000000     PRINT-NUMBER.
000000     IF index-value = 0 then
000000     DISPLAY '0'
000000     ELSE
000000     MOVE index-value TO out-val(1:7)
000000     MOVE 1 to line-index
000000     PERFORM UNTIL (not out-data(line-index) = '0')
000000     ADD 1 to line-index
000000     END-PERFORM
000000     DISPLAY out-val(line-index:8 - line-index)
000000     END-IF
000000     EXIT PARAGRAPH.
000000  END PROGRAM cobmain.
