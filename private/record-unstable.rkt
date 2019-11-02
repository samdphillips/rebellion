#lang racket/base

(require lens/common
         rebellion/collection/record)

(provide record-field-lens)

(define (record-field-lens field-name)
  (make-lens
    (lambda (a-record)
      (record-ref a-record field-name))
    (lambda (a-record a-value)
      (build-record
        (lambda (record-field-name)
          (cond
            [(equal? record-field-name field-name) a-value]
            [else (record-ref a-record record-field-name)]))
        (record-keywords a-record)))))
