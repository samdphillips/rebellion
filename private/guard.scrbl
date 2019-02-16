#lang scribble/manual

@title{Guards}
@defmodule[rebellion/guard]

A @deftech{guard} is a partial function that enforces some property on values,
either by immediately raising an error or by wrapping the value with a chaperone
or impersonator. Guards are useful as primitive building blocks for creating
contract combinators.

@defthing[guard? predicate?]{
 A predicate for @tech{guards}.}

@defproc[(make-guard [proc (-> any/c any/c)] [#:name name name? unknown-name])
         guard?]{
 Constructs a @tech{guard} named @racket[name] that wraps values using @racket[
 proc].}

@defproc[(guard-apply [grd guard?] [v (guard-domain grd)]) (guard-domain grd)]{
 Wraps @racket[v] with @racket[grd] to enforce whatever properties @racket[grd]
 is interested in asserting.}

@defproc[(guard-name [grd guard?]) name?]{
 Returns @racket[grd]'s name.}

@defproc[(guard/c [domain contract?]) contract?]{
 A contract combinator for @tech{guards} that can only be applied to values
 satisfying @racket[domain]. The domain contract of a guard wrapped with a
 @racket[guard/c] contract can be accessed with @racket[guard-domain].}

@defproc[(guard-domain [grd guard?]) contract?]{
 Returns the domain contract of @racket[grd], or @racket[any/c] if @racket[grd]
 has no @racket[guard/c] contract.}
