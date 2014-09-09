(use-modules (oop goops)
             (system foreign)
             (ice-9 regex)
             (aiscm element)
             (aiscm pointer)
             (aiscm mem)
             (aiscm bool)
             (aiscm int)
             (guile-tap))
(planned-tests 15)
(define m1 (make <mem> #:size 10))
(define m2 (make <mem> #:size 4))
(define p1-bool (make (pointer <bool>) #:value m1))
(define p2-bool (make (pointer <bool>) #:value m2))
(define p1-byte (make (pointer <byte>) #:value m1))
(define p2-byte (make (pointer <byte>) #:value m2))
(define p1-sint (make (pointer <sint>) #:value m1))
(define p2-sint (make (pointer <sint>) #:value m2))
(write-bytes m1 #vu8(1 2 3 4 5 6 7 8 9 10))
(write-bytes m2 #vu8(0 0 0 0))
(ok (equal? (pointer <bool>) (pointer <bool>))
    "equal pointer types")
(ok (equal? (pointer <byte>) (pointer (integer 8 signed)))
    "equal pointer types")
(ok (equal? p1-bool (make (pointer <bool>) #:value m1))
    "equal pointers")
(ok (not (equal? p1-bool p2-bool))
    "unequal pointers")
(ok (not (equal? p1-bool p1-byte))
    "unequal pointers (different type)")
(ok (equal? (make <bool> #:value #t) (fetch p1-bool))
    "fetch boolean from memory")
(ok (equal? (make <byte> #:value 1) (fetch p1-byte))
    "fetch byte from memory")
(ok (equal? (make <sint> #:value #x0201) (fetch p1-sint))
    "fetch short integer from memory")
(ok (equal? 123 (store p2-byte 123))
    "store function returns value")
(ok (equal? (make <sint> #:value #x0201)
            (begin (store p2-sint #x0201) (fetch p2-sint)))
    "storing and fetching back short int")
(ok (equal? (+ m2 2) (get-value (+ p2-sint 1)))
    "pointer operations are aware of size of element")
(ok (eqv? (pointer-address (get-memory m1))
          (get-value (unpack <native-int> (pack p1-byte))))
    "convert pointer to bytevector containing raw data")
(ok (string-match "^#<<pointer<int<16,signed>>> .*>$"
                  (call-with-output-string (lambda (port) (write p1-sint port))))
    "write pointer object")
(ok (string-match "^#<<pointer<int<16,signed>>> .*>$"
                  (call-with-output-string (lambda (port) (display p1-sint port))))
    "display pointer object")
(ok (eqv? 4 (get-size (get-value (make (pointer <int>)))))
    "Memory is allocated if no value is specified")
