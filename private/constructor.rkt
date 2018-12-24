#lang rebellion/private/dependencies/layer1

(provide
 (contract-out
  [constructor? predicate?]
  [make-constructor
   (->* (#:make procedure?
         #:accessors (listof procedure?)
         #:fields keyset?)
        (#:name name?)
        constructor?)]
  [constructor-name (-> constructor? name?)]
  [constructor-maker-procedure (-> constructor? procedure?)]
  [constructor-field-accessor-procedure
   (->i ([ctor constructor?]
         [field (ctor) (constructor-field-predicate ctor)])
        [_ (-> any/c any/c)])]
  [constructor-fields (-> constructor? keyset?)]))

(require rebellion/private/boolean
         rebellion/private/function
         rebellion/private/keyset
         rebellion/private/keyword
         rebellion/private/list
         rebellion/private/name-lite
         rebellion/private/predicate-lite)

(module+ test
  (require (submod "..")
           rackunit))

;@------------------------------------------------------------------------------
;; core API

(struct constructor-impl (name fields make-proc accessor-procs)
  #:reflection-name 'constructor
  #:constructor-name plain-make-constructor
  #:property prop:type-name 'constructor
  #:property prop:name (λ (this) (constructor-name this))
  #:methods gen:custom-write [(define write-proc write-named-value)])

(define constructor?
  (make-predicate constructor-impl? #:name (symbolic-name 'constructor?)))

(define constructor-name constructor-impl-name)
(define constructor-fields constructor-impl-fields)
(define constructor-make-proc constructor-impl-make-proc)
(define constructor-accessor-procs constructor-impl-accessor-procs)

(define (make-constructor #:make make-proc
                          #:accessors accessor-procs
                          #:fields fields
                          #:name [name unknown-name])
  (plain-make-constructor name fields make-proc accessor-procs))

(define (constructor-maker-procedure ctor)
  (define field-list (keyset->sorted-keyword-list (constructor-fields ctor)))
  (define maker (constructor-make-proc ctor))
  (define maker/field-keywords
    (make-keyword-procedure (λ (_ keyword-vs) (apply maker keyword-vs))))
  (procedure-reduce-keyword-arity maker/field-keywords 0 field-list field-list))

(define (constructor-field-accessor-procedure ctor field)
  (define field-pos (keyset-index-of (constructor-fields ctor) field))
  (list-ref (constructor-accessor-procs ctor) field-pos))

(define (constructor-field-predicate ctor)
  (define name (compound-name (symbolic-name 'constructor-field-predicate)
                              (name-literal ctor)))
  (define (predicate-proc v)
    (and (keyword? v) (keyset-contains? (constructor-fields ctor) v)))
  (make-predicate predicate-proc #:name name))

;@------------------------------------------------------------------------------
;; constructor creators

(define (make-list-constructor name fields)
  (define accessors
    (build-list (keyset-size fields)
                (λ (n) (λ (lst) (list-ref lst n)))))
  (make-constructor #:make list
                    #:accessors accessors
                    #:fields fields
                    #:name name))

(define (make-struct-constructor name fields)
  (define num-fields (keyset-size fields))
  (define-values (type
                  constructor-procedure
                  predicate-procedure
                  accessor-procedure
                  mutator-procedure)
    (make-struct-type (symbolic-name->symbol name)
                      #f
                      num-fields
                      0
                      #f
                      '()
                      (current-inspector)
                      #f
                      (build-list num-fields values)))
  (define (make-accessor n)
    (define field-symbol (keyword->symbol (keyset-ref fields n)))
    (make-struct-field-accessor accessor-procedure n field-symbol))
  (define accessors (build-list num-fields make-accessor))
  (make-constructor #:make constructor-procedure
                    #:accessors accessors
                    #:fields fields
                    #:name name))

(module+ test
  (define name (symbolic-name 'player))
  (define fields (keyset #:health #:armor #:strength))
  (test-case "make-list-constructor"
    (define player-constructor (make-list-constructor name fields))
    (define make-player (constructor-maker-procedure player-constructor))
    (make-player #:health 100 #:armor 5 #:strength 8))
  (test-case "make-struct-constructor"
    (define player-constructor (make-struct-constructor name fields))
    (define make-player (constructor-maker-procedure player-constructor))
    (make-player #:health 100 #:armor 5 #:strength 8)))
