#lang rebellion/private/dependencies/layer1

(provide
 (contract-out
  [keyword? predicate?]
  [keyword->symbol (-> keyword? interned-symbol?)]))

(require rebellion/private/name-lite
         rebellion/private/predicate-lite
         rebellion/private/symbol
         (only-in racket/base [keyword? racket:keyword?]))

;@------------------------------------------------------------------------------

(define keyword?
  (make-predicate racket:keyword? #:name (symbolic-name 'keyword?)))

(define (keyword->symbol kw) (string->symbol (keyword->string kw)))
