# Racket Scaffold templated content generator

This package extends the standard Racket `raco` command with the ability
to generate templated common content. While it can be used to replace the 
`raco pkg new` command, it can also be used to add content to existing 
packages.

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
