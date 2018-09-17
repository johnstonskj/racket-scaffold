#lang {{module-language}}
;;
;; {{package-name}} - {{content-name}}.
;;   {{content-description}}
;;
;; Copyright (c) {{year}} {{user-name}} ({{user-email}}).

;; Racket Style Guide: http://docs.racket-lang.org/style/index.html

(require racket/contract)

(provide
 (contract-out))

;; ---------- Requirements

(require{{module-requires}})

;; ---------- Internal types

;; ---------- Implementation

;; ---------- Internal procedures

;; ---------- Internal tests

(module+ test
  (require rackunit)
  ;; only use for internal tests, use check- functions 
  (check-true "dummy first test" #f))
{{^private-module}}
(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
{{/private-module}}