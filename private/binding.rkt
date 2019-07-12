#lang racket/base

(require racket/contract/base)

(provide
 (contract-out
  [binding (-> module-path? symbol? phase? binding?)]
  [binding? predicate/c]
  [binding-source (-> binding? module-path?)]
  [binding-name (-> binding? symbol?)]
  [binding-phase (-> binding? phase?)]
  [module-provided-bindings (-> module-path? (set/c binding?))]
  [module-provided-names (-> module-path? (multidict/c phase? symbol?))]
  [module-required-bindings (-> module-path? (multidict/c phase? binding?))]
  [module-internal-bindings (-> module-path? (set/c binding?))]))

(require racket/list
         racket/set
         rebellion/collection/entry
         rebellion/collection/multidict
         rebellion/module/phase
         rebellion/type/tuple
         syntax/parse/define)

;@------------------------------------------------------------------------------

(define-tuple-type binding (source name phase))

(define (module-provided-bindings mod)
  (dynamic-require mod #f)
  (define-values (exported-variables exported-syntax) (module->exports mod))
  (for*/set ([export-list (in-list (list exported-variables exported-syntax))]
             [phase-export-list (in-list export-list)]
             [ph (in-value (phase (first phase-export-list)))]
             [export (in-list (rest phase-export-list))])
    (binding mod (first export) ph)))

(define (module-provided-names mod)
  (for/multidict ([bind (in-immutable-set (module-provided-bindings mod))])
    (entry (binding-phase bind) (binding-name bind))))

(define (module-required-bindings mod) #f)
(define (module-internal-bindings mod) #f)
