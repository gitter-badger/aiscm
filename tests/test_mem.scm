(use-modules (oop goops)
             (aiscm element)
             (aiscm mem)
             (ice-9 regex)
             (guile-tap))
(define m (make <mem> #:size 10))
(planned-tests 15)
(ok (equal? (get-memory m) (slot-ref m 'base))
  "base pointer protects allocated memory from garbage collector")
(ok (eqv? 10 (get-size m))
  "'get-size' returns size of allocated memory")
(ok (equal? (get-memory m) (slot-ref (+ m 6) 'base))
  "base pointer is copied when creating pointer with offset")
(ok (equal? (+ m 1) (+ m 1))
  "equal mem objects")
(ok (not (equal? (+ m 1) (+ m 2)))
  "unequal mem objects")
(ok (eqv? 4 (get-size (+ m 6)))
  "pointer operations keep track of memory size")
(ok (throws? (+m -1))
  "throw exception when pointer offset is negative")
(ok (throws? (+m 11))
  "throw exception when pointer offset exceeds memory boundary")
(ok (equal? #vu8(2 3 5)
  (begin (write-bytes m #vu8(2 3 5 7)) (read-bytes m 3)))
  "writing and reading to/from memory")
(ok (equal? #vu8(3 5 7)
  (begin (write-bytes m #vu8(2 3 5 7)) (read-bytes (+ m 1) 3)))
  "writing and reading with offset to/from memory")
(ok (equal? #vu8(2 2 1 1)
  (begin (write-bytes m #vu8(1 1 1 1)) (write-bytes m #vu8(2 2))
    (read-bytes m 4)))
  "writing with overlap and reading back")
(ok (throws? (read-bytes m 11))
  "throw exception when reading past memory boundary")
(ok (throws? (write-bytes m #vu8(1 2 3 4 5 6 7 8 9 10 11)))
  "throw exception when attempting to write past memory boundary")
(ok (string-match "^#<<mem> #x[0-9a-f]* 10>$"
  (call-with-output-string (lambda (port) (display m port))))
  "display mem object")
(ok (string-match "^#<<mem> #x[0-9a-f]* 10>$"
  (call-with-output-string (lambda (port) (write m port))))
  "write mem object")
