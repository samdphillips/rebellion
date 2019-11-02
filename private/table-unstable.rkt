#lang racket/base

(require lens/common
         lens/data/vector
         rebellion/collection/record/unstable
         (submod rebellion/private/table internal))

(provide table-value-lens)

;; XXX: validate sizes
(define table-columns-lens
  (make-lens
    table-backing-column-vectors
    (lambda (a-table a-record)
      (make-table #:backing-column-vectors a-record
                  #:size (table-size a-table)))))

(define (table-column-lens column-name)
  (lens-thrush table-columns-lens
               (record-field-lens column-name)))

(define (table-value-lens column-name pos)
  (lens-thrush (table-column-lens column-name)
               (vector-ref-lens pos)))
