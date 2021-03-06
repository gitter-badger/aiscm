(use-modules (oop goops)
             (srfi srfi-1)
             (srfi srfi-26)
             (ice-9 optargs)
             (ice-9 curried-definitions)
             (aiscm util)
             (aiscm element)
             (aiscm pointer)
             (aiscm mem)
             (aiscm sequence)
             (aiscm jit)
             (aiscm op)
             (aiscm int))


; return value, code, predefined

(define-class <fragment> ()
  (code #:init-keyword #:code #:getter get-code)
)


(define a (make <var> #:type <int> #:symbol 'a))
(define b (make <var> #:type <int> #:symbol 'b))
(define c (make <var> #:type <int> #:symbol 'c))

(define prog (list (MOV a 0) (NOP) (MOV b a) (RET)))
(define l (live-intervals (live-analysis prog) (variables prog)))
(define s (spill-variable a (ptr <int> RSP 8) prog))
(update-intervals l (index-groups s))
(length (flatten-code s))

(use-modules (oop goops))
(define-class <x> ())
(define-method (test (x <x>)) 'test)

(make-array 0 2 3)
(make-typed-array 'u8 0 2 3)
#vu8(1 2 3)
#2((1 2 3) (4 5 6))

#2u32((1 2 3) (4 5 6))
(define m #2s8((1 -2 3) (4 5 6)))
(array-ref m 1 0)
(array-shape m)
(array-dimensions m)
(array-rank m)
(array->list m)

(class-slots <x>)
(define m (car (generic-function-methods test)))
((method-procedure m) x)
(slot-ref test 'methods)
;(sort-applicable-methods test (compute-applicable-methods test (list x)) (list x))
(equal? (map class-of (list x)) (method-specializers m))
(define x (make <x>))
(test x)
(define-method (test (x <x>)) 'test2)
(test x)
