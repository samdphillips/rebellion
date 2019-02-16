#lang racket/base

(require racket/contract/base
         racket/list
         racket/struct
         syntax/parse/define)

(struct property-key (symbol domain)
  #:omit-define-syntaxes
  #:constructor-name plain-make-property-key)

(define (make-property-key)
  (plain-make-property-key (gensym) any/c))

(struct property (value key)
  #:transparent)

(struct property-bag (opaque-set))

(struct record (keywords values)
  #:constructor-name plain-record
  #:omit-define-syntaxes
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (λ (this) 'record)
      (λ (this)
        (apply append
               (for/list ([kw (in-list (record-keywords this))]
                          [v (in-list (record-values this))])
                 (list (unquoted-printing-string (format "~s" kw)) v))))))])

(define record (make-keyword-procedure plain-record))

(define-simple-macro (define-property-key id:id)
  (define id (make-property-key)))

(struct deriver (function-expression input-keys output-keys generative-output?)
  #:omit-define-syntaxes
  #:constructor-name plain-make-deriver)

(struct derivation-graph (derivers))

(define (make-deriver function-expression input-keys output-keys
                      #:generative-output? [generative? #f])
  (plain-make-deriver function-expression input-keys output-keys generative?))

(define-property-key constant-key)
(define-property-key constant-name-key)
(define-property-key constant-predicate-key)
(define-property-key constant-predicate-name-key)
(define-property-key constant-struct-type-expression-key)
(define-property-key constant-struct-type-properties-key)

(define (derive-constant-struct-type-expression
         #:constant-name constant-name
         #:constant-struct-type-properties props)
  (define-values (type constructor predicate unused-accessor unused-mutator)
    (make-struct-type constant-name #f 0 0 #f props #f #f empty #f #f))
  (record #:constant-struct-type type
          #:constant-struct-type-constructor constructor
          #:constant-struct-type-predicate predicate))


(define (derive-constant-predicate #:constant constant
                                   #:constant-name constant-name)
  (define name (string->symbol (format "~a?" constant-name)))
  (define pred (procedure-rename (λ (v) (eq? v constant)) #:name name))
  (record #:constant-predicate pred
          #:constant-predicate-name name))

(define constant-predicate-deriver
  (make-deriver derive-constant-predicate
                (record #:constant constant-key
                        #:constant-name constant-name-key)
                (record #:constant-predicate constant-predicate-key
                        #:constant-predicate-name constant-predicate-name-key)))


#|
struct person
  #:context (constant-deriver struct-definition-context)
  #:fields 
  #:equality equality-deriver



  field name
  field age
  field favorite-color

enum color
  value red
  value orange
  value yellow
  value green
  value blue
  value indigo
  value violet
|#
