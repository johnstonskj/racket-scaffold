#lang info
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

(define collection "scaffold")
(define scribblings '(("scribblings/scaffold.scrbl" ())))

(define raco-commands
  '(("scaffold" scaffold/main "create content from scaffold planks" 85)))

(define compile-omit-paths '("plank-files"))
(define test-omit-paths '("scribblings" "plank-files"))