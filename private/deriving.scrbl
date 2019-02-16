#lang scribble/manual
@(require (for-label rebellion/deriving))

@title{Deriving Programs}
@defmodule[rebellion/deriving]

This module provides an extensible, macro-driven @tech{derivation framework} for
Racket. For more details about the framework, see @secref{framework}. Otherwise,
continue with @secref{overview} which describes derivation frameworks in
general.

@section[#:tag "overview"]{Derivation Overview}

In program design, @deftech{derivation} is a technique whereby some objects are
defined automatically, or @deftech{derived}, as a result of defining some other
object, called the @deftech{source object}. A @deftech{derivation-rule}
encapsulates a means to derive certain objects from each other, allowing the
same derivation logic to be reused with many source objects. Derivation requires
a @deftech{derivation framework}, which offers a logical system of derivation
rules and specifies how those rules can be used to derive objects.

Programmers derive objects by providing rules and an initial set of objects,
called the @deftech{axiom objects}, to the derivation framework. The framework
returns a @deftech{deriver} which encapsulates the set of all objects derivable
from the given axioms and rules, called the @deftech{derivation graph}. The
derivation graph may be represented implicitly by the deriver. Derivers can be
instructed to explicitly define derivable objects or sets of objects in a
process called @deftech{materialization}, but some sets of derivable objects may
not be materializable. The details of what can or can't be materialized by a
deriver depends on the specific derivation framework used.

@section{Derivation vs Dependency Injection}

Derivation is one type of @tech{inversion of control}, and has some similarities
with @tech{dependency injection}. However, derivation has some key differences:

@itemlist[
 @item{Definition-time --- Dependency injection frameworks @emph{construct}
  objects using dependency objects, whereas derivation frameworks @emph{define}
  objects using dependency object definitions. In practice, "object definition"
  usually means "source code" and derivation frameworks generate APIs using some
  amount of compile-time metaprogramming. In contrast, dependency injection
  frameworks usually operate directly on objects while the program is running,
  and change nothing about the interfaces of those objects.}

 @item{Provenance --- There can be only one definition of an object, so
  derivation frameworks must not allow @deftech{ambiguous derivation rules} that
  attempt to give the same object two different definitions. This is similar to
  the logical principle that it does not matter @emph{how} a theorem is proved,
  only that the proof used is correct. Dependency injection frameworks do not
  have this restriction and freely admit satisfying the same dependency with
  multiple different objects in different ways and at different times.}

 @item{Push vs pull --- Derivation frameworks ask programmers to specify a set
  of initial root depedency objects and leave the set of client objects
  implicit, as the framework "pushes out" in all directions deriving the
  clients. Dependency injection frameworks ask programmers to specify the
  immediate dependencies of each client object and leave the set of root
  dependencies implicit, and injection "pulls in" all the transitive
  dependencies of a client object whenever that client object is requested. Note
  that lazy execution may be used in either approach to avoid unnecessary work;
  the difference between push and pull is not about @emph{performance} but
  rather what @emph{goal} is stated.}]

@section{Derivation Frameworks in Other Languages}

@itemlist[
 @item{Haskell typeclasses --- The canonical example of a derivation framework;
  automatically generating typeclass instances even uses a @litchar{derive}
  keyword.}

 @item{C++ templates -- Programmers specify template parameters and constraints,
  then derive instances of those templates automatically as needed. Templates
  generate code and template parameters can be both types and constant data, so
  this template derivation framework is more than just a generic type system.}
  
 @item{Java annotation processors --- Possibly the most mainstream example of an
  extensible derivation framework; many Java libraries and frameworks use
  annotation processors to generate derived APIs from annotated code.}

 @item{Rust attributes --- Used by the core language to instruct the compiler to
  automatically derive implementations of traits, among other things. A macro
  system additionally allows user libraries to create their attribute-driven
  trait implementations.}]

@section[#:tag "framework"]{The Racket Derivation Framework}

@defform[(deriving rules body ...)
         #:grammar [(rules (code:line) (code:line #:rule rule-expr))]
         #:contracts ([rule-expr derivation-rule?])]{
 Adds each @racket[rule-expr] to the local derivation environment of @racket[
 body]. Each @racket[rule-expr] is evaluated in the transformer environment, not
 at runtime.}

@defform[(derive-from axiom:id context-expr:expr)
         #:contracts ([context-expr derivation-context?])]{
 Finds all definitions in the local derivation environment that can be @tech{
  derived} from @racket[axiom] and binds them in the scope of the @racket[
 derive-from] form. The derivation environment is given @racket[context-expr] as
 a description of what @racket[axiom] is and where it comes from; this is the
 only information about @racket[axiom] that is given to @tech{derivation rules}
 as input.}

@defproc[(make-derivation-rule
          [deriving-function procedure?]
          [#:input-keys inputs (record/c derivation-key? ...kw)]
          [#:output-keys outputs (record/c derivation-key? ...kw)])
         derivation-rule?]{
 Constructs a @tech{derivation rule} from @racket[deriving-function] that
 requires definitions for @racket[inputs] and provides definitions for @racket[
 outputs]. The @racket[derivation-function] is given the derivation context for
 each input key in @racket[inputs] as a keyword argument, and is expected to
 return a @racket[derivation?] with definitions for each output key in @racket[
 outputs].}

@defproc[(derivation [identifiers (listof identifier?)]
                     [expression syntax?]
                     [contexts (record/c derivation-context? ...kw)])
         derivation?]{
 Constructs a derivation.}
