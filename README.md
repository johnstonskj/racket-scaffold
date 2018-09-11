# Racket Scaffold templated content generator

[![GitHub release](https://img.shields.io/github/release/johnstonskj/racket-scaffold.svg?style=flat-square)](https://github.com/johnstonskj/racket-scaffold/releases)
[![Travis Status](https://travis-ci.org/johnstonskj/racket-scaffold.svg)](https://www.travis-ci.org/johnstonskj/racket-scaffold)
[![Coverage Status](https://coveralls.io/repos/github/johnstonskj/racket-scaffold/badge.svg?branch=master)](https://coveralls.io/github/johnstonskj/racket-scaffold?branch=master)
[![raco pkg install racket-scaffold](https://img.shields.io/badge/raco%20pkg%20install-racket--scaffold-blue.svg)](http://pkgs.racket-lang.org/package/racket-scaffold)
[![Documentation](https://img.shields.io/badge/raco%20docs-racket--scaffold-blue.svg)](http://docs.racket-lang.org/racket-scaffold/index.html)
[![GitHub stars](https://img.shields.io/github/stars/johnstonskj/racket-scaffold.svg)](https://github.com/johnstonskj/racket-scaffold/stargazers)
![MIT License](https://img.shields.io/badge/license-MIT-118811.svg)

This package primarily adds a new command to `raco` to generate source
content. The tool, *scaffold*, has a set of pre-defined complex templates
known as *planks*. Planks can be as simple as a snippet of useful reusable
code, or as complex as a complete package structure (akin to the existing
`raco pkg new` command).


## Examples

```bash
$ raco scaffold
Usage: raco scaffold <subcommand> [option ...] <arg ...>
  where any unambiguous prefix can be used for a subcommand

The Racket templated content generator.

For help on a particular subcommand, use 'raco scaffold <subcommand> --help'
  raco scaffold package       create a new, complete, package.
  raco scaffold collection    create a new collection.
  raco scaffold module        create a new module.
  raco scaffold testmodule    create a new rackunit test module.
  raco scaffold plank         expand a short code snippet.
  raco scaffold config        show default configuration values.
```

Running the following command line will create a complete package.

```bash
$ raco scaffold package -d "Some new package" -V "1.0" -l MIT -r markdown \
         -L "racket/base" -u "me" -e "me@example.com" my-name
```

The generated package has the following structure:

```
my-name/
|-- README.md 
|-- LICENSE
|-- .travis.yml
|-- Makefile
|-- info.rkt
'-- my-name/
    |-- info.rkt
    |-- main.rkt
    |-- private/
    |   '-- my-name.rkt
    |-- test/
    |   '-- my-name.rkt
    '-- scribblings/
        '-- scribblings.scrbl
        '-- my-name.scrbl
```

## History

* **1.0** - Initial Version

[![Racket Language](https://racket-lang.org/logo-and-text-1-2.png)](https://racket-lang.org/)
