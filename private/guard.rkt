#lang racket

(struct guard (proc)
  #:constructor-name plain-make-guard)

(define (make-guard proc) (plain-make-guard proc))

(define identity-guard (make-guard values))

(define (make-raising-guard raised-value-maker)
  (make-guard (λ (v) (raise (raised-value-maker v)))))

(define (guard-apply grd v)
  ((guard-proc grd) v))

(define (make-procedure-guard #:wrapper [wrapper #f]
                              #:kind [kind 'chaperone]
                              . props+vs)
  (define interposer
    (case kind
      [(chaperone) chaperone-procedure]
      [(chaperone*) chaperone-procedure*]
      [(impersonate) impersonate-procedure]
      [(impersonate*) impersonate-procedure*]))
  (make-guard (λ (proc) (apply interposer proc wrapper props+vs))))

(define (procedure-properties-guard . props+vs)
  (apply make-procedure-guard props+vs))

(define (procedure-marks-guard . marks+vs)
  #f)

(define (procedure-wrapper-marks-guard . marks+vs)
  #f)

(define (procedure-arity-guard arity-guard)
  #f)

(define (procedure-results-guard results-guard)
  #f)

(define (procedure-arguments-guard arguments-guard)
  #f)

;@------------------------------------------------------------------------------

(struct multiguard (proc arity)
  #:constructor-name plain-make-multiguard)

(define (make-multiguard proc #:arity [arity (procedure-arity proc)])
  (plain-make-multiguard proc arity))

(define identity-multiguard (make-multiguard values))

(define (make-raising-multiguard raised-value-maker)
  (make-multiguard (λ xs (raise (apply raised-value-maker xs)))
                   #:arity (procedure-arity raised-value-maker)))

(define (multiguard-apply mgrd . vs)
  (apply (multiguard-proc mgrd) vs))
  