#lang racket

(require syntax/parse/define)

(struct de-bruijn-application (free-variables function-term argument-terms)
  #:constructor-name plain-de-bruijn-application
  #:omit-define-syntaxes)

(struct de-bruijn-abstraction (free-variables lambda-layers body-term)
  #:constructor-name plain-de-bruijn-abstraction
  #:omit-define-syntaxes)

(struct de-bruijn-variable (reference)
  #:omit-define-syntaxes)

(define (de-bruijn-application function-term . argument-terms)
  (define terms (cons function-term argument-terms))
  (define unbound-variables
    (apply max (map de-bruijn-term-free-variables terms)))
  (plain-de-bruijn-application unbound-variables function-term argument-terms))

(define (de-bruijn-abstraction body-term #:lambda-layers [layers 1])
  (define unbound-variables
    (max 0 (- (de-bruijn-term-free-variables body-term) layers)))
  (plain-de-bruijn-abstraction unbound-variables layers body-term))

(define (de-bruijn-term? term)
  (or (de-bruijn-application? term)
      (de-bruijn-abstraction? term)
      (de-bruijn-variable? term)))

(define/contract (de-bruijn-term-free-variables term)
  (-> de-bruijn-term? natural?)
  (cond [(de-bruijn-application? term)
         (de-bruijn-application-free-variables term)]
        [(de-bruijn-abstraction? term)
         (de-bruijn-abstraction-free-variables term)]
        [(de-bruijn-variable? term)
         (de-bruijn-variable-reference term)]))

(define (proper-de-bruijn-term? term)
  (and (de-bruijn-term? term)
       (zero? (de-bruijn-term-free-variables term))))

(define (improper-de-bruijn-term? term)
  (and (de-bruijn-term? term)
       (positive? (de-bruijn-term-free-variables term))))

(begin-for-syntax
  (define-syntax-class de-bruijn-expression
    #:attributes (term)
    #:literals (λ)
    (pattern reference:exact-positive-integer
             #:with term #'(de-bruijn-variable reference))
    (pattern ((~and layer λ) ...+ body:de-bruijn-body)
             #:do [(define layers (length (syntax->list #'(layer ...))))]
             #:with term
             #`(de-bruijn-abstraction body.term #:lambda-layers #,layers))
    (pattern id:id #:with term #'id)
    (pattern (function:de-bruijn-expression arg:de-bruijn-expression ...+)
             #:with term #'(de-bruijn-application function.term arg.term ...)))
  (define-splicing-syntax-class de-bruijn-body
    #:attributes (term)
    (pattern :de-bruijn-expression)
    (pattern (~seq function:de-bruijn-expression arg:de-bruijn-expression ...+)
             #:with term #'(de-bruijn-application function.term arg.term ...))))
    

(define-simple-macro
  (define-de-bruijn id:id (~optional (~seq #:alias alias:id))
    expr:de-bruijn-expression)
  (~? (begin (define id expr.term) (define alias id))
      (define id expr.term)))
    
;; Traditional SKI combinator calculus. These three combinators together define
;; a Turing-complete language, without the need for any other lambdas.
;;
;; S = λfgx.fx(gx)
;; K = λkx.k
;; I = λx.x
;;
;; Lambda calculus terms are represented as data structures where variables are
;; replaced with de Bruijn indices - numbers representing which enclosing lambda
;; the variable was bound by.

(define-de-bruijn de-bruijn-substitution-combinator #:alias S (λ λ λ 3 1 (2 1)))
(define-de-bruijn de-bruijn-constant-combinator #:alias K (λ λ 2))
(define-de-bruijn de-bruijn-identity-combinator #:alias I (λ 1))

;; Universal iota combinator (this combinator is Turing-complete on its own)
;; ι = λf.fSK

(define-de-bruijn de-bruijn-iota-combinator #:alias ι (λ 1 S K))

;; Combinators for the alternate BCKW system. This system is often a more
;; effective "assembly language" than SKI for compiling lambdas into combinator
;; calculus expressions.
;;
;; B = λfgx.f(gx)
;; C = λfxy.fyx
;; W = λfx.fxx
;;
;; Furthermore, by choosing to use only subsets of these combinators, one can
;; control whether or not the resulting combinator language has various
;; interesting restrictions beyond normal lambda calculus:
;;
;;   BCI = linear lambda calculus (variables must be used exactly once)
;;   BCKI = affine lambda calculus (variables must be used at most once)
;;   BCWI = relevant lambda calculus (variables must be used at least once)
;;   BI = ordered linear lambda calculus (like linear, but variables must be
;;     used in the order they're declared - λxy.xy OK, λxy.yx NOT OK)

(define-de-bruijn de-bruijn-compose-combinator #:alias B (λ λ λ 3 (2 1)))
(define-de-bruijn de-bruijn-swap-combinator #:alias C (λ λ λ 3 1 2))
(define-de-bruijn de-bruijn-duplicate-cominbator #:alias W (λ λ 2 1 1))

;; Boolean logic combinators. True and false are two-argument functions that
;; return either the first or second argument, and an if condition becomes a
;; three argument function where the first argument (a boolean) is given the
;; second and third arguments (the conditional branches)
;;
;; TRUE = λxy.x = K
;; FALSE = λxy.y
;; IF = λbxy.bxy
;; IF TRUE x y => TRUE x y => x
;; IF FALSE x y => FALSE x y => y

(define-de-bruijn de-bruijn-true-combinator #:alias TRUE K)
(define-de-bruijn de-bruijn-false-combinator #:alias FALSE (λ λ 1))
(define-de-bruijn de-bruijn-if-combinator #:alias IF (λ λ λ 3 2 1))
