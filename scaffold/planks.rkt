#lang racket/base
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

(provide

 readme-types

 license-types

 package-types
 
 expand-package

 expand-collection
 
 expand-module
 
 expand-test-module
 
 expand-scribblings

 expand-a-plank

 list-planks)

;; ---------- Requirements

(require racket/function
         racket/match
         racket/port
         racket/string
         scaffold/expand)

;; ---------- Internal Configuration

(define readme-types (hash "markdown" "md" "text" "txt"))

(define license-types '("Apache-2.0" "BSD" "GPL-3" "LGPL-2.1" "MIT"))

(define package-types '("single" "multi" "triple"))

;; ---------- Implementation

(define (expand-package arguments)
  (vdisplayln 'expand-package (format "package name ~a" (hash-ref arguments "content-name")))
  (vdisplayln 'expand-package (format "package dir ~a" (hash-ref arguments "package-dir")))
  (define package-name (hash-ref arguments "content-name"))
  (let ([package-dir (hash-ref arguments "package-dir")])
    (if (non-empty-string? package-dir)
        (make-directory package-dir)
        (make-directory package-name)))
  (parameterize ([current-directory package-name])
    (let ([file-name (format "README.~a" (string-downcase
                                          (hash-ref readme-types
                                                    (hash-ref arguments "package-readme"))))]
          [heading-underline (make-string (string-length (hash-ref arguments "content-name")) #\=)])
      (vdisplayln 'expand-package (format "readme file ~a" file-name))
      (expand-plank-file file-name
                         (hash-set* arguments
                                    "file-name" file-name
                                    "heading-underline" heading-underline)))
    (let ([plank-name (format "LICENSE-~a" (hash-ref arguments "package-license"))])
      (expand-plank-file plank-name
                       (hash-set arguments "file-name" "LICENSE")))
    (when (hash-ref arguments "package-include-travis")
      (expand-plank-file "dot-travis.yml"
                         (hash-set arguments "file-name" ".travis.yml"))
      (expand-plank-file "Makefile"
                         (hash-set arguments "file-name" "Makefile")))
    (match (hash-ref arguments "package-structure")
      ["single"
       (expand-info "single-package" arguments)]
      ["multi"
       (begin
         (expand-info "multi-package" arguments)
         (expand-collection arguments))]
      ["triple"
       (begin
         (expand-info "multi-package" arguments)
         (expand-collection (hash-set arguments
                                      "content-name"
                                      (format "~a-lib" (hash-ref arguments "content-name"))))
         (expand-collection (hash-set arguments
                                      "content-name"
                                      (format "~a-doc" (hash-ref arguments "content-name"))))
         (expand-collection (hash-set arguments
                                      "content-name"
                                      (format "~a-test" (hash-ref arguments "content-name")))))]
      
      [else (error "invalid package structure")]))
  )

(define (expand-info type arguments)
  (expand-plank-file (format "info-~a.rkt" type)
                     (hash-set* arguments
                                "file-name"
                                "info.rkt"
                                "scribbling-format"
                                (if (equal? (hash-ref arguments "scribble-structure") "multi")
                                    "(multi-page)"
                                    "()"))))

(define (expand-collection arguments [type 'all])
  (define collection (hash-ref arguments "content-name"))
  (define collection-file (format "~a.rkt" collection))
  (if (directory-exists? collection)
      (error (format "cannot overwrite existing collection ~a" collection))
      (begin
        (make-directory collection)
        (parameterize ([current-directory collection])
          (expand-info "collection" arguments)
          (expand-plank-file "module.rkt"
                             (hash-set arguments "file-name" "main.rkt"))
          (when (hash-ref arguments "package-include-private")
            (expand-plank-file "module.rkt"
                               (hash-set arguments "file-name" collection-file)
                               "private"))
          (expand-test-module arguments)
          (expand-scribblings arguments)))))

(define (expand-module arguments)
  (expand-plank-file "module.rkt" arguments)
  (expand-test-module arguments)
  (expand-scribblings arguments))

(define (expand-test-module arguments)
  (expand-plank-file "test-module.rkt"
                     arguments
                     "tests"))

(define (expand-scribblings arguments)
  (expand-plank-file "scribble-top.scrbl"
                     (hash-set arguments "file-name" "scribblings.scrbl")
                     "scribblings")
  (expand-plank-file "scribble-module.scrbl"
                     (hash-set arguments
                               "file-name"
                               (format "~a.scrbl" (hash-ref arguments "content-name")))
                     "scribblings"))

(define (expand-a-plank arguments)
  (define file-name (find-plank-file (hash-ref arguments "content-name")))
  (if file-name
      (call-with-input-file* file-name
        (λ (in)
          (displayln (expand-string (port->string in) arguments blank-missing-value-handler))))
      (displayln (format "No content found for '~a'" (hash-ref arguments "content-name")))))

(define (list-planks)
  (for-each displayln (map
                       (λ (f) (string-replace (path->string f) #rx"\\.plank$" ""))
                       (append
                        (list-planks-in (collection-file-path "plank-files/" "scaffold"))
                        (list-planks-in (expand-user-path "~/planks"))))))

;; ---------- Internal procedures

(define (vdisplayln who str)
  (displayln (format "! ~a: ~a" (symbol->string who) str)))

(define (expand-plank-file file-name arguments [output-dir "."])
  (vdisplayln 'expand-plank-file (format "plank ~a" file-name))
  (vdisplayln 'expand-plank-file (format "output-dir ~a -> ~a" (current-directory) output-dir))
  (unless (directory-exists? output-dir)
    (make-directory output-dir))
  (define output-file (format "~a/~a"
                              output-dir
                              (or (hash-ref arguments "file-name" #f)
                                  (hash-ref arguments "content-name"))))
  (vdisplayln 'expand-plank-file (format "output-file ~a" output-file))
  (if (file-exists? output-file)
      (error (format "cannot overwrite existing file ~a" output-file))
      (expand-file (plank-file-path file-name)
                   output-file
                   arguments)))

(define (find-plank-file name)
  (let* ([file-name (format "~a.plank" name)]
         [plank-path (plank-file-path file-name)])
    (if (file-exists? plank-path)
        plank-path
        (let* ([local-file-name (format "~~/planks/~a" file-name)]
               [plank-path (expand-user-path local-file-name)])
          (displayln local-file-name)
          (displayln plank-path)
          (if (file-exists? plank-path)
              plank-path
              #f)))))

(define (list-planks-in dir)
  (if (directory-exists? dir)
      (filter (λ (p) (string-suffix? (path->string p) ".plank")) (directory-list dir))
      '()))

(define (plank-file-path name)
  (collection-file-path (format "plank-files/~a" name) "scaffold"))