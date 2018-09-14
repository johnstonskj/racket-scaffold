Racket package {{package-name}} {{package-version}}
==============={{heading-underline}}

{{package-description}}

Modules
-------

* `{{collection-name}}` - TBD.


Example
-------

> (require {{collection-name}})
> 
> ;; add example here


Installation
------------

To install (from within the package directory):
  $ raco pkg install

To install (once uploaded to pkgs.racket-lang.org):
  $ raco pkg install {{package-name}}

To uninstall:
  $ raco pkg remove {{package-name}}

To view documentation:
  $ raco docs {{package-name}}


History
-------

{{package-version}} - Initial version.


Links
-----

GitHub
  https://github.com/{{user-id}}/{{package-name}}/releases
{{#package-include-travis}}
Travis
  https://www.travis-ci.org/{{user-id}}/{{package-name}}{{/package-include-travis}}

Racket Package
  http://pkgs.racket-lang.org/package/{{package-name}}

Racket Docs
  http://docs.racket-lang.org/{{package-name}}/index.html
