#lang scribble/manual

@(require racket/sandbox
          scribble/core
          scribble/eval
          scaffold/expand
          scaffold/planks
          (for-label racket/base
                     racket/contract
                     scaffold/expand
                     scaffold/planks
          scaffold/planks))

@;{============================================================================}

@(define example-eval (make-base-eval
                      '(require racket/string
                                scaffold/expand
                                scaffold/planks)))

@;{============================================================================}

@title[#:version "1.0"]{Package racket-scaffold}
@author[(author+email "Simon Johnston" "johnstonskj@gmail.com")]

This package primarily adds a new command to @racket[raco] to generate source
content. The tool, @italic{scaffold}, has a set of pre-defined complex templates
known as @italic{planks}. Planks can be as simple as a snippet of useful reusable
code, or as complex as a complete package structure (akin to the existing
'@racket[raco pkg new]' command).

@table-of-contents[]

@;{============================================================================}
@section[]{Using raco}

TBD

@subsection[]{Examples}

@verbatim|{
$ raco scaffold
Usage: raco scaffold <subcommand> [option ...] <arg ...>
  where any unambiguous prefix can be used for a subcommand

The Racket templated content generator.

For help on a particular subcommand, use 'raco scaffold <subcommand> --help'
  raco scaffold package       create a new, complete, package.
  raco scaffold collection    create a new collection.
  raco scaffold module        create a new module.
  raco scaffold testmodule    create a new rackunit test module.
  raco scaffold scribble      create basic scribble documentation.
  raco scaffold plank         expand a short code snippet.
  raco scaffold config        show default configuration values.
}|

@subsection[]{Pre-Defined Planks}

@itemlist[
  @item{package}
  @item{collection}
  @item{module}
  @item{test module}
  @item{scribble}
]

@subsection[]{Command-Line Flags}

@subsection[]{Adding Your Own Planks}

@;{============================================================================}

@;{============================================================================}
@section[]{Reference}

@subsection[]{Internal Arguments}

@tabular[#:style 'boxed
         #:sep @hspace[1]
         #:column-properties '(right-border right-border right-border ())
         #:row-properties '(bottom-border ())
         (list (list @bold{key} @bold{values} @bold{default} @bold{flags})
               (list @smaller{content-description} @smaller{@racket[string?]} "" @smaller{-d})
               (list @smaller{content-name} @racket[string?] "" "")
               (list @smaller{module-language} @smaller{?} @smaller{racket/base} @smaller{-L})
               (list @smaller{package-dir} @racket[path-string?] "" @smaller{?})
               (list @smaller{package-include-private} @racket[boolean?] @racket[#t] @smaller{--no-private})
               (list @smaller{package-include-travis} @racket[boolean?] @racket[#t] @smaller{--no-travis})
               (list @smaller{package-license} @smaller{Apache-2.0, BSD, GPL-3, LGPL-2.1, MIT} @smaller{MIT} @smaller{-l})
               (list @smaller{package-readme} @smaller{markdown, text} @smaller{markdown} @smaller{-r})
               (list @smaller{package-structure} @smaller{single, multi, triple} @smaller{multi} @smaller{--single-collection, --triple-collection})
               (list @smaller{package-version} @racket[string?] @smaller{0.1} @smaller{-V})
               (list @smaller{scribble-structure} @smaller{"", multi} @smaller{multi} @smaller{--single-scribble})
               (list @smaller{user-email} @racket[string?] "" @smaller{-e, -E})
               (list @smaller{user-id} @racket[string?] "" "")
               (list @smaller{user-name} @racket[string?] "" @smaller{-u, -U})
               (list @smaller{year} @racket[string?] "" ""))]

@subsection[]{Module scaffold/expand}
@defmodule[scaffold/expand]

TBD

@examples[ #:eval example-eval
(require scaffold/expand)
; add more here.
]

@defproc[(expand-file
          [source path-string?]
          [target path-string?]
          [arguments hash?]
          [missing-value-handler (-> string? string?) blank-missing-value-handler])
         void?]{}

@defproc[(expand-string
          [source string?]
          [arguments hash?]
          [missing-value-handler (-> string? string?) blank-missing-value-handler])
         string?]{}

@defproc[(blank-missing-value-handler
          [name string?])
         string?]{}

@subsection[]{Module scaffold/planks}
@defmodule[scaffold/planks]

TBD

@examples[ #:eval example-eval
(require scaffold/planks)
; add more here.
]

@defthing[readme-types (hash/c string? string?)]{}
   
@defthing[license-types (hash/c string? string?)]{}

@defthing[package-types (listof string?)]{}
  
@defproc[(expand-package
          [arguments hash?])
         void?]{}

@defproc[(expand-collection
          [arguments hash?])
         void?]{}

@defproc[(expand-module
          [arguments hash?])
         void?]{}

@defproc[(expand-test-module
          [arguments hash?])
         void?]{}
  
@defproc[(expand-scribblings
          [arguments hash?])
         void?]{}
  
@defproc[(expand-a-plank
          [arguments hash?])
         void?]{}
  
@defproc[(list-planks)
         void?]{}
