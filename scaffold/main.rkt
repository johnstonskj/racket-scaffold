#lang racket/base
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

;; ---------- Requirements

(require racket/cmdline
         racket/date
         racket/list
         racket/logging
         racket/match
         racket/port
         racket/string
         racket/system
         raco/command-name
         setup/getinfo
         ; Yes, the following is brittle, and bad.
         planet/private/command
         ; Here is the internal API
         scaffold/planks
         scaffold/system)

;; ---------- Internal parameters

(define argument-hash
  (make-hash (list (cons "content-name" "")
                   (cons "content-description" "")
                   (cons "module-language" "racket/base")
                   (cons "package-dir" "")
                   (cons "package-version" "0.1")
                   (cons "package-license" "MIT")
                   (cons "package-readme" "markdown")
                   (cons "package-include-private" #t)
                   (cons "package-include-travis" #t)
                   (cons "package-structure" "multi")
                   (cons "scribble-structure" "multi")
                   (cons "user-id"
                         (find-user-id))
                   (cons "user-name"
                         (find-user-name))
                   (cons "user-email"
                         (system-value "git config --global user.email"))
                   (cons "user-keys" (make-hash))
                   (cons "year"
                         (number->string (date-year (current-date)))))))

(define (set-argument name value)
  (hash-set! argument-hash name value))

(define (add-argument key-value)
  (define kv-list (string-split key-value "="))
  (when (= (length kv-list) 2)
    (hash-set! (hash-ref argument-hash "user-keys") (first kv-list) (second kv-list))))

;; ---------- Implementation

(define (show-config)
  (for ([key (sort (hash-keys argument-hash) string<?)])
    (displayln (format "  ~a: ~s" key (hash-ref argument-hash key)))
    (match key
      ["package-license"
       (displayln (format "    one of: ~a" (string-join license-types ", ")))]
      ["package-readme"
       (displayln (format "    one of: ~a" (string-join (hash-keys readme-types) ", ")))]
      [else (void)])))

(define (validate-arguments)
  (unless (member (string-downcase (hash-ref argument-hash "package-license"))
                  '("apache" "gplv3" "mit"))
    (error "not a valid license type"))
  (unless (member (string-downcase (hash-ref argument-hash "package-readme"))
                  '("markdown" "text"))
    (error "not a valid readme type")))

(define (expand-content name)
  (with-logging-to-port
      (current-output-port)
    (λ ()
      (when (log-level? (current-logger) 'debug)
        (show-config))
      (log-debug "expand-content: log level set to ~a" (tool-log-level))
      (validate-arguments)
      (define content-type (current-svn-style-command))
      (set-argument "content-type" content-type)
      (unless (equal? (current-svn-style-command) "package")
        (set-argument "parent-package-name" (or (find-package-name) "")))
      (set-argument "content-name" name)
      (log-info "expand-content: expecting to expand ~a ~a" content-type name)
      (define fixed-args (make-immutable-hash (hash->list argument-hash)))
      (match content-type
        ["package" (expand-package fixed-args)]
        ["collection" (expand-collection fixed-args)]
        ["module" (expand-module fixed-args)]
        ["testmodule" (expand-test-module fixed-args)]
        ["scribble" (expand-scribblings fixed-args)]
        ["plank"
         (cond
           [(hash-ref fixed-args "list-planks" #f)
            (for-each displayln (list-planks))]
           [(> (length name) 0)
            (for ([plank-file name])
              (expand-a-plank (hash-set fixed-args "content-name" plank-file)))]
           [else (log-warning "no plank names specified, nothing to do.")])]
        [else (log-error "unexpected content type ~a" content-type)]))
    (tool-log-level)))

;; ---------- Internal procedures

(define tool-log-level (make-parameter 'warning))

(define (find-package-name)
  (log-info "find-package-name: looking for a directory that holds a package...")
  (define go-back (current-directory))
  (define current-path (reverse (map path->string (explode-path go-back))))
  (define package-name (for/or ([dir-name current-path])
                         (if (file-exists? "info.rkt")
                             (let* ([info (get-info/full (current-directory))])
                               (if (and info (info 'pkg-desc (λ () #f)))
                                   (begin
                                     (log-info
                                      "find-package-name: found info.rkt for package in dir ~a"
                                      dir-name)
                                     dir-name)
                                   (begin (current-directory "..") #f)))
                             (begin (current-directory "..") #f))))
  (current-directory go-back)
  (log-info "find-package-name: found package named ~a" package-name)
  package-name)

(svn-style-command-line
 #:program (short-program+command-name)
 #:argv (current-command-line-arguments)
 "The Racket templated content generator."
     
 ["package" "create a new, complete, package."
            "\nCreate a Racket package in the current directory."
            #:once-each
            [("-d" "--description") value "Short description"
                                    (set-argument "content-description" value)]
            [("-V" "--version") value "Version string"
                                (set-argument "package-version" value)]
            [("-l" "--license") value "License type to create"
                                (set-argument "package-license" value)]
            [("-r" "--readme") value "Read-me file type to create"
                               (set-argument "package-readme" value)]

            [("--no-private") "Do not generate a private source folder"
                              (set-argument "package-include-private" #f)]
            [("--no-travis") "Do not generate Travis CI files"
                             (set-argument "package-include-travis" #f)]
            [("-L" "--language") value "The Racket language name to be used for new modules"
                                 (set-argument "module-language" value)]
            [("-o" "--output-dir") value "The alternate directory to create the package in."
                                 (set-argument "package-dir" value)]
            #:once-any
            [("--triple-collection") "Create separate lib, doc, test, collections in package"
                                     (set-argument "package-structure" "triple")]
            [("--single-collection") "Create as a single collection package"
                                     (set-argument "package-structure" "single")]
            #:once-each
            [("--single-scribble") "Create a single-page Scribble doc"
                                   (set-argument "scribble-structure" "single")]
            #:once-any
            [("-u" "--user") user "User name"
                             (set-argument "user-id" user)]
            [("-U" "--github-user") user "Github user name"
                                    (set-argument "user-id" user)]
            #:once-any
            [("-e" "--email") email "User email"
                              (set-argument "user-email" email)]
            [("-E" "--github-email") email "Github email"
                                     (set-argument "user-email" email)]
            #:once-each
            [("-v" "--verbose") "Verbose mode"
                                (tool-log-level 'info)]
            [("--very-verbose") "Very verbose mode"
                                (tool-log-level 'debug)]
            #:args (package-name)
            (expand-content package-name)]
     
 ["collection" "create a new collection."
               "\nCreate a Racket collection in the current package."
               #:once-each
               [("-d" "--description") value "Short description"
                                       (set-argument "content-description" value)]
               [("--no-private") "Do not generate a private source folder"
                                 (set-argument "package-include-private" #f)]
               [("-L" "--language") value "The Racket language name to be used for new modules"
                                    (set-argument "module-language" value)]
               #:once-any
               [("-u" "--user") user "User name"
                                (set-argument "user-id" user)]
               [("-U" "--github-user") user "Github user name"
                                       (set-argument "user-id" user)]
               #:once-any
               [("-e" "--email") email "User email"
                                 (set-argument "user-email" email)]
               [("-E" "--github-email") email "Github email"
                                        (set-argument "user-email" email)]
               #:once-each
               [("-v" "--verbose") "Verbose mode"
                                   (tool-log-level 'info)]
               [("--very-verbose") "Very verbose mode"
                                   (tool-log-level 'debug)]
               #:args (collection-name)
               (expand-content collection-name)]
     
 ["module" "create a new module."
           "\nCreate a Racket module in the current package."
           #:once-each
           [("-d" "--description") value "Short description"
                                   (set-argument "content-description" value)]
           [("-L" "--language") value "The Racket language name to be used for new modules"
                                (set-argument "module-language" value)]
           #:once-any
           [("-u" "--user") user "User name"
                            (set-argument "user-id" user)]
           [("-U" "--github-user") user "Github user name"
                                   (set-argument "user-id" user)]
           #:once-any
           [("-e" "--email") email "User email"
                             (set-argument "user-email" email)]
           [("-E" "--github-email") email "Github email"
                                    (set-argument "user-email" email)]
           #:once-each
           [("-v" "--verbose") "Verbose mode"
                   (tool-log-level 'info)]
           [("--very-verbose") "Very verbose mode"
                   (tool-log-level 'debug)]
           #:args (module-name)
           (expand-content module-name)]
     
 ["testmodule" "create a new rackunit test module."
               "\nCreate a Racket module configured for rackunit, in the current package."
               #:once-each
               [("-d" "--description") value "Short description"
                                       (set-argument "content-description" value)]
               [("-L" "--language") value "The Racket language name to be used for new modules"
                                    (set-argument "module-language" value)]
               #:once-any
               [("-u" "--user") user "User name"
                                (set-argument "user-id" user)]
               [("-U" "--github-user") user "Github user name"
                                       (set-argument "user-id" user)]
               #:once-any
               [("-e" "--email") email "User email"
                                 (set-argument "user-email" email)]
               [("-E" "--github-email") email "Github email"
                                        (set-argument "user-email" email)]
               #:once-each
               [("-v" "--verbose") "Verbose mode"
                                   (tool-log-level 'info)]
               [("--very-verbose") "Very verbose mode"
                                   (tool-log-level 'debug)]
               #:args (test-module-name)
               (expand-content test-module-name)]

 ["scribble" "create basic scribble documentation."
               "\nCreate a basic scribble layout for documentation."
               #:once-each
               [("-d" "--description") value "Short description"
                                       (set-argument "content-description" value)]
               #:once-any
               [("-u" "--user") user "User name"
                                (set-argument "user-id" user)]
               [("-U" "--github-user") user "Github user name"
                                       (set-argument "user-id" user)]
               #:once-any
               [("-e" "--email") email "User email"
                                 (set-argument "user-email" email)]
               [("-E" "--github-email") email "Github email"
                                        (set-argument "user-email" email)]
               #:once-each
               [("-v" "--verbose") "Verbose mode"
                                   (tool-log-level 'info)]
               [("--very-verbose") "Very verbose mode"
                                   (tool-log-level 'debug)]
               #:args (module-name)
               (expand-content module-name)]

 ["plank" "expand a short code snippet."
           "\nFind a snippet, expand variables, and display to standard-out."
           #:once-each
           [("-l" "--list") "List all known planks."
                            (set-argument "list-planks" #t)]
           #:multi
           [("-k" "--key=value") key-value "Add a user-defined key/value argument"
                                 (add-argument key-value)]
           #:once-each
           [("-v" "--verbose") "Verbose mode"
                   (tool-log-level 'info)]
           [("--very-verbose") "Very verbose mode"
                   (tool-log-level 'debug)]
           #:args plank-name
           (expand-content plank-name)]

 ["config" "show default configuration values."
           "\nShow all the defaults for command-line values."
           #:args () (show-config)])
