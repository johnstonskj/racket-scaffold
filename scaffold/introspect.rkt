#lang racket/base
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

(require racket/contract)

(provide

 (contract-out
  
  [introspect-module
   (-> symbol? module-info?)]

  [display-module
   (->* (module-info?) (output-port?) void?)])

 (except-out
  (struct-out module-info)
  module-info)
 
 (except-out
  (struct-out export-info)
  export-info))

(struct module-info
  (name
   namespace
   base-phase
   exports))

(struct export-info
  (name
   level
   form
   primitive?
   procedure?
   input-arity
   keywords
   result-arity
   contract
   value
   exported-from))

;; ---------- Requirements

(require racket/function
         racket/list
         racket/port
         racket/string)

;; ---------- Implementation

(define (introspect-module module-name)
  (dynamic-require module-name 0)
  (define namespace (module->namespace module-name))
  (module-info
   module-name
   namespace
   (namespace-base-phase namespace)
   (let-values ([(vars syntax) (module->exports module-name)])
     (append (introspect-exports namespace 'variable vars)
             (introspect-exports namespace 'syntax syntax)))))

(define (display-module mod [out (current-output-port)])
  (displayln (format "~a:" (module-info-name mod)) out)
  (displayln (format "|-- namespace: ~a" (module-info-namespace mod)) out)
  (displayln (format "|-- base phase: ~a" (module-info-base-phase mod)) out)
  (display-exports (module-info-exports mod) out)
  (void))

;; ---------- Internal procedures

(define (introspect-exports namespace form leveled-lists)
  (flatten (for/list ([level-list leveled-lists])
             (define level (first level-list))
             (for/list ([export (rest level-list)])
               (introspect-export namespace form level export)))))

(define (introspect-export namespace form level export)
  (define name (first export))
  (define thing (with-handlers ([exn? (λ (e) name)])
                  (eval name namespace)))
  (define ns:thing (syntax-shift-phase-level (namespace-symbol->identifier name) 1))
  (export-info
   name
   level
   form
   (primitive? thing)
   (procedure? thing)
   (if (procedure? thing) (procedure-arity thing) #f)
   (if (procedure? thing)
        (let-values ([(required all) (procedure-keywords thing)])
          (list
           required
           (filter (λ (kw) (not (member kw required))) all)))
        #f)
   (if (procedure? thing) (procedure-result-arity thing) #f)
   (value-contract thing)
   (if (variable-reference? ns:thing) (namespace-variable-value name) #f)
   (second export)))

(define (display-exports exports out)
  (displayln "|-- exports:" out)
  (for ([export exports])
    (display (format "    |-- form: ~a" (export-info-form export)) out)
    (display (format ", level: ~a" (export-info-level export)) out)
    (display (format ", ~a:" (export-info-name export)) out)
    (when (export-info-primitive? export)
        (display " [primitive]") out)
    (when (export-info-procedure? export)
      (when (export-info-input-arity export)
        (display (format " (arity: ~a" (export-info-input-arity export)) out))
      (when (> (length (first (export-info-keywords export))) 0)
        (display (format " ~a"
                         (string-join (append
                                       (first (export-info-keywords export))
                                       (map (λ (e) (format "[~a]" e))
                                            (second (export-info-keywords export)))
                                       " "))) out))
      (when (export-info-result-arity export)
        (display (format " -> ~a" (export-info-result-arity export)) out))
      (display ")" out))
    (when (export-info-contract export)
      (display (format " :- ~a" (export-info-contract export)) out))
    (when (not (empty? (export-info-exported-from export)))
      (display (format ", declared in ~a" (export-info-exported-from export)) out))
    (newline out)))

(display-module (introspect-module 'scaffold/planks))

;(introspect-module 'rackunit)

;(display-module (introspect-module 'rml/data))