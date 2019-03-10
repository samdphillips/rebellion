#lang racket/base

(require racket/contract/base)

(provide
 (contract-out
  [consistent-order? (-> any/c boolean?)]
  [inconsistent-order? (-> any/c boolean?)]
  [total-order? (-> any/c boolean?)]
  [partial-order? (-> any/c boolean?)]
  [make-partial-order
   (->* ((-> any/c any/c (or/c '< '> '= '≠)))
        (#:name symbol?
         #:inconsistent? boolean?)
        partial-order?)]
  [make-total-order
   (->* ((-> any/c any/c (or/c '< '> '=)))
        (#:name symbol?
         #:inconsistent? boolean?)
        total-order?)]
  [order? (-> any/c boolean?)]
  [natural<=> consistent-total-order?]))

(require rebellion/equal+hash/tuple
         rebellion/named-custom-write
         rebellion/tuple-type-definition)

;@------------------------------------------------------------------------------

(define (make-order-properties descriptor)
  (define custom-write (make-named-tuple-custom-write descriptor))
  (define equal+hash (make-tuple-equal+hash descriptor))
  (list (cons prop:custom-write custom-write)
        (cons prop:equal+hash equal+hash)))

(define-tuple-type inconsistent-partial-order (name function)
  #:property-maker make-order-properties)

(define-tuple-type inconsistent-total-order (name function)
  #:property-maker make-order-properties)

(define-tuple-type consistent-partial-order (name function)
  #:property-maker make-order-properties)

(define-tuple-type consistent-total-order (name function)
  #:property-maker make-order-properties)

(define (partial-order? v)
  (or (inconsistent-partial-order? v)
      (consistent-partial-order? v)))

(define (total-order? v)
  (or (inconsistent-total-order? v)
      (consistent-total-order? v)))

(define (consistent-order? v)
  (or (consistent-partial-order? v)
      (consistent-total-order? v)))

(define (inconsistent-order? v)
  (or (inconsistent-partial-order? v)
      (inconsistent-total-order? v)))

(define (order? v)
  (or (inconsistent-partial-order? v)
      (inconsistent-total-order? v)
      (consistent-partial-order? v)
      (consistent-total-order? v)))

(define (make-partial-order function
                            #:name [name #f]
                            #:inconsistent? [inconsistent? #f])
  (if inconsistent?
      (inconsistent-partial-order name function)
      (consistent-partial-order name function)))

(define (make-total-order function
                          #:name [name #f]
                          #:inconsistent? [inconsistent? #f])
  (if inconsistent?
      (inconsistent-total-order name function)
      (consistent-total-order name function)))

(define (natural-order-function x y)
  (cond [(< x y) '<]
        [(= x y) '=]
        [else '>]))

(define natural<=> (make-total-order natural-order-function #:name 'natural<=>))
