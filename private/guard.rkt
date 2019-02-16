#lang rebellion/private/dependencies/layer0

(require (for-syntax rebellion/private/dependencies/layer0
                     racket/syntax)
         rebellion/name
         rebellion/predicate
         syntax/parse/define)

;@------------------------------------------------------------------------------

(struct guard-impl (name procedure)
  #:reflection-name 'guard
  #:constructor-name plain-make-guard
  #:property prop:name (λ (this) (guard-name this))
  #:property prop:type-name 'guard
  #:methods gen:custom-write [(define write-proc write-named-value)]

  #:methods gen:equal+hash
  [(define type-tag (gensym 'guard-type-tag))
   (define type-tag2 (gensym 'guard-type-tag))
   (define (equal-proc this other recur)
     (and (recur (guard-name this) (guard-name other))
          (recur (guard-procedure this) (guard-procedure other))))
   (define (hash-proc this recur)
     (recur (list type-tag (guard-name this) (guard-procedure this))))
   (define (hash2-proc this recur)
     (recur (list type-tag2 (guard-name this) (guard-procedure this))))])

(define guard? (make-predicate guard-impl? #:name (symbolic-name 'guard?)))
(define guard-name guard-impl-name)
(define guard-procedure guard-impl-procedure)

(define (make-guard proc #:name [name unknown-name])
  (plain-make-guard name proc))

;@------------------------------------------------------------------------------

(define-simple-macro (define-domain-contract-type type-name:id)
  #:with struct-type-name
  (format-id #'type-name "~a-chaperone-contract" (syntax-e #'type-name))
  #:with get-domain
  (format-id #'struct-type-name "~a-domain" (syntax-e #'struct-type-name))
  #:with get-name
  (format-id #'struct-type-name "~a-name" (syntax-e #'struct-type-name))
  #:with get-first-order
  (format-id #'struct-type-name "~a-first-order" (syntax-e #'struct-type-name))
  #:with get-late-neg-projection
  (format-id #'struct-type-name
             "~a-late-neg-projection"
             (syntax-e #'struct-type-name))
  #:with get-val-first-projection
  (format-id #'struct-type-name
             "~a-val-first-projection"
             (syntax-e #'struct-type-name))
  #:with get-projection
  (format-id #'struct-type-name "~a-projection" (syntax-e #'struct-type-name))
  
  (struct struct-type-name
    (domain
     name
     first-order
     late-neg-projection
     val-first-projection
     projection)
    
    #:property prop:chaperone-contract
    (build-chaperone-contract-property
     #:name (λ (this) (get-name this))
     #:first-order (λ (this) (get-first-order this))
     #:late-neg-projection (λ (this) (get-late-neg-projection this))
     #:val-first-projection
     (λ (this blm) ((get-val-first-projection this) blm))
     #:projection (λ (this) (get-projection this)))

    #:methods gen:custom-write
    [(define write-proc contract-custom-write-property-proc)]

    #:methods gen:equal+hash
    [(define type-tag (gensym 'struct-type-name))
     (define type-tag2 (gensym 'struct-type-name))
     (define (equal-proc this other recur)
       (recur (get-domain this) (get-domain other)))
     (define (hash-proc this recur)
       (recur (list type-tag (get-domain this))))
     (define (hash2-proc this recur)
       (recur (list type-tag2 (get-domain this))))]))

(define-domain-contract-type guard)

(define (guard/c domain-contract)
  