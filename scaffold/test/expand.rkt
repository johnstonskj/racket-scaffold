#lang racket/base
;;
;; racket-scaffold - expand.
;;   Test cases for the template engine
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; ---------- Requirements

(require rackunit
         ; ---------
         "../expand.rkt")

;; ---------- Test Fixtures

;; ---------- Internal procedures

(define (myname v) "steve")

;; ---------- Test Cases - Success

(test-case
 "expand-string: success"
 (check-equal?
   (expand-string "hello {{name}} :)" (hash "name" "simon"))
   "hello simon :)"))
  
(test-case
 "expand-string: success with comment"
  (check-equal?
   (expand-string "hello {{!name}} :)" (hash "name" "simon"))
   "hello  :)"))
  
(test-case
 "expand-string: success with lambda value"
  (check-equal?
   (expand-string "hello {{name}} :)" (hash "name" myname))
   "hello steve :)"))
  
(test-case
 "expand-string: success with html escape &"
  (check-equal?
   (expand-string "hello {{& name}} :)" (hash "name" "<simon>"))
   "hello &lt;simon&gt; :)"))
  
(test-case
 "expand-string: success with html escape {}"
  (check-equal?
   (expand-string "hello {{{name}}} :)" (hash "name" "<simon>"))
   "hello &lt;simon&gt; :)"))
  
(test-case
 "expand-string: success with nested"
  (check-equal?
   (expand-string "hello {{my.name}} :)" (hash "my" (hash "name" "simon")))
   "hello simon :)"))
  
(test-case
 "expand-string: success with missing key"
  (check-equal?
   (expand-string "hello {{no-name}} :)" (hash "name" "simon"))
   "hello  :)"))

(test-case
 "expand-string: success with missing key, and handler"
  (check-equal?
   (expand-string "hello {{no-name}} :)" (hash "name" "simon") (λ (n) "oops"))
   "hello oops :)"))

(test-case
 "expand-string: success with # conditional"
 (define c (hash "items" (list (hash "item" "one")
                               (hash "item" "two")
                               (hash "item" "three"))))
 (check-equal?
  (expand-string "a list: {{#items}} {{item}}, {{/items}}and that's all" c)
  "a list:  one,  two,  three, and that's all")
 (check-equal?
  (expand-string "a list: {{#items}} {{_}}, {{/items}}and that's all"
                 (hash "items" '(a b c)))
  "a list:  a,  b,  c, and that's all"))

;; ---------- Test Cases - Errors

(test-case
 "expand-string: unbalanced conditionals"
  (check-exn
   exn:fail?
   (λ ()
     (expand-string "hello {{#unsupported}} :)" (hash "name" "simon"))))
  (check-exn
   exn:fail?
   (λ ()
     (expand-string "hello {{^unsupported}} :)" (hash "name" "simon"))))
  (check-exn
   exn:fail?
   (λ ()
     (expand-string "hello {{/unsupported}} :)" (hash "name" "simon")))))

;; ---------- Test Cases - Unsupported

(test-case
 "expand-string: unsupported relative path"
  (check-exn
   exn:fail?
   (λ ()
     (expand-string "hello {{../name}} :)" (hash "name" "simon")))))

(test-case
 "expand-string: unsupported partials"
  (check-exn
   exn:fail?
   (λ ()
     (expand-string "hello {{> unsupported}} :)" (hash "name" "simon")))))

(test-case
 "expand-string: unsupported set delimiter"
  (check-exn
   exn:fail?
   (λ ()
     (expand-string "hello {{=<% %>=}} :)" (hash "name" "simon")))))
