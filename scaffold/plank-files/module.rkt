#lang {{module-language}}
;;
;; {{parent-package-name}} - {{content-name}}.
;;   {{content-description}}
;;
;; Copyright (c) {{year}} {{user-name}} ({{user-email}}).

(provide
 (contract-out))

;; ---------- Requirements

(require)

;; ---------- Internal types

;; ---------- Implementation

;; ---------- Internal procedures

;; ---------- Internal tests

(module+ test
  (require rackunit rackunit/docs-complete)
  ; only use for internal tests, use check- functions 
  (check-true "dummy first test" #f))