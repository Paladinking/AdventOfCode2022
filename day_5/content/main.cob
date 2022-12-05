000100* MAIN.COB GnuCOBOL
000200 IDENTIFICATION DIVISION.
000300 PROGRAM-ID. cobmain.
000300 ENVIRONMENT DIVISION.
000400 INPUT-OUTPUT SECTION.
000500 FILE-CONTROL.
000600     SELECT infile ASSIGN TO
000700          "../input/input5.txt"
000000          ORGANIZATION IS LINE SEQUENTIAL
000800          .
000800 DATA DIVISION.
000900 FILE SECTION.
001000 FD infile
001100      RECORD IS VARYING IN SIZE FROM 0 TO 64 CHARACTERS
001200		DEPENDING ON infile-record-length.
001300 01 infile-record.
001400    05 infile-data PIC X OCCURS 1 TO 64 TIMES 
001500                   DEPENDING ON infile-record-length.
001600 WORKING-STORAGE SECTION.
000000 01  boxes.
000000     05 box-col OCCURS 16 TIMES.
000000        10 box-value PIC X OCCURS 64 TIMES.
000000     05 box-col-length PIC S9(07) COMP-5 OCCURS 16 TIMES.
000000 01  crates.
000000     05 crate-col OCCURS 16 TIMES.
000000        10 crate-value PIC X OCCURS 64 TIMES.
000000     05 crate-col-length PIC S9(07) COMP-5 OCCURS 16 TIMES.
000000 01  boxes-length PIC S9(07) COMP-5.
000000 01  boxes-row PIC S9(07) COMP-5.
000000 01  boxes-col PIC S9(07) COMP-5.
000000 01  infile-record-length PIC S9(07) COMP-5.
000000 01  line-index PIC S9(07) COMP-5.
000000 01  index-value PIC S9(07) COMP-5.
000000 01  move-amount PIC S9(07) COMP-5.
000000 01  move-source PIC S9(07) COMP-5.
000000 01  move-dest PIC S9(07) COMP-5.
000700 PROCEDURE DIVISION.
000000     OPEN INPUT  INFILE
000000	   MOVE 16 TO boxes-row
000000     PERFORM UNTIL EXIT
000000     READ INFILE AT END 
000000     DISPLAY "END"
000000     END-READ
000000     IF infile-data(2) = '1' THEN
000000     EXIT PERFORM
000000     END-IF
000000     PERFORM PARSE-BOX-ROW
000000     ADD -1 TO boxes-row
000000     END-PERFORM
000000     MOVE infile-data(infile-record-length - 1) TO boxes-length
000000     MOVE 1 TO boxes-col
000000     PERFORM UNTIL boxes-col > boxes-length
000000     PERFORM COMPACT-BOX-COL
000000     ADD 1 TO boxes-col
000000     END-PERFORM
000000     MOVE boxes TO crates
000000     READ INFILE
000000     PERFORM UNTIL EXIT
000000     READ INFILE AT END
000000     EXIT PERFORM
000000     END-READ
000000     SET line-index TO 6
000000     PERFORM NUMBER-GET
000000     MOVE index-value TO move-amount
000000     ADD 6 TO line-index
000000     PERFORM NUMBER-GET
000000     MOVE index-value TO move-source
000000     ADD 4 TO line-index
000000     PERFORM NUMBER-GET
000000     MOVE index-value TO move-dest
000000     MOVE move-amount TO index-value
000000     PERFORM until move-amount = 0
000000     ADD 1 TO box-col-length(move-dest)
000000     ADD 1 TO crate-col-length(move-dest)
000000     MOVE box-value(move-source, box-col-length(move-source))
000000          TO box-value(move-dest, box-col-length(move-dest))
000000     MOVE ' ' TO box-value(move-source, 
000000          box-col-length(move-source))
000000     MOVE crate-value(move-source, 
000000       crate-col-length(move-source) - move-amount + 1)
000000       TO crate-value(move-dest, crate-col-length(move-dest))
000000     MOVE ' ' TO crate-value(move-source, 
000000          crate-col-length(move-source) - move-amount + 1)
000000     SUBTRACT 1 FROM box-col-length(move-source)
000000     SUBTRACT 1 FROM move-amount
000000     END-PERFORM
000000     SUBTRACT index-value FROM crate-col-length(move-source)
000000     END-PERFORM
000000     SET boxes-col TO 1
000000     PERFORM UNTIL boxes-col = boxes-length
000000     DISPLAY box-col(boxes-col)(box-col-length(boxes-col):1) 
000000             WITH NO ADVANCING
000000     ADD 1 TO boxes-col
000000     END-PERFORM
00000      DISPLAY box-col(boxes-col)(box-col-length(boxes-col):1) 
000000     SET boxes-col TO 1
000000     PERFORM UNTIL boxes-col = boxes-length
000000     DISPLAY crate-col(boxes-col)(crate-col-length(boxes-col):1) 
000000             WITH NO ADVANCING
000000     ADD 1 TO boxes-col
000000     END-PERFORM
00000      DISPLAY crate-col(boxes-col)(crate-col-length(boxes-col):1) 
000000     CLOSE INFILE
000900     STOP RUN.
000000     NUMBER-GET.
000000     MOVE line-index TO index-value
000000     PERFORM UNTIL 
000000         infile-data(line-index) = ' ' or
000000         line-index = infile-record-length + 1
000000     ADD 1 TO line-index
000000     END-PERFORM
000000     MOVE infile-record(index-value:line-index - index-value)
000000          TO index-value
000000     EXIT PARAGRAPH.
000000     PARSE-BOX-ROW.
000000     MOVE 1 TO line-index
000000     MOVE 1 TO boxes-col
000000     PERFORM UNTIL line-index > infile-record-length
000000     IF infile-data(line-index) = '[' THEN
000000     MOVE infile-data(line-index + 1) 
000000          TO box-value(boxes-col, boxes-row)
000000     END-IF
000000     ADD 4 TO line-index
000000     ADD 1 TO boxes-col
000000     END-PERFORM
000000     EXIT PARAGRAPH.
000000     COMPACT-BOX-COL.
000000     SET boxes-row TO 1
000000     PERFORM UNTIL not (box-value(boxes-col, boxes-row) = ' ')
000000     ADD 1 to boxes-row
000000     END-PERFORM
000000     SET box-col-length(boxes-col) TO 1
000000     PERFORM UNTIL boxes-row = 17
000000     MOVE box-value(boxes-col, boxes-row) 
000000          TO box-value(boxes-col, box-col-length(boxes-col))
000000     MOVE ' '  TO box-value(boxes-col, boxes-row)
000000     ADD 1 TO boxes-row
000000     ADD 1 TO box-col-length(boxes-col)
000000     END-PERFORM
000000     PERFORM UNTIL not 
000000         box-value(boxes-col, box-col-length(boxes-col)) = ' '
000000     SUBTRACT 1 FROM box-col-length(boxes-col)
000000     END-PERFORM
000000     EXIT PARAGRAPH.
000000  END PROGRAM cobmain.
