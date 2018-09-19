#lang scribble/manual

@(require racket/sandbox
          scribble/core
          scribble/eval
          {{content-name}}
          (for-label racket/base
                     racket/contract
                     {{content-name}}))

@;{============================================================================}

@(define example-eval (make-base-eval
                      '(require racket/string
                                {{content-name}})))

@;{============================================================================}

@section[]{Module {{content-name}}.}
@defmodule[{{content-name}}]

{{content-description}}

@examples[ #:eval example-eval
(require {{content-name}})
; add more here.
]

@;{============================================================================}

@;Add your API documentation here...

{{#exports}}
Document {{name}} - TBD
{{/exports}}