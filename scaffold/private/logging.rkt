#lang racket/base
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

(provide
 
 (all-defined-out)
 
 with-logging-to-port)

(require racket/logging)

(define-logger scaffold)

(current-logger scaffold-logger)

(define scaffold-log-level (make-parameter 'warning))