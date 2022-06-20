# Racket package {{package-name}}

[![GitHub release](https://img.shields.io/github/release/{{user-id}}/{{package-name}}.svg?style=flat-square)](https://github.com/{{user-id}}/{{package-name}}/releases)
{{#package-include-travis}}[![Travis Status](https://travis-ci.org/{{user-id}}/{{package-name}}.svg)](https://www.travis-ci.org/{{user-id}}/{{package-name}})
[![Coverage Status](https://coveralls.io/repos/github/{{user-id}}/{{package-name}}/badge.svg?branch=master)](https://coveralls.io/github/{{user-id}}/{{package-name}}?branch=master)
{{/package-include-travis}}[![raco pkg install {{package-name}}](https://img.shields.io/badge/raco%20pkg%20install-{{package-name}}-blue.svg)](http://pkgs.racket-lang.org/package/{{package-name}})
[![Documentation](https://img.shields.io/badge/raco%20docs-{{package-name}}-blue.svg)](http://docs.racket-lang.org/{{package-name}}/index.html)
[![GitHub stars](https://img.shields.io/github/stars/{{user-id}}/{{package-name}}.svg)](https://github.com/{{user-id}}/{{package-name}}/stargazers)
![{{package-license}} License](https://img.shields.io/badge/license-{{package-license}}-118811.svg)

{{package-description}}

## Modules

* `{{collection-name}}` - TBD.

## Example

```racket
(require {{collection-name}})

;; add example here
```


## Installation

* To install (from within the package directory): `raco pkg install`
* To install (once uploaded to [pkgs.racket-lang.org](https://pkgs.racket-lang.org/)): `raco pkg install {{package-name}}`
* To uninstall: `raco pkg remove {{package-name}}`
* To view documentation: `raco docs {{package-name}}`

## History

* **{{package-version}}** - Initial Version

[![Racket Language](https://raw.githubusercontent.com/johnstonskj/racket-scaffold/master/scaffold/plank-files/racket-lang.png)](https://racket-lang.org/)
