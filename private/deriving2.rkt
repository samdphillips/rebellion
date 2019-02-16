#lang racket

(struct generative-token () #:constructor-name make-generative-token)

(struct derivation (symbol expr) #:transparent)

(struct eager-dependency (key) #:transparent)
(struct lazy-dependency (key) #:transparent)
(struct static-dependency (key) #:transparent)

;; type is one of 'static or 'dynamic
(struct derivation-key (token type)
  #:transparent
  #:constructor-name plain-make-derivation-key)

(define (make-derivation-key type)
  (plain-make-derivation-key (make-generative-token) type))

(struct derivation-rule (function key dependencies)
  #:constructor-name plain-make-derivation-rule)

(define (make-derivation-rule func #:key key #:dependencies deps)
  (plain-make-derivation-rule func key deps))

;@------------------------------------------------------------------------------

(struct singleton-datatype (name) #:transparent)

(define singleton-datatype-key (make-derivation-key 'static))

;@------------------------------------------------------------------------------

(define singleton-datatype-tag-key (make-derivation-key 'dynamic))

(define (derive-singleton-datatype-tag datatype)
  (define type-name (singleton-datatype-name datatype))
  (define name
    (string->symbol (string-append (symbol->string type-name) "-type-tag")))
  (define expr #`(gensym (quote #,name)))
  (derivation name expr))

;@------------------------------------------------------------------------------

(define singleton-properties-key (make-derivation-key 'dynamic))

(define (derive-singleton-properties datatype datatype-tag-id)
  (define datatype-name-string
    (symbol->string (singleton-datatype-name datatype)))
  (define output-string (string-append "#<" datatype-name-string ">"))
  (define expr
    #`(list (cons prop:custom-write
                  (λ (ignored-this out ignored-mode)
                    (write-string #,output-string out)
                    (void)))
            (cons prop:equal+hash
                  (list (λ (ignored-this ignored-other ignored-recur) #t)
                        (λ (ignored-this ignored-recur)
                          (equal-hash-code #,datatype-tag-id))
                        (λ (ignored-this ignored-recur)
                          (equal-secondary-hash-code #,datatype-tag-id))))))
  (define name
    (string->symbol
     (string-append datatype-name-string "-struct-type-properties")))
  (derivation name expr))

(define singleton-properties-rule
  (make-derivation-rule derive-singleton-properties
                        #:key singleton-properties-key
                        #:dependencies
                        (list (static-dependency singleton-datatype-key)
                              (lazy-dependency singleton-datatype-tag-key))))

;@------------------------------------------------------------------------------

(define singleton-struct-type-key (make-derivation-key 'dynamic))

(define (derive-singleton-struct-type datatype props-id)
  (define name
    (string->symbol
     (string-append "struct:"
                    (symbol->string (singleton-datatype-name datatype)))))
  (define expr
    #`(let-values ([(type
                     unused-constructor
                     unused-predicate
                     unused-accessor
                     unused-mutator)
                    (make-struct-type (quote #,name) #f 0 0 #f #,props-id)])
        type))
  (derivation name expr))

(define singleton-struct-type-rule
  (make-derivation-rule derive-singleton-struct-type
                        #:key singleton-struct-type-key
                        #:dependencies
                        (list (static-dependency singleton-datatype-key)
                              (eager-dependency singleton-properties-key))))

;@------------------------------------------------------------------------------

(define singleton-constructor-key (make-derivation-key 'dynamic))

(define (derive-singleton-constructor struct-type-id datatype)
  (define constructor-name
    (string->symbol
     (string-append "make-"
                    (symbol->string (singleton-datatype-name datatype)))))
  (derivation constructor-name
                            #`(struct-type-make-constructor
                               #,struct-type-id
                               (quote #,constructor-name))))

(define singleton-constructor-rule
  (make-derivation-rule derive-singleton-constructor
                        #:key singleton-constructor-key
                        #:dependencies
                        (list (eager-dependency singleton-struct-type-key)
                              (static-dependency singleton-datatype-key))))

;@------------------------------------------------------------------------------

(define singleton-value-key (make-derivation-key 'dynamic))

(define (derive-singleton-value constructor-id datatype)
  (derivation (singleton-datatype-name datatype)
                            #`(#,constructor-id)))

(define singleton-value-rule
  (make-derivation-rule derive-singleton-value
                        #:key singleton-value-key
                        #:dependencies
                        (list (eager-dependency singleton-constructor-key)
                              (static-dependency singleton-datatype-key))))

;@------------------------------------------------------------------------------

(define singleton-predicate-key (make-derivation-key 'dynamic))

(define (derive-singleton-predicate struct-type-id datatype)
  (define name
    (string->symbol
     (string-append (symbol->string (singleton-datatype-name datatype))
                    "?")))
  (derivation name
                            #`(struct-type-make-predicate #,struct-type-id)))

(define singleton-predicate-rule
  (make-derivation-rule derive-singleton-predicate
                        #:key singleton-predicate-key
                        #:dependencies
                        (list (eager-dependency singleton-struct-type-key)
                              (static-dependency singleton-datatype-key))))

#|
(with-derivation-rules
  #:rule singleton-rule
  (define-syntax unit-datatype (singleton-datatype 'unit))
  (derive-from [singleton-datatype-key unit-datatype]))
|#