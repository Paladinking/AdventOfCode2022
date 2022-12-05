000100* MAIN.COB GnuCOBOL
000200 IDENTIFICATION DIVISION.
000300 PROGRAM-ID. cobmain.
000400 ENVIRONMENT DIVISION.
000500 INPUT-OUTPUT SECTION.
000600 FILE-CONTROL.
000700     SELECT infile ASSIGN TO
000800          "../input/input5.txt"
000900          ORGANIZATION IS LINE SEQUENTIAL
001000          .
00100 DATA DIVISION.
001200 FILE SECTION.
001300 FD infile
001400      RECORD IS VARYING IN SIZE FROM 0 TO 64 CHARACTERS
001500		DEPENDING ON infile-record-length.
001600 01 infile-record.
001700    05 infile-data PIC X OCCURS 1 TO 64 TIMES 
001800                   DEPENDING ON infile-record-length.
001900 WORKING-STORAGE SECTION.
002000 01  boxes.
002100     05 box-col OCCURS 16 TIMES.
002200        10 box-value PIC X OCCURS 64 TIMES.
002300     05 box-col-length PIC S9(07) COMP-5 OCCURS 16 TIMES.
002400 01  crates.
002500     05 crate-col OCCURS 16 TIMES.
002600        10 crate-value PIC X OCCURS 64 TIMES.
002700     05 crate-col-length PIC S9(07) COMP-5 OCCURS 16 TIMES.
002800 01  boxes-length PIC S9(07) COMP-5.
002900 01  boxes-row PIC S9(07) COMP-5.
003000 01  boxes-col PIC S9(07) COMP-5.
003100 01  infile-record-length PIC S9(07) COMP-5.
003200 01  line-index PIC S9(07) COMP-5.
003300 01  index-value PIC S9(07) COMP-5.
003400 01  move-amount PIC S9(07) COMP-5.
003500 01  move-source PIC S9(07) COMP-5.
003600 01  move-dest PIC S9(07) COMP-5.
003700 PROCEDURE DIVISION.
003800     OPEN INPUT  INFILE
003900	   MOVE 16 TO boxes-row
004000     PERFORM UNTIL EXIT
004100     READ INFILE AT END 
004200     DISPLAY "END"
004300     END-READ
004400     IF infile-data(2) = '1' THEN
004500     EXIT PERFORM
004600     END-IF
004700     PERFORM PARSE-BOX-ROW
004800     ADD -1 TO boxes-row
004900     END-PERFORM
005000     MOVE infile-data(infile-record-length - 1) TO boxes-length
005100     MOVE 1 TO boxes-col
005200     PERFORM UNTIL boxes-col > boxes-length
005300     PERFORM COMPACT-BOX-COL
005400     ADD 1 TO boxes-col
005500     END-PERFORM
005600     MOVE boxes TO crates
005700     READ INFILE
005800     PERFORM UNTIL EXIT
005900     READ INFILE AT END
006000     EXIT PERFORM
006100     END-READ
006200     SET line-index TO 6
006300     PERFORM NUMBER-GET
006400     MOVE index-value TO move-amount
006500     ADD 6 TO line-index
006600     PERFORM NUMBER-GET
006700     MOVE index-value TO move-source
006800     ADD 4 TO line-index
006900     PERFORM NUMBER-GET
007000     MOVE index-value TO move-dest
007100     MOVE move-amount TO index-value
007200     PERFORM until move-amount = 0
007300     ADD 1 TO box-col-length(move-dest)
007400     ADD 1 TO crate-col-length(move-dest)
007500     MOVE box-value(move-source, box-col-length(move-source))
007600          TO box-value(move-dest, box-col-length(move-dest))
007700     MOVE ' ' TO box-value(move-source, 
007800          box-col-length(move-source))
007900     MOVE crate-value(move-source, 
008000       crate-col-length(move-source) - move-amount + 1)
008100       TO crate-value(move-dest, crate-col-length(move-dest))
008200     MOVE ' ' TO crate-value(move-source, 
008300          crate-col-length(move-source) - move-amount + 1)
008400     SUBTRACT 1 FROM box-col-length(move-source)
008500     SUBTRACT 1 FROM move-amount
008600     END-PERFORM
008700     SUBTRACT index-value FROM crate-col-length(move-source)
008800     END-PERFORM
008900     SET boxes-col TO 1
009000     PERFORM UNTIL boxes-col = boxes-length
009100     DISPLAY box-col(boxes-col)(box-col-length(boxes-col):1) 
009200             WITH NO ADVANCING
009300     ADD 1 TO boxes-col
009400     END-PERFORM
009500     DISPLAY box-col(boxes-col)(box-col-length(boxes-col):1) 
009600     SET boxes-col TO 1
009700     PERFORM UNTIL boxes-col = boxes-length
009800     DISPLAY crate-col(boxes-col)(crate-col-length(boxes-col):1) 
009900             WITH NO ADVANCING
010000     ADD 1 TO boxes-col
010100     END-PERFORM
010200     DISPLAY crate-col(boxes-col)(crate-col-length(boxes-col):1) 
010300     CLOSE INFILE
010400     STOP RUN.
010500     NUMBER-GET.
010600     MOVE line-index TO index-value
010700     PERFORM UNTIL 
010800         infile-data(line-index) = ' ' or
010900         line-index = infile-record-length + 1
011000     ADD 1 TO line-index
011100     END-PERFORM
011200     MOVE infile-record(index-value:line-index - index-value)
011300          TO index-value
011400     EXIT PARAGRAPH.
011500     PARSE-BOX-ROW.
011600     MOVE 1 TO line-index
011700     MOVE 1 TO boxes-col
011800     PERFORM UNTIL line-index > infile-record-length
011900     IF infile-data(line-index) = '[' THEN
012000     MOVE infile-data(line-index + 1) 
012100          TO box-value(boxes-col, boxes-row)
012200     END-IF
012300     ADD 4 TO line-index
012400     ADD 1 TO boxes-col
012500     END-PERFORM
012600     EXIT PARAGRAPH.
012700     COMPACT-BOX-COL.
012800     SET boxes-row TO 1
012900     PERFORM UNTIL not (box-value(boxes-col, boxes-row) = ' ')
013000     ADD 1 to boxes-row
013100     END-PERFORM
013200     SET box-col-length(boxes-col) TO 1
013300     PERFORM UNTIL boxes-row = 17
013400     MOVE box-value(boxes-col, boxes-row) 
013500          TO box-value(boxes-col, box-col-length(boxes-col))
013600     MOVE ' '  TO box-value(boxes-col, boxes-row)
013700     ADD 1 TO boxes-row
013800     ADD 1 TO box-col-length(boxes-col)
013900     END-PERFORM
014000     PERFORM UNTIL not 
014100         box-value(boxes-col, box-col-length(boxes-col)) = ' '
014200     SUBTRACT 1 FROM box-col-length(boxes-col)
014300     END-PERFORM
014400     EXIT PARAGRAPH.
014500  END PROGRAM cobmain.
