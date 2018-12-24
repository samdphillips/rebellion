#lang rebellion/private/dependencies/layer1

(provide
 (contract-out
  [list? predicate?]))

(require rebellion/private/name-lite
         rebellion/private/predicate-lite
         (only-in racket/base [list? racket:list?]))

;@------------------------------------------------------------------------------

(define list? (make-predicate racket:list? #:name (symbolic-name 'list?)))
