# Racket Scaffold templated content generator

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
