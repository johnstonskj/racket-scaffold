#lang racket/base
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

(require racket/contract)

(provide
 (contract-out

  [readme-types (hash/c string? string?)]
   
  [license-types (listof string?)]

  [package-types (listof string?)]
  
  [expand-package
   (-> hash? void?)]
  
  [expand-collection
   (->* (hash?) (boolean?) void?)]
  
  [expand-module
   (-> hash? void?)]
  
  [expand-test-module
   (-> hash? void?)]
  
  [expand-scribblings
   (-> hash? void?)]
  
  [expand-a-plank
   (-> hash? void?)]
  
  [list-planks
   (-> (listof string?))]
  
  [plank-argument-defaults
   (-> hash?)]))

;; ---------- Requirements

(require racket/date
         racket/function
         racket/list
         racket/match
         racket/path
         racket/port
         racket/string
         dali
         scaffold/introspect
         scaffold/private/system
         scaffold/private/logging)

;; ---------- Configuration

(define readme-types (hash "markdown" "md" "text" "txt"))

(define license-types '("Apache-2.0" "BSD" "GPL-3" "LGPL-2.1" "MIT"))

(define package-types '("single" "multi" "triple"))

(define test-dir-name "tests")

(define scribble-dir-name "scribblings")

;; ---------- Implementation

(define (expand-package arguments)
  (define form (hash-ref arguments "package-structure"))
  (define package-name (hash-ref arguments "package-name"))
  (define package-dir (string-or (hash-ref arguments "package-dir") package-name))
  (log-scaffold-info "expand-package: package ~a into ~a" package-name package-dir)
  
  (when
      (cond
        [(equal? package-dir "")
         (log-scaffold-error "package directory not provided")
         #f]
        [(directory-exists? package-dir)
         (log-scaffold-error "package directory already exists ~a" package-dir)
         #f]
        [else
         (make-directory package-dir)
         #t])
    (parameterize ([current-directory package-dir])
      (define collection-name (string-or (hash-ref arguments "collection-name")
                                         (hash-ref arguments "content-name")))
      (expand-plank-file "dot-gitignore"
                         (hash-set arguments "file-name" ".gitignore"))
      (let ([file-name (format "README.~a" (string-downcase
                                            (hash-ref readme-types
                                                      (hash-ref arguments "package-readme"))))]
            [heading-underline (make-string (string-length (hash-ref arguments "content-name")) #\=)])
        (expand-plank-file file-name
                           (hash-set* arguments
                                      "collection-name" collection-name
                                      "file-name" file-name
                                      "heading-underline" heading-underline)))
      (let ([plank-name (format "LICENSE-~a" (hash-ref arguments "package-license"))])
        (expand-plank-file plank-name
                           (hash-set arguments "file-name" "LICENSE")))
      ;; TODO: top-level info file!
      (when (equal? form "single")
         (expand-info "multi-package" arguments))
      (when (hash-ref arguments "package-include-travis")
        (let ([test-dir (if (equal? form "single")
                            (format "./~a" test-dir-name)
                            (format "~a/~a" collection-name test-dir-name))]
              [scribble-dir (if (equal? form "single")
                                (format "./~a" scribble-dir-name)
                                (format "~a/~a" collection-name scribble-dir-name))])
          (expand-plank-file "dot-travis.yml"
                             (hash-set* arguments
                                        "collection-name" collection-name
                                        "file-name" ".travis.yml"
                                        "test-dir" test-dir
                                        "scribble-dir" scribble-dir))
          (expand-plank-file "Makefile"
                             (hash-set* arguments
                                        "collection-name" collection-name
                                        "file-name" "Makefile"
                                        "test-dir" test-dir
                                        "scribble-dir" scribble-dir))))
      (expand-collection (hash-set arguments "collection-name" collection-name)
                         (equal? form "single")))))
  
(define (expand-info type arguments)
  (log-scaffold-info "expand-info: ~a" type)
  (expand-plank-file (format "info-~a.rkt" type)
                     (hash-set* arguments "file-name" "info.rkt")))


(define (expand-collection arguments [flat #f])
  (define collection (hash-ref arguments "collection-name"))
  (log-scaffold-info "expand-collection ~a" collection)
  (define (expander)
    (if flat
        (expand-info "single-package" arguments)
        (expand-info "collection" (hash-set arguments "content-name" collection)))
    (expand-module (hash-set arguments "content-name" collection))
    (expand-plank-file "test-doc-complete.rkt"
                          (hash-set arguments "file-name" "test-doc-complete.rkt")
                          test-dir-name))
  
  (cond
    [(and (not flat) (directory-exists? collection))
      (log-scaffold-error "cannot overwrite existing collection ~a" collection)]
    [(not flat)
     (make-directory collection)
     (parameterize ([current-directory collection])
       (expander))]
    [flat
     (expander)]
    [else (log-scaffold-error "invalid state in expand-collection")]))     


(define (expand-module arguments)
  (log-scaffold-info "expand-module")
  (cond
    [(hash-ref arguments "package-include-private")
     (define requires (format " \"private/~a.rkt\"" (hash-ref arguments "content-name")))
     (expand-plank-file "module.rkt" (hash-set* arguments
                                                "file-name" "main.rkt"
                                                "module-requires" requires))
     (expand-plank-file "module.rkt" (hash-set arguments "private-module" #t) "private")]
    [else
     (expand-plank-file "module.rkt" (hash-set arguments
                                               "file-name" "main.rkt"))])
  (expand-test-module (hash-set arguments "module-requires" "\"../main.rkt\""))
  (expand-scribblings arguments))


(define (expand-test-module arguments)
  (log-scaffold-info "expand-test-module")
  (expand-plank-file "test-module.rkt"
                     (hash-set arguments
                               "file-ext" "rkt")
                     test-dir-name))


(define (expand-scribblings arguments)
  (log-scaffold-info "expand-scribblings")
  (define top-doc-name
    (format "~a.scrbl"
            (cond
              [(non-empty-string? (hash-ref arguments "package-name" ""))
               (hash-ref arguments "package-name")]
              [(non-empty-string? (hash-ref arguments "collection-name" ""))
               (hash-ref arguments "collection-name")]
              [else
               (hash-ref arguments "content-name")])))
  (define content-doc-name
    (format "~a.scrbl"
            (cond
              [(equal? (hash-ref arguments "content-name") (first (string-split top-doc-name ".")))
               (format "_~a" (hash-ref arguments "content-name"))]
              [else
               (hash-ref arguments "content-name")])))
  ;; TODO: name for package
  (expand-plank-file "scribble-top.scrbl"
                     (hash-set* arguments
                                "file-name" top-doc-name
                                "content-doc-name" content-doc-name)
                     scribble-dir-name
                     #t)
  (define scribble-this (introspect-this arguments))
  ;; TODO: name for module
  (expand-plank-file "scribble-module.scrbl"
                     (hash-set arguments
                               "file-name" content-doc-name)
                     scribble-dir-name))


(define (expand-a-plank arguments)
  (define file-name (find-plank-file (hash-ref arguments "content-name")))
  (log-scaffold-info "expand-a-plank: ~s" file-name)
  (if file-name
      (call-with-input-file* file-name
        (λ (in)
          (displayln (expand-string (port->string in) arguments blank-missing-value-handler))))
      (log-scaffold-warning "No content found for '~a'" (hash-ref arguments "content-name"))))


(define (list-planks)
  (define package-path (collection-file-path "plank-files/" "scaffold"))
  (define local-path (expand-user-path "~/planks"))
  (log-scaffold-info "list-planks: package dir: ~a" (path->string package-path))
  (log-scaffold-info "list-planks: local dir: ~a" (path->string local-path))
  (map
   (λ (f) (string-replace (path->string f) #rx"\\.plank$" ""))
   (append
    (list-planks-in package-path)
    (list-planks-in local-path))))


(define (plank-argument-defaults)
  (make-hash (list (cons "collection-name" "")
                   (cons "content-name" "")
                   (cons "content-description" "")
                   (cons "module-language" "racket/base")
                   (cons "package-dir" "")
                   (cons "package-version" "0.1")
                   (cons "package-license" "MIT")
                   (cons "package-name" "")
                   (cons "package-readme" "markdown")
                   (cons "package-include-private" #t)
                   (cons "package-include-travis" #t)
                   (cons "package-structure" "multi")
                   (cons "scribble-structure" "(multi-page)")
                   (cons "user-id"
                         (find-user-id))
                   (cons "user-name"
                         (find-user-name))
                   (cons "user-email"
                         (system-value "git config --global user.email"))
                   (cons "user-args" (make-hash))
                   (cons "year"
                         (number->string (date-year (current-date)))))))

;; ---------- Internal procedures

(define (introspect-this arguments)
  (if (hash-has-key? arguments "scribble-this")
      (let ([mod (introspect-module (string->symbol (hash-ref arguments "scribble-this")))])
        (for/list ([export (module-info-exports mod)])
          (define content
            (cond
              [(export-info-procedure? export)
               (hash "form" "defproc")]
              [(string-prefix? (export-info-name export) "struct:")
               (hash "form" "defstruct")]
              [else
               (hash "form" "defthing")]
               ))
          (hash-set content "name" (export-info-name export))))
      '()))

(define (string-or . strings)
  (findf non-empty-string? strings))

(define (output-file-name input-file-name arguments)
  (or (hash-ref arguments "file-name" #f)
      (if (hash-ref arguments "file-ext" #f)
          (format "~a.~a"
                  (hash-ref arguments "content-name")
                  (hash-ref arguments "file-ext"))
           (if (path-get-extension input-file-name)
               (format "~a~a"
                       (hash-ref arguments "content-name")
                       (path-get-extension input-file-name))
               #f))
      (hash-ref arguments "content-name")))

(define (expand-plank-file file-name arguments [output-dir "."] [ignore-existing #f])
  (log-scaffold-info "expand-plank-file: plank ~a" file-name)
  (log-scaffold-debug "expand-plank-file: output-dir ~a -> ~a" (current-directory) output-dir)
  (unless (directory-exists? output-dir)
    (make-directory output-dir))
  (define output-file (format "~a/~a"
                              output-dir
                              (output-file-name file-name arguments)))
  (log-scaffold-info "expand-plank-file: output-file ~a" output-file)
  (if (file-exists? output-file)
      (unless ignore-existing (log-scaffold-error "cannot overwrite existing file ~a" output-file))
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
          (if (file-exists? plank-path)
              plank-path
              #f)))))

(define (list-planks-in dir)
  (if (directory-exists? dir)
      (filter (λ (p) (string-suffix? (path->string p) ".plank")) (directory-list dir))
      '()))

(define (plank-file-path name)
  (collection-file-path (format "plank-files/~a" name) "scaffold"))