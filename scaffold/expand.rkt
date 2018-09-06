#lang racket/base
;;
;; Scaffolding templated Racket files.
;;
;; See:
;;   https://mustache.github.io/
;;   https://handlebarsjs.com/
;;
;; ~ Simon Johnston 2018.
;;

(require racket/contract)

(provide
 (contract-out

  [expand-file
   (->* (path-string? path-string? hash?) ((-> string? string?)) void?)]

  [expand-string
   (->* (string? hash?) ((-> string? string?)) string?)]

  [blank-missing-value-handler
   (-> string? string?)]))

;; ---------- Requirements

(require racket/bool
         racket/list
         racket/port
         racket/string)

;; ---------- Implementation

(define (blank-missing-value-handler name) "")

(define (expand-file source target replacements [missing-value-handler blank-missing-value-handler])
  (call-with-input-file* source
    (λ (in)
      (let ([str (port->string in)])
        (call-with-output-file* target
                                (λ (out) (display
                                          (expand-string str replacements missing-value-handler)
                                          out)))))))

(define (expand-string str replacements [missing-value-handler blank-missing-value-handler])
  (define matches (regexp-match-positions* moustache str #:match-select values))
  (if (or (false? matches) (empty? matches))
      str
      (let ([out (open-output-string)])
        (let next-match ([last 0]
                         [pos-list (first matches)]
                         [more (rest matches)])
          (let ([prefix (substring str (car (second pos-list)) (cdr (second pos-list)))]
                [value (substring-tag str (third pos-list))])
            (display (substring str last (car (first pos-list))) out)
            (display (cond
                       [(equal? prefix "!")
                        ""]
                       [(string-between? value "{" "}")
                        (escape-string (ref replacements
                                            (substring-between value 1)
                                            missing-value-handler))]
                       [(equal? prefix "&")
                        (escape-string (ref replacements
                                            value
                                            missing-value-handler))]
                       [(string-prefix? value ".")
                        (error "unsupported: relative paths")]
                       [(string-in? prefix '("#" "^" "/"))
                        (error "unsupported: conditional block expressions")]
                       [(equal? prefix ">")
                        (error "unsupported: partial block expressions")]
                       [(string-between? value "=" "=")
                        (error "unsupported: setting delimiters")]
                       [else (ref replacements
                                  value
                                  missing-value-handler)])
                     out)
            (if (empty? more)
                (display (substring str (cdr (first pos-list))) out)
                (next-match (cdr (third pos-list)) (first more) (rest more)))
            (get-output-string out))))))

;; ---------- Internal procedures

;; The following is a pretty complete match for Moustache/Handlebars
(define moustache
  (regexp "\\{\\{([\\#\\^/!>&]?)(\\{\\s*[^}]*\\s*\\}|\\s*[^}]*\\s*|=\\S+\\s+\\S+=)\\}\\}"))
;; group 0 - the overall match
;; group 1 - any prefix characters
;; group 2 - the embedded tag

(define (substring-tag str position-pair)
  (string-trim (substring str
                          (car position-pair)
                          (cdr position-pair))))

(define (substring-between str characters)
  (string-trim (substring str
                          characters
                          (- (string-length str) characters))))

(define (string-between? str prefix suffix)
  (and (string-prefix? str prefix)
       (string-suffix? str suffix)))

(define (string-in? str strings)
  (for/or ([string strings]) (equal? str string)))

(define (ref top-replacements key missing-value-handler)
  (let nested ([replacements top-replacements] [names (string-split key ".")])
    (define value (hash-ref replacements (first names) (missing-value-handler key)))
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
