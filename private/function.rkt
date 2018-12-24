#lang rebellion/private/dependencies/layer1

(provide
 (contract-out
  [procedure? predicate?]))

(require rebellion/private/name-lite
         rebellion/private/predicate-lite
         (only-in racket/base [procedure? racket:procedure?]))

;@------------------------------------------------------------------------------

(define procedure?
  (make-predicate racket:procedure? #:name (symbolic-name 'procedure?)))
