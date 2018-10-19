#lang racket/base
;;
;; Scaffolding templated Racket files.
;;
;; ~ Simon Johnston 2018.
;;

;; ---------- Requirements

(require racket/cmdline
         racket/list
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
         scaffold/private/logging
         )

;; ---------- Internal parameters

(define argument-hash (plank-argument-defaults))

(define (set-argument name value)
  (hash-set! argument-hash name value))

(define (add-argument key-value)
  (define kv-list (string-split key-value "="))
  (when (= (length kv-list) 2)
    (hash-set! (hash-ref argument-hash "user-args") (first kv-list) (second kv-list))))

;; ---------- Implementation

(define (show-config [args argument-hash])
  (for ([key (sort (hash-keys args) string<?)])
    (displayln (format "  ~a: ~s" key (hash-ref args key)))
    (match key
      ["package-license"
       (displayln (format "    one of: ~a" (string-join license-types ", ")))]
      ["package-readme"
       (displayln (format "    one of: ~a" (string-join (hash-keys readme-types) ", ")))]
      [else (void)])))

(define (validate-arguments)
  (unless (member (string-downcase (hash-ref argument-hash "package-license"))
                  (map string-downcase license-types))
    (error (format "~a is not a valid license type" (hash-ref argument-hash "package-license"))))
  (unless (member (string-downcase (hash-ref argument-hash "package-readme"))
                  (map string-downcase (hash-keys readme-types)))
    (error (format "~a is not a valid readme type" (hash-ref argument-hash "package-readme")))))

(define (expand-content name)
  (with-logging-to-port
      (current-output-port)
    (λ ()
      (log-scaffold-debug "expand-content: log level set to ~a" (scaffold-log-level))
      (validate-arguments)
      (define content-type (current-svn-style-command))
      (set-argument "content-type" content-type)
      (set-argument "content-name" name)
      (log-scaffold-info "expand-content: expecting to expand ~a ~a" content-type name)
      (define fixed-args (make-immutable-hash (hash->list argument-hash)))
      (when (log-level? (current-logger) 'debug)
        (show-config fixed-args))
      (match content-type
        ["package"
         (expand-package (hash-set fixed-args "package-name" name))]
        ["collection"
         (expand-collection (hash-set* fixed-args
                                       "package-name" (or (find-package-name) "")
                                       "collection-name" name))]
        ["module"
         (expand-module (hash-set* fixed-args
                                   "package-name" (or (find-package-name) "")
                                   "module-name" name))]
        ["testmodule"
         (set-argument "package-name" (or (find-package-name) ""))
         (expand-test-module (hash-set* fixed-args
                                        "package-name" (or (find-package-name) "")))]
        ["scribble"
         (expand-scribblings (hash-set* fixed-args
                                        "package-name" (or (find-package-name) "")))]
        ["plank"
         (cond
           [(hash-ref fixed-args "list-planks" #f)
            (for-each displayln (list-planks))]
           [(> (length name) 0)
            (for ([plank-file name])
              (expand-a-plank (hash-set fixed-args "content-name" plank-file)))]
           [else (log-scaffold-warning "no plank names specified, nothing to do.")])]
        [else (log-scaffold-error "unexpected content type ~a" content-type)]))
    (scaffold-log-level)))

;; ---------- Internal procedures

(define (find-package-name)
  (log-scaffold-info "find-package-name: looking for a directory that holds a package...")
  (define go-back (current-directory))
  (define current-path (reverse (map path->string (explode-path go-back))))
  (define package-name (for/or ([dir-name current-path])
                         (if (file-exists? "info.rkt")
                             (let* ([info (get-info/full (current-directory))])
                               (if (and info (info 'pkg-desc (λ () #f)))
                                   (begin
                                     (log-scaffold-info
                                      "find-package-name: found info.rkt for package in dir ~a"
                                      dir-name)
                                     dir-name)
                                   (begin (current-directory "..") #f)))
                             (begin (current-directory "..") #f))))
  (current-directory go-back)
  (log-scaffold-info "find-package-name: found package named ~a" package-name)
  package-name)

(svn-style-command-line
 #:program (short-program+command-name)
 #:argv (current-command-line-arguments)
 "The Racket templated content generator."
     
 ["package" "create a new, complete, package."
            "\nCreate a Racket package in the current directory."
            #:once-each
            [("-d" "--description")
             value
             "Short description"
             (set-argument "content-description" value)]
            [("-V" "--version")
             value
             "Version string"
             (set-argument "package-version" value)]
            [("-l" "--license")
             value
             "License type to create"
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
            [("-c" "--collection") value "The alternate name of the collection."
                                 (set-argument "collection-name" value)]
            #:once-any
            [("--triple-collection") "Create separate lib, doc, test, collections in package"
                                     (set-argument "package-structure" "triple")]
            [("--single-collection") "Create as a single collection package"
                                     (set-argument "package-structure" "single")]
            #:once-each
            [("--single-scribble") "Create a single-page Scribble doc"
                                   (set-argument "scribble-structure" "()")]
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
                                (scaffold-log-level 'info)]
            [("--very-verbose") "Very verbose mode"
                                (scaffold-log-level 'debug)]
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
                                   (scaffold-log-level 'info)]
               [("--very-verbose") "Very verbose mode"
                                   (scaffold-log-level 'debug)]
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
                   (scaffold-log-level 'info)]
           [("--very-verbose") "Very verbose mode"
                   (scaffold-log-level 'debug)]
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
                                   (scaffold-log-level 'info)]
               [("--very-verbose") "Very verbose mode"
                                   (scaffold-log-level 'debug)]
               #:args (test-module-name)
               (expand-content test-module-name)]

 ["scribble" "create basic scribble documentation."
               "\nCreate a basic scribble layout for documentation."
               #:once-each
               [("-d" "--description") value "Short description"
                                       (set-argument "content-description" value)]
               #:once-each
               [("-i" "--introspect") value "Module name to document in scribble"
                                       (set-argument "scribble-this" value)]
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
                                   (scaffold-log-level 'info)]
               [("--very-verbose") "Very verbose mode"
                                   (scaffold-log-level 'debug)]
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
                   (scaffold-log-level 'info)]
           [("--very-verbose") "Very verbose mode"
                   (scaffold-log-level 'debug)]
           #:args plank-name
           (expand-content plank-name)]

 ["config" "show default configuration values."
           "\nShow all the defaults for command-line values."
           #:args () (show-config)])
