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

TBD

@table-of-contents[]

@;{============================================================================}
@section[]{Using raco}

TBD

@subsection[]{Pre-Defined Planks}

@subsection[]{Command-Line Flags}

@subsection[]{Adding Your Own Planks}

@;{============================================================================}

@;{============================================================================}
@section[]{Reference}

@subsection[]{Internal Arguments}

@subsection[]{Module scaffold/expand}
@defmodule[scaffold/expand]

TBD

@examples[ #:eval example-eval
(require scaffold/expand)
; add more here.
]

@subsection[]{Module scaffold/planks}
@defmodule[scaffold/planks]

TBD

@examples[ #:eval example-eval
(require scaffold/planks)
; add more here.
]
