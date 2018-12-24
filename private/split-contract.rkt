#lang racket

(struct split-contract (procedure)
  #:constructor-name make-split-contract)

(define split-contract-procedure/c
  (-> blame?
      (values (-> any/c any/c any/c)
              (-> any/c any/c))))
