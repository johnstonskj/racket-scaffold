#lang racket
;;
;; Scaffolding templated Racket files.
;;
;; See:
;;   https://mustache.github.io/
;;   https://handlebarsjs.com/
;;
;; ~ Simon Johnston 2018.
;;

(provide
 
 expand-file

 expand-string

 blank-missing-value-handler)

;; ---------- Requirements

(require racket/bool
         racket/list
         racket/port
         racket/string)

;; ---------- Implementation

(define (blank-missing-value-handler name) "")

(define (expand-file source target values [missing-value-handler blank-missing-value-handler])
  (call-with-input-file* source
    (λ (in)
      (let ([str (port->string in)])
        (call-with-output-file* target
                                (λ (out) (display
                                          (expand-string str values missing-value-handler)
                                          out)))))))

(define (expand-string str values [missing-value-handler blank-missing-value-handler])
  (define matches (regexp-match-positions* simple str))
  (if (or (false? matches) (empty? matches))
      str
      (let ([out (open-output-string)])
        (let next-match ([last 0]
                         [pos (first matches)]
                         [more (rest matches)])
          (let ([value (substring-tag str pos)])
            (display (substring str last (car pos)) out)
            (display (cond
                       [(string-prefix? value "!")
                        ""]
                       [(string-between? value "{" "}")
                        (escape-string (ref values
                                            (substring-between value 1)
                                            missing-value-handler))]
                       [(string-prefix? value "&")
                        (escape-string (ref values
                                            (string-trim (substring value 1))
                                            missing-value-handler))]
                       [(string-prefix? value ".")
                        (error "unsupported: relative paths")]
                       [(string-prefix-in? value '("#" "^" "/"))
                        (error "unsupported: conditional block expressions")]
                       [(string-prefix? value ">")
                        (error "unsupported: partial block expressions")]
                       [(string-between? value "=" "=")
                        (error "unsupported: setting delimiters")]
                       [else (ref values
                                  value
                                  missing-value-handler)])
                     out)
            (if (empty? more)
                (display (substring str (cdr pos)) out)
                (next-match (cdr pos) (first more) (rest more)))
            (get-output-string out))))))

;; ---------- Internal procedures

(define simple (regexp "\\{\\{\\{?[^}]*\\}\\}\\}?"))

(define (substring-tag str position-pair)
  (string-trim (substring str
                          (+ (car position-pair) 2)
                          (- (cdr position-pair) 2))))

(define (substring-between str characters)
  (string-trim (substring str
                          characters
                          (- (string-length str) characters))))

(define (string-between? str prefix suffix)
  (and (string-prefix? str prefix)
       (string-suffix? str suffix)))

(define (string-prefix-in? str prefixes)
  (for/or ([prefix prefixes]) (string-prefix? str prefix)))

(define (ref top-values key missing-value-handler)
  (let nested ([values top-values] [names (string-split key ".")])
    (define value (hash-ref values (first names) (missing-value-handler key)))
    (cond
      [(and (> (length names) 1) (hash? value))
       (nested value (rest names))]
      [(and (= (length names) 1) (procedure? value))
       (if (= (procedure-arity value) 1)
           (value (first names))
           (value))]
      [(and (= (length names) 1) (string? value))
       value]
      [else (missing-value-handler key)])))

(define html-escapes '(("&" . "&amp;")
                       ("<" . "&lt;")
                       (">" . "&gt;")
                       ("\"" .  "&quot;")
                       ("'"  . "&#39;")))

(define (escape-string str [replace-pairs html-escapes])
  (let next ([in-str str] [replace replace-pairs])
    (define pair (first replace))
    (if (empty? (rest replace))
        in-str
        (next (string-replace in-str (car pair) (cdr pair)) (rest replace)))))
