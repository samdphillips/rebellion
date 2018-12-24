#lang rebellion/private/dependencies/layer1

(provide
 (contract-out
  [datatype-factory? predicate?]
  [datatype? predicate?]
  [datatype-predicate (-> datatype? predicate?)]
  [datatype-size (-> datatype? natural?)]
  [datatype-name (-> datatype? symbolic-name?)]
  [datatype-constructor-procedure
   (->i ([type datatype?])
        [_ (type)
           (and/c (procedure-arity-includes/c (datatype-size type))
                  (unconstrained-domain-> (datatype-predicate type)))])]
  [datatype-accessor-procedure
   (->i ([type datatype?])
        [_ (type) (-> (datatype-predicate type)
                      (integer-in 0 (sub1 (datatype-size type)))
                      any/c)])]
  [datatype-factory-name (-> datatype-factory? name?)]
  [datatype-factory-make-datatype
   (-> datatype-factory? #:name symbolic-name? #:size natural? datatype?)]
  [make-datatype-factory
   (->* ((-> symbolic-name? natural? datatype?))
        (#:name name?)
        datatype-factory?)]))

(require rebellion/private/boolean
         rebellion/private/name-lite
         rebellion/private/natural
         rebellion/private/predicate-lite)

;@------------------------------------------------------------------------------

(struct datatype-impl
  (name size predicate constructor-procedure accessor-procedure)
  #:reflection-name 'datatype
  #:constructor-name plain-make-datatype
  #:property prop:type-name 'datatype
  #:property prop:name (λ (this) (datatype-name this))
  #:methods gen:custom-write [(define write-proc write-named-value)])

(define datatype?
  (make-predicate datatype-impl? #:name (symbolic-name 'datatype?)))

(define datatype-name datatype-impl-name)
(define datatype-size datatype-impl-size)
(define datatype-predicate datatype-impl-predicate)
(define datatype-constructor-procedure datatype-impl-constructor-procedure)
(define datatype-accessor-procedure datatype-impl-accessor-procedure)

(define (make-datatype #:name name
                       #:size size
                       #:predicate pred
                       #:constructor-procedure ctor-proc
                       #:accessor-procedure accessor-proc)
  (plain-make-datatype name size pred ctor-proc accessor-proc))

(struct datatype-factory-impl (name make-datatype-proc)
  #:reflection-name 'datatype-factory
  #:constructor-name plain-make-datatype-factory
  #:property prop:type-name 'datatype-factory
  #:property prop:name (λ (this) (datatype-name this))
  #:methods gen:custom-write [(define write-proc write-named-value)])

(define datatype-factory?
  (make-predicate datatype-factory-impl?
                  #:name (symbolic-name 'datatype-factory?)))

(define datatype-factory-name datatype-factory-impl-name)
(define datatype-factory-make-datatype-proc
  datatype-factory-impl-make-datatype-proc)

(define (make-datatype-factory make-datatype-proc #:name [name unknown-name])
  (plain-make-datatype-factory name make-datatype-proc))

(define (datatype-factory-make-datatype type-factory #:name name #:size size)
  ((datatype-factory-make-datatype-proc type-factory) name size))

(define (make-struct-datatype
         #:name name
         #:size size
         #:properties [props '()]
         #:inspector [inspector (current-inspector)]
         #:predicate-name [pred-name unknown-name]
         #:constructor-name [ctor-name unknown-name])
  (define-values (ignored-type
                  constructor-procedure
                  predicate-procedure
                  accessor-procedure
                  ignored-mutator-procedure)
    (make-struct-type (symbolic-name->symbol name)
                      #f
                      size
                      0
                      #f
                      props
                      inspector
                      #f
                      (build-list size values)
                      #f
                      (and (symbolic-name? ctor-name)
                           (symbolic-name->symbol ctor-name))))
  (define predicate (make-predicate predicate-procedure #:name predicate-name))
  (make-datatype #:name name
                 #:size size
                 #:predicate predicate
                 #:constructor-procedure constructor-procedure
                 #:accessor-procedure accessor-procedure))
