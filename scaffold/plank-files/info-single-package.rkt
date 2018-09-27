#lang info
;;
;; Package {{package-name}}.
;;   {{content-description}}
;;
;; Copyright (c) {{year}} {{user-name}} ({{user-email}}).

(define collection "{{collection-name}}")
(define pkg-desc "{{content-description}}")
(define version "{{package-version}}")
(define pkg-authors '({{user-name}}))

(define scribblings '(("scribblings/{{package-name}}.scrbl" {{scribble-structure}})))
(define test-omit-paths '("scribblings" "private"))

(define deps '(
  "base"
  "rackunit-lib"
  "racket-index"))
(define build-deps '(
  "scribble-lib"
  "racket-doc"
  "sandbox-lib"
  "cover-coveralls"))
