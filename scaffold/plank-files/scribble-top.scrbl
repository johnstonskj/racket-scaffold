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

@title[#:version "1.0"]{Package {{content-name}}.}
@author[(author+email "{{user-name}}" "{{user-email}}")]

{{content-description}}

@table-of-contents[]

@include-section["{{content-name}}.scrbl"]
