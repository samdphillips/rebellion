#lang racket/base

(module+ main
  (require setup/setup)

  (setup #:pkgs (list "rebellion")
         #:make-docs? #t
         #:make-doc-index? #t
         #:tidy? #t))
