#lang scribble/manual

@title{Guards}
@defmodule[rebellion/guard]

A @deftech{guard} is a partial function that enforces some property on the
values its applied to. Guards can be seen as primitive building blocks for
constructing @tech{contracts} and @tech{contract combinators}.

@defproc[(guard? [v any/c]) boolean?]{
 A @tech{predicate} for @tech{guards}.}

@defproc[(make-guard [wrapper-proc (-> any/c any/c)]) guard?]{
 Constructs a @tech{guard} that implements @racket[guard-wrap] with @racket[
 wrapper-proc].}

@defproc[(guard-wrap [grd guard?] [v any/c]) any/c]{
 Wraps @racket[v] with @racket[grd] in order to enforce the invariants of
 @racket[grd].}

@defproc[(guard-pipe [grd guard?] ...) guard?]{
 Combines each @racket[grd] into a single @tech{guard} 