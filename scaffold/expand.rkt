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
         racket/format
         racket/list
         racket/logging
         racket/port
         racket/string)

;; ---------- Implementation

(define (blank-missing-value-handler name) "")

(define (expand-file source target context [missing-value-handler blank-missing-value-handler])
  (log-debug "expand ~a ==> ~a" source target)
  (call-with-input-file* source
    (λ (in)
      (let ([str (port->string in)])
        (call-with-output-file* target
                                (λ (out) (display
                                          (expand-string str context missing-value-handler)
                                          out)))))))

(define (expand-string str context [missing-value-handler blank-missing-value-handler])
  (define matches (regexp-match-positions* moustache str #:match-select values))
  (if (or (false? matches) (empty? matches))
      str
      (let ([out (open-output-string)])
        (expand-matches str 0 (string-length str) matches out context missing-value-handler))))

;; ---------- Internal procedures

;; The following is a pretty complete match for Moustache/Handlebars
(define moustache
  (regexp "\\{\\{([\\#\\^/!>&]?)(\\{\\s*[^}]*\\s*\\}|\\s*[^}]*\\s*|=\\S+\\s+\\S+=)\\}\\}"))
;; group 0 - the overall match
;; group 1 - any prefix characters
;; group 2 - the embedded tag


(define (expand-matches str start end matches out context missing-value-handler)
  (if (or (false? matches) (empty? matches))
      str
      (let next-match ([last start]
                       [pos-list (first matches)]
                       [more (rest matches)]
                       [skip-to #f])
        (cond
          [(and skip-to (equal? skip-to pos-list))
           (set! skip-to #f)]
          [(not skip-to)
           (let-values ([(prefix value) (prefix-and-value str pos-list)])
             (display (substring str last (t-start (first pos-list))) out)
             (display (cond
                        [(equal? prefix "!")
                         ""]
                        [(string-between? value "{" "}")
                         (escape-string (ref context
                                             (substring-between value 1)
                                             missing-value-handler))]
                        [(equal? prefix "&")
                         (escape-string (ref context
                                             value
                                             missing-value-handler))]
                        [(string-in? prefix '("#" "^"))
                         (let ([end (for/or ([end-list more])
                                      (let-values ([(e-prefix e-value)
                                                    (prefix-and-value str end-list)])
                                        (if (and (equal? e-prefix "/")
                                                 (equal? e-value value))
                                            (member end-list more)
                                            #f)))])
                           (cond
                             [(equal? end #f)
                              (error "no end tag for block")]
                             [(let ([content (ref context value blank-missing-value-handler)])
                                (or (and (equal? prefix "#") content)
                                    (and (equal? prefix "^") (not content))))
                              (let ([new-context (ref context value blank-missing-value-handler)]
                                    [sub-matches (take more (index-of more (first end)))])
                                (when (list? new-context)
                                  (for ([item new-context])
                                    (expand-matches str
                                                    (t-end (first pos-list))
                                                    (t-start (first (first end)))
                                                    sub-matches
                                                    out
                                                    item
                                                    missing-value-handler))))])
                           (set! skip-to end))
                         ""]
                        [(equal? prefix "/")
                         (error "unexpected conditional end")]
                        [(equal? prefix ">")
                         (error "unsupported: partial block expressions")]
                        [(string-prefix? value ".")
                         (error "unsupported: relative paths")]
                        [(string-between? value "=" "=")
                         (error "unsupported: setting delimiters")]
                        [else (ref context
                                   value
                                   missing-value-handler)])
                      out))])
        (if (empty? more)
            (display (substring str (t-end (first pos-list)) end) out)
            (next-match (t-end (third pos-list)) (first more) (rest more) skip-to))
        (get-output-string out))))

(define (t-start pair) (car pair))

(define (t-end pair) (cdr pair))

(define (prefix-and-value str a-match)
  (values (substring str (t-start (second a-match)) (t-end (second a-match)))
          (substring-tag str (third a-match))))

(define (substring-tag str position-pair)
  (string-trim (substring str
                          (t-start position-pair)
                          (t-end position-pair))))

(define (substring-between str characters)
  (string-trim (substring str
                          characters
                          (- (string-length str) characters))))

(define (string-between? str prefix suffix)
  (and (string-prefix? str prefix)
       (string-suffix? str suffix)))

(define (string-in? str strings)
  (for/or ([string strings]) (equal? str string)))

(define (ref top-context key missing-value-handler)
  (let nested ([context top-context] [names (string-split key ".")])
    (define value (hash-ref context (first names) (missing-value-handler key)))
    (cond
      [(and (> (length names) 1) (hash? value))
       (nested value (rest names))]
      [(and (= (length names) 1) (procedure? value))
       (if (= (procedure-arity value) 1)
           (value (first names))
           (value))]
      [(and (= (length names) 1))
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
        (next (string-replace in-str (t-start pair) (t-end pair)) (rest replace)))))
