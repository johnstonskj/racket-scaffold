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
@;{============================================================================}
@title[#:version "1.0"]{Package racket-scaffold}
@author[(author+email "Simon Johnston" "johnstonskj@gmail.com")]

This package primarily adds a new command to @tt{raco} to generate source
content. The tool, @italic{scaffold}, has a set of pre-defined complex templates
known as @italic{planks}. Planks can be as simple as a snippet of useful reusable
code, or as complex as a complete package structure (akin to the existing
'@tt{raco pkg new}' command).

@table-of-contents[]

@;{============================================================================}
@;{============================================================================}
@section[]{Using raco}

The primary purpose of this package is to add a templated content generator to the
@tt{raco} tool. As distributed the tool has a '@tt{pkg new}' option that generates
an idiomatic package structure. The @italic{scaffold} command seeks to extend the
existing package tool in three ways.

@itemlist[
  @item{It should provide options to generate multiple, legitimate, forms of major
    structures such as package and collections.}
  @item{It should provide a mechanism to add content to an existing package or
    collection.}
  @item{It should allow the user to create their own templates for commonly-used
    tasks.}
]

To this end scaffold defines content in the form of @italic{planks} that represent
templated content. A plank can be a snippet of code, a complete file, or a set
of files and directories such as a whole package.

@;{============================================================================}
@subsection[]{Example}

The following shows the top-level sub-command help.

@verbatim[#:indent 2]|{
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

The following shows the expansion of a snippet of code from a user-defined
plank file.

@verbatim[#:indent 2]|{
$ raco scaffold plank -l
test-exn

$ raco scaffold plank -k fixture=my-function -k exn=contract test-exn
(test-case
  "my-function: check for contract exception"
  (check-exn exn:fail:contract?
    (λ () (my-function))))
}|

@;{============================================================================}
@subsection[]{Planks}

@subsubsection[]{Create a Package}

Invoking the @tt{package} sub-command, as shown in the command-line below,

@verbatim[#:indent 2]|{
$ raco scaffold package -d "Some new package" -V "1.0" -l MIT -r markdown \
         -L "racket/base" -u "me" -e "me@example.com" my-name
}|

results in the @bold{Multi-Collection Package}  package structure shown
below (numbers indicate comments in the following list).

@verbatim[#:indent 2]|{
my-name/
|-- README.md              {1}
|-- LICENSE                {2}
|-- .travis.yml            {3}
|-- Makefile               {3}
|-- info.rkt
'-- my-name/
    |-- info.rkt
    |-- main.rkt
    |-- private/           {4}
    |   '-- my-name.rkt    {4}
    |-- test/
    |   '-- my-name.rkt
    '-- scribblings/
        '-- scribblings.scrbl {5}
        '-- my-name.scrbl  {5}
}|

@itemlist[#:style 'ordered
  @item{The file format for the README is set using the @tt{-r} argument
          with the default set to @tt{markdown}.}
  @item{The actual license included in the LICENSE file is set using
           the @tt{-l} argument with the default set to @tt{MIT}.}
  @item{These two files are used for running builds, specifically using
          the @hyperlink["https://www.travis-ci.org/"]{Travis} service.
          These can be excluded using the @tt{--no-travis} argument.}
  @item{This is a common style for keeping implementation files separate
        from the interface ones, here it is used as the default layout.
        These can be excluded using the @tt{--no-private} argument.}
  @item{By default scribble files are configured in the collection's
        @tt{info.rkt} to use the @tt{multi-page} option (see
        @secref["Multi-Page_Sections"
                #:doc '(lib "scribblings/scribble/scribble.scrbl")]).
        This can be changed to a single-page using the
        @tt{--single-scribble} argument.}
]

Additionally, scribble files are setup with a top-level file (named
@tt{scribblings.scrbl})) that uses @tt|{@include-section}| to include
each module scribble separately. This has the advantage of smaller
files to edit, and more fine-grained version control.

@bold{Single Collection Package}. Adding the @tt{--single-collection}
argument will create a structure more like the @tt{pkg new} command
where the collection and package are one and the same.

@verbatim[#:indent 2]|{
my-name/
|-- README                 {1}
|-- LICENSE                {2}
|-- .travis.yml            {3}
|-- Makefile               {3}
|-- info.rkt
|-- main.rkt
|-- private/               {4}
|   '-- my-name.rkt        {4}
|-- test/
|   '-- my-name.rkt
'-- scribblings/
    '-- scribblings.scrbl  {5}
    '-- my-name.scrbl      {5}
}|

@bold{Triple Collection Package}. Alternatively, adding the
@tt{--triple-collection} argument will create a package structure with
three collections, a @tt{-lib} for the library itself, a @tt{-doc} for
the scribble documentation, and a @tt{-test} for all test code.

@verbatim[#:indent 2]|{
my-name/
|-- README                 {1}
|-- LICENSE                {2}
|-- .travis.yml            {3}
|-- Makefile               {3}
|-- info.rkt
|-- my-name-lib/
|   |-- info.rkt
|   |-- main.rkt
|   '-- private/           {4}
|       '-- my-name.rkt    {4}
|-- my-name-test/
|   |-- info.rkt
|   '-- my-name.rkt
|-- my-name-doc
    |-- info.rkt
    |-- scribblings.scrbl  {5}
    '-- my-name.scrbl      {5}
}|

@subsubsection[]{Create a Collection}

@verbatim[#:indent 2]|{
my-name/
|-- info.rkt
|-- main.rkt
|-- private/
|   '-- my-name.rkt
|-- test/
|   '-- my-name.rkt
'-- scribblings/
    '-- scribblings.scrbl
    '-- my-name.scrbl
}|

@subsubsection[]{Create a Module}

@verbatim[#:indent 2]|{
my-name.rkt
test/
'-- my-name.rkt
scribblings/
'-- my-name.scrbl
}|

@subsubsection[]{Create a Test Module}

@verbatim[#:indent 2]|{
test/
'-- my-name.rkt
}|

@subsubsection[]{Create a Scribble}

@verbatim[#:indent 2]|{
scribblings/
'-- my-name.scrbl
}|

@;{============================================================================}
@subsection[]{Command-Line Flags}

The following summarizes all of the command-line flags and the sub-commands
that make use of them.

@tabular[#:style 'boxed
         #:sep @hspace[1]
;         #:column-properties '(right-border right-border right-border ())
         #:row-properties '(bottom-border ())
         (list (list @bold{short} @bold{long} @bold{package} @bold{collection}
                     @bold{module} @bold{test} @bold{scribble} @bold{plank})
               (list @tt{d} @tt{description} "Y" "Y" "Y" "Y" "Y" "Y")
               (list @tt{u} @tt{user} "Y" "Y" "Y" "Y" "Y" "")
               (list @tt{U} @tt{github-user} "Y" "Y" "Y" "Y" "Y" "")
               (list @tt{e} @tt{email} "Y" "Y" "Y" "Y" "Y" "")
               (list @tt{E} @tt{github-email} "Y" "Y" "Y" "Y" "Y" "")
               (list @tt{v} @tt{verbose} "Y" "Y" "Y" "Y" "Y" "Y")
               (list @tt{} @tt{very-verbose} "Y" "Y" "Y" "Y" "Y" "Y")
               (list @tt{L} @tt{language} "Y" "Y" "Y" "Y" "" "")
               (list @tt{l} @tt{license} "Y" "" "" "" "" "")
               (list @tt{r} @tt{readme} "Y" "" "" "" "" "")
               (list @tt{} @tt{no-private} "Y" "Y" "" "" "" "")
               (list @tt{} @tt{no-travis} "Y" "" "" "" "" "")
               (list @tt{o} @tt{output-dir} "Y" "" "" "" "" "")
               (list @tt{} @tt{single-collection} "Y" "" "" "" "" "")
               (list @tt{} @tt{triple-collection} "Y" "" "" "" "" "")
               (list @tt{} @tt{single-scribble} "Y" "" "" "" "" "")
               (list @tt{V} @tt{version} "Y" "" "" "" "" "")
               (list @tt{} @tt{key-value} "" "" "" "" "" "Y")
               (list @tt{l} @tt{list} "" "" "" "" "" "Y")
               )]

@;{============================================================================}
@subsection[]{Adding Your Own Planks}

See @secref["Module_scaffold_expand"
         #:doc '(lib "scaffold/scribblings/scaffold.scrbl")] for a full
description of the supported template syntax.

@;{============================================================================}
@;{============================================================================}
@section[]{Reference}

@;{============================================================================}
@subsection[]{Module scaffold/expand}
@defmodule[scaffold/expand]

This module implements the core of the template engine, by implementing a subset of the
languages defined by @hyperlink["https://mustache.github.io/"]{Moustache} and
@hyperlink["https://handlebarsjs.com/"]{Handlebars}. Specifically, the following
describes the language.

@itemlist[
  @item{keys are specified between @tt{@"{{"} and @tt{@"}}"}.}
  @item{keys specified between @tt{@"{{{"} and @tt{@"}}}"}, or with the prefix character @tt{&}, will
    HTML-escape their content.}
  @item{keys with a @tt{!} prefix character are treated as comments and ignored.}
  @item{keys may be nested, i.e. @tt{name.name}.}
  @item{conditionals (starting with either @tt{#} or @tt{^} and closing with @tt{/}) are supported.}
  @item{relative context specfication (use of @tt{./} or @tt{../} etc) is unsupported.}
  @item{partials, prefix character @tt{>}, are unsupported.}
  @item{setting new delimiter characters, between @tt{=} and @tt{=}, is unsupported.}
  @item{a key name "@tt{_}" is reserved to simply return a display form of the current context.}
]

@examples[ #:eval example-eval
(require scaffold/expand)
(define template "a list: {{#items}} {{item}}, {{/items}}and that's all")
(define context (hash "items" (list (hash "item" "one")
                                    (hash "item" "two")
                                    (hash "item" "three"))))
(expand-string template context)
(expand-string
 "a list: {{#items}} {{_}}, {{/items}}and that's all"
 (hash "items" '(a b c)))
]

The last example shows the use of the "@tt{_}" extension that allows for the printing of
values as-is rather than having to always use nested hashes.

@defproc[(expand-file
          [source path-string?]
          [target path-string?]
          [context hash?]
          [missing-value-handler (-> string? string?) blank-missing-value-handler])
         void?]{
This function will read the file @racket[source], process with @racket[expand-string],
and write the result to the file @racket[target]. It will raise an error if
the target file already exists.
}

@defproc[(expand-string
          [source string?]
          [context hash?]
          [missing-value-handler (-> string? string?) blank-missing-value-handler])
         string?]{
This function will treat @racket[source] as a template, evaluate it with the provided
context and return the result as a string.

A context is actually defined recursively as @racket[(hash/c string? (or/c string? list? hash?))]
so that the top level is a hash with string keys and values which are either lists
or hashes with the same contract.

The @racket[missing-value-handler] is a function that will be called when the key
in a template is not found in the context, it is provided the key content and
any value it returns is used as the replacement text.}

@defproc[(blank-missing-value-handler
          [name string?])
         string?]{
This is the default missing-value-handler function, it simply returns a blank
string for any missing template key.}

@;{============================================================================}
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
         (listof string?)]{}

@subsection[]{Internal Arguments}

The following table lists the arguments passed into the functions in
@secref["Module_scaffold_planks"
         #:doc '(lib "scaffold/scribblings/scaffold.scrbl")].

@tabular[#:style 'boxed
         #:sep @hspace[1]
         #:column-properties '(right-border right-border right-border ())
         #:row-properties '(bottom-border ())
         (list (list @bold{key} @bold{values} @bold{default} @bold{flags})
               (list @smaller{content-description} @smaller{@racket[string?]} ""
                     @smaller{-d})
               (list @smaller{content-name} @racket[string?] "" "")
               (list @smaller{module-language} @smaller{?} @smaller{racket/base}
                     @smaller{-L})
               (list @smaller{package-dir} @racket[path-string?] ""
                     @smaller{?})
               (list @smaller{package-include-private} @racket[boolean?] @racket[#t]
                     @smaller{--no-private})
               (list @smaller{package-include-travis} @racket[boolean?] @racket[#t]
                     @smaller{--no-travis})
               (list @smaller{package-license} @smaller{Apache-2.0, BSD, GPL-3, LGPL-2.1, MIT}
                     @smaller{MIT} @smaller{-l})
               (list @smaller{package-readme} @smaller{markdown, text} @smaller{markdown}
                     @smaller{-r})
               (list @smaller{package-structure} @smaller{single, multi, triple} @smaller{multi}
                     @smaller{--single-collection, --triple-collection})
               (list @smaller{package-version} @racket[string?] @smaller{0.1}
                     @smaller{-V})
               (list @smaller{scribble-structure} @smaller{"'()", multi-page} @smaller{multi-page}
                     @smaller{--single-scribble})
               (list @smaller{user-args} @smaller{key=value} ""
                     @smaller{-k})
               (list @smaller{user-email} @racket[string?] ""
                     @smaller{-e, -E})
               (list @smaller{user-id} @racket[string?] "" "")
               (list @smaller{user-name} @racket[string?] ""
                     @smaller{-u, -U})
               (list @smaller{year} @racket[string?] "" ""))]
