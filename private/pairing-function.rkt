#lang racket

(module+ test
  (require rackunit))


;; A pairing function is a bijection between natural numbers and pairs of
;; natural numbers. The existence of pairing functions proves that the set of
;; rational numbers and the set of natural numbers are in one-to-one
;; correspondence. The first pairing function discovered is Cantor's pairing
;; function, and is intimately related with George Cantor's diagonalization
;; argument.
(struct pairing-function (forwards backwards)
  #:constructor-name plain-make-pairing-function)

(define (make-pairing-function #:forwards forwards #:backwards backwards)
  (plain-make-pairing-function forwards backwards))

(define (pairing-function-pair pairfunc x y)
  ((pairing-function-forwards pairfunc) x y))

(define (pairing-function-unpair pairfunc z)
  ((pairing-function-backwards pairfunc) z))

(define (cantor-pair x y)
  (+ (* 1/2 (+ x y) (+ x y 1)) y))

(define (cantor-unpair z)
  (define w
    (exact-floor
     (/ (sub1 (sqrt (add1 (* 8 z))))
        2)))
  (define t
    (/ (+ (sqr w) w)
       2))
  (define y (- z t))
  (define x (- w y))
  (values x y))

(define cantor-pairing
  (make-pairing-function #:forwards cantor-pair #:backwards cantor-unpair))

(module+ test
  (test-case "cantor-pairing"
    (for ([x (in-range 100)] [y (in-range 100)])
      (define z (pairing-function-pair cantor-pairing x y))
      (define-values (x* y*) (pairing-function-unpair cantor-pairing z))
      (check-equal? x* x)
      (check-equal? y* y))))
