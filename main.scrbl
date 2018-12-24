#lang scribble/manual
@(require (for-label rebellion))

@title{Rebellion}
@defmodule[rebellion]

Rebellion is a set of infrastructure libraries for Racketeers to build new
languages, new frameworks, and new tools with.

@section{Predicates}
@defmodule[rebellion/predicate/base]

A @deftech{predicate} is a boolean-returning function of one argument.
Predicates are commonly used to represent data types, but this is not their only
use. Predicates can have contracts attached to their domain using @racket[
 predicate/c]. Additionally, any predicate is automatically both a @tech{flat
 contract} and a function of one argument.

@defthing[predicate? predicate?]{
 A @tech{predicate} satisfied by all predicate values, including itself.}

@defproc[(make-predicate [proc (-> any/c boolean?)]
                         [#:name name name? unknown-name])
         predicate?]{
 Constructs a @tech{predicate} named @racket[name] and implemented with @racket[
 proc].}

@defproc[(predicate/c [domain contract?]) contract?]{
                                                     