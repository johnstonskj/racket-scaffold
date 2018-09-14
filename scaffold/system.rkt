#lang racket/base
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

(provide
 system-value

 find-user-id

 find-user-name)


;; ---------- Requirements

(require racket/date
         racket/logging
         racket/match
         racket/port
         racket/string
         racket/system)

;; ---------- Implementation

(define (system-value command)
  (define string-error (open-output-string))
  (define result (parameterize ([current-error-port string-error])
                   (string-trim
                    (with-output-to-string
                      (lambda ()
                        (system command))))))
  (when (get-output-string string-error)
    (log-info "system ~a error: ~a" command (get-output-string string-error)))
  result)
  
  
(define (find-user-id)
  (match (system-type)
    ['unix
     (system-value "whoami")]
    ['macosx
     (system-value "id -un")]
    ['windows
     (system-value "echo %username%")]
    [else ""]))

(define (find-user-name)
  (define git-name (system-value "git config --global user.name"))
  (if (non-empty-string? git-name)
      git-name
      (match (system-type)
        ['macosx
         (system-value "id -F")]
        [else ""])))


