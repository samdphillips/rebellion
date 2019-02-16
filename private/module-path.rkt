#lang racket/base

(struct relative-module-path (string) #:transparent)

(struct collection-module-path (collection-names file-name) #:transparent)

(struct file-module-path (string) #:transparent)

(struct planet-module-path
  (user package version-constraint rel-string rel-strings) #:transparent)

(struct self-module-path ()
  #:transparent
  #:omit-define-syntaxes
  #:constructor-name plain-self-module-path)

(define self-module-path (plain-self-module-path))

(struct enclosing-module-path ()
  #:transparent
  #:omit-define-syntaxes
  #:constructor-name plain-enclosing-module-path)

(define enclosing-module-path (plain-enclosing-module-path))

(struct submodule-path (root elements) #:transparent)

(define (root-module-path? v)
  (or (relative-module-path? v)
      (collection-module-path? v)
      (file-module-path? v)
      (planet-module-path? v)))
