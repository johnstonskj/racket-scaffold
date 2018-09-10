# Racket package {{content-name}}

[![GitHub release](https://img.shields.io/github/release/{{user-id}}/{{content-name}}.svg?style=flat-square)](https://github.com/{{user-id}}/{{content-name}}/releases)
{{#package-include-travis}}[![Travis Status](https://travis-ci.org/{{user-id}}/{{content-name}}.svg)](https://www.travis-ci.org/{{user-id}}/{{content-name}})
[![Coverage Status](https://coveralls.io/repos/github/{{user-id}}/{{content-name}}/badge.svg?branch=master)](https://coveralls.io/github/{{user-id}}/{{content-name}}?branch=master)
{{/package-include-travis}}[![raco pkg install {{content-name}}](https://img.shields.io/badge/raco%20pkg%20install-rml--core-blue.svg)](http://pkgs.racket-lang.org/package/{{content-name}})
[![Documentation](https://img.shields.io/badge/raco%20docs-rml--core-blue.svg)](http://docs.racket-lang.org/{{content-name}}/index.html)
[![GitHub stars](https://img.shields.io/github/stars/{{user-id}}/{{content-name}}.svg)](https://github.com/{{user-id}}/{{content-name}}/stargazers)
![{{package-license}} License](https://img.shields.io/badge/license-{{package-license}}-118811.svg)

{{content-description}}

## Modules

* `{{content-name}}` - TBD.

## Example

```scheme
(require {{content-name}})

;; add example here
```


## Installation

* To install (from within the package directory): `raco pkg install`
* To install (once uploaded to pkgs.racket-lang.org): `raco pkg install {{content-name}}`
* To uninstall: `raco pkg remove {{content-name}}`
* To view documentation: `raco docs {{content-name}}`

## History

* **{{package-version}}** - Initial Version

[![Racket Language](https://racket-lang.org/logo-and-text-1-2.png)](https://racket-lang.org/)
