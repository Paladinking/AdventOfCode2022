(defun is-identifier (str size offset)
	(loop for i from 0 to (- size 1) do 
		(loop for j from (+ i 1) to (- size 1) do
			(when (CHAR= (char str (+ offset i)) (char str (+ offset j)))
				(return-from is-identifier nil)
			)
		)
	)
	t
)

(defun find-identifier (str size)
	(loop for i from 0 to (- (length str) 1) do 
		(when (is-identifier str size i) 
			(return (+ i size))
		)
	)
)

(let ((infile (open "../input/input6.txt" :if-does-not-exist nil)))
   (when infile
	  (let ((line (read-line infile nil)))
		(let ((pos (find-identifier line 4))) 
			(write pos)
			(terpri)
		)
		(let ((pos (find-identifier line 14))) 
			(write pos)
			(terpri)
		)
	  )
	  
      (close infile)
   )
)