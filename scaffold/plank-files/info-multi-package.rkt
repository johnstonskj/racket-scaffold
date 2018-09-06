#lang info
;;
;; Package {{content-name}}.
;;   {{content-description}}
;;
;; Copyright (c) {{year}} {{user-name}} ({{user-email}}).

(define collection 'multi)

(define pkg-desc "{{content-description}}")
(define version "{{package-version}}")
(define pkg-authors '({{user-name}}))

(define deps '(
  "base"
  "rackunit-lib"
  "racket-index"))
(define build-deps '(
  "scribble-lib"
  "racket-doc"
  "sandbox-lib"
  "cover-coveralls"))
