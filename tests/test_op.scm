(use-modules (oop goops)
             (aiscm element)
             (aiscm int)
             (aiscm op)
             (guile-tap))
(planned-tests 7)
(define s1 (make <sint> #:value (random (ash 1 14))))
(define s2 (make <sint> #:value (random (ash 1 14))))
(define i1 (make <int> #:value (random (ash 1 29))))
(define i2 (make <int> #:value (random (ash 1 29))))
(define i3 (make <int> #:value (random (ash 1 29))))
(define l1 (make <long> #:value (random (ash 1 62))))
(define l2 (make <long> #:value (random (ash 1 62))))
(ok (eqv? (+ (get-value i1) (get-value i2)) (get-value (+ i1 i2)))
    "add two integers")
(ok (eqv? (+ (get-value l1) (get-value l2)) (get-value (+ l1 l2)))
    "add two long integers")
(ok (eqv? (+ (get-value i1) (get-value l2)) (get-value (+ i1 l2)))
    "add integer and long integer")
(ok (eqv? 64 (bits (class-of (+ i1 l1))))
    "check type coercion of addition")
(ok (eqv? (+ (get-value i1) (get-value i2) (get-value i3)) (get-value (+ i1 i2 i3)))
    "add three integers")
(ok (eqv? (- (get-value i1) (get-value i2)) (get-value (- i1 i2)))
    "subtract two integers")
(skip #f '((ok (eqv? (- (get-value i1)) (get-value (- i1)))
    "negate integer")))
(format #t "~&")
