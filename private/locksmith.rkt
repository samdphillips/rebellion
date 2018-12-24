#lang racket

(struct locksmith (sealer unsealer)
  #:constructor-name plain-make-locksmith)

(define (make-locksmith #:seal sealer #:unseal unsealer)
  (plain-make-locksmith sealer unsealer))

(define (locksmith-seal smith v k)
  ((locksmith-sealer smith) v k))

(define (locksmith-unseal smith v k)
  ((locksmith-unsealer smith) v k))

(define (locksmith-chaperone smith
                             #:key-guard key-guard
                             #:domain-guard domain-guard
                             #:range-guard-maker range-guard-maker
                             . props+vs)
  (define sealer (locksmith-sealer smith))
  (define unsealer (locksmith-unsealer smith))
  (define guarded-sealer
    (chaperone-procedure sealer
                         (λ (k v)
                           (values (range-guard-maker k)
                                   (key-guard k)
                                   (domain-guard v))))))
                                   

(define (locksmith/c key-contract domain-contract range-contract-maker)
  (define name #f)
  (define first-order #f)
  (make-contract #:name name
                 #:first-order first-order)
  (void))
  
(struct strongbox (value key)
  #:constructor-name make-strongbox)

(define (strongbox-seal v k)
  (make-strongbox v k))

(define (strongbox-unseal sbox k)
  (unless (equal? (strongbox-key sbox) k)
    (raise-arguments-error 'strongbox-unseal
                           "key does not unlock given strongbox"
                           "key" k
                           "strongbox" sbox))
  (strongbox-value sbox))

(define strongbox-locksmith
  (make-locksmith #:seal strongbox-seal
                  #:unseal strongbox-unseal))
