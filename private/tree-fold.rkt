#lang racket

(require racket/struct)

(module+ test
  (require rackunit))

(struct leaf (value) #:transparent)

(define write-branch
  (make-constructor-style-printer
   (λ (_) 'branch)
   (λ (br) (list (branch-left-tree br) (branch-right-tree br)))))

(struct branch (depth left-tree right-tree)
  #:transparent
  #:omit-define-syntaxes
  #:constructor-name plain-branch
  #:methods gen:custom-write [(define write-proc write-branch)])

(define (tree-depth tr)
  (if (leaf? tr) 1 (branch-depth tr)))

(define (branch left-tree right-tree)
  (plain-branch (add1 (max (tree-depth left-tree) (tree-depth right-tree)))
                left-tree
                right-tree))

(module+ test
  (test-case "tree-depth"
    (check-equal? (tree-depth (leaf 42)) 1)
    (check-equal? (tree-depth (branch (leaf 42) (leaf 17))) 2)
    (check-equal? (tree-depth (branch (branch (leaf 42) (leaf 17))
                                      (leaf 5)))
                  3)
    (check-equal? (tree-depth (branch (leaf 5)
                                      (branch (leaf 42) (leaf 17))))
                  3)
    (check-equal? (tree-depth (branch (branch (leaf 5) (leaf 124))
                                      (branch (leaf 42) (leaf 17))))
                  3)))

(struct tree-collector-state (stack) #:transparent)

(define (tree-collector-start tr) (tree-collector-state (list tr)))

(define (tree-collector-consume st v)
  (define tree-stack (tree-collector-state-stack st))
  (define (new-stack [new-tree (leaf v)] [tree-stack tree-stack])
    (cond [(empty? tree-stack) (list new-tree)]
          [else
           (define shallowest-tree (first tree-stack))
           (if (= (tree-depth new-tree) (tree-depth shallowest-tree))
               (new-stack (branch shallowest-tree new-tree)
                          (rest tree-stack))
               (cons new-tree tree-stack))]))
  (tree-collector-state (new-stack)))

(define (tree-collector-shutdown st)
  (define trees (tree-collector-state-stack st))
  (let loop ([tree (first trees)] [trees (rest trees)])
    (if (empty? trees)
        tree
        (loop (branch (first trees) tree) (rest trees)))))

(define (collect-list-into-tree tr lst)
  (let loop ([current-state (tree-collector-start tr)] [lst lst])
    (if (empty? lst)
        (tree-collector-shutdown current-state)
        (loop (tree-collector-consume current-state (first lst)) (rest lst)))))

(module+ test
  (test-case "collect-list-into-tree"
    (check-equal? (collect-list-into-tree (leaf 0)
                                          (list 1 2 3))
                  (branch (branch (leaf 0) (leaf 1))
                          (branch (leaf 2) (leaf 3))))
    (check-equal? (collect-list-into-tree (leaf 0)
                                          (list 1 2 3 4 5 6 7 8 9))
                  (branch (branch (branch (branch (leaf 0) (leaf 1))
                                          (branch (leaf 2) (leaf 3)))
                                  (branch (branch (leaf 4) (leaf 5))
                                          (branch (leaf 6) (leaf 7))))
                          (branch (leaf 8) (leaf 9))))
    (check-equal? (collect-list-into-tree (leaf 0)
                                          (list 1 2 3 4 5 6 7 8 9))
                  (branch (branch (branch (branch (leaf 0) (leaf 1))
                                          (branch (leaf 2) (leaf 3)))
                                  (branch (branch (leaf 4) (leaf 5))
                                          (branch (leaf 6) (leaf 7))))
                          (branch (leaf 8) (leaf 9))))
    (check-equal? (collect-list-into-tree (leaf 0)
                                          (list 1 2 3 4 5 6 7 8 9))
                  (branch (branch (branch (branch (leaf 0) (leaf 1))
                                          (branch (leaf 2) (leaf 3)))
                                  (branch (branch (leaf 4) (leaf 5))
                                          (branch (leaf 6) (leaf 7))))
                          (branch (leaf 8) (leaf 9))))))
