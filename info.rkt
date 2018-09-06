#lang info
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

(define collection 'multi)

(define pkg-desc "Expanded version of `raco pkg new`.")
(define version "1.0")
(define pkg-authors '(simonjo))

(define deps '(
  "base"
  "rackunit-lib"
  "racket-index"))
(define build-deps '(
  "scribble-lib"
  "racket-doc"
  "sandbox-lib"
  "cover-coveralls"))
