#lang scribble/manual

@(require (for-label racket/base
                     racket/contract/base
                     rebellion/module-path)
          scribble/example)

@(define module-sharing-evaluator-factory
   (make-base-eval-factory (list 'racket/base 'rebellion/module-path)))

@(define (make-evaluator)
   (define evaluator (module-sharing-evaluator-factory))
   (evaluator '(require rebellion/module-path))
   evaluator)

@title{Module Paths}
@defmodule[rebellion/module-path]

@defproc[(module-path? [v any/c]) boolean?]{
 A predicate for module paths.}

@defproc[(root-module-path? [v any/c]) boolean?]{
 A predicate for root module paths. Implies @racket[module-path?].}
