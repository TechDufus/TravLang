
## Announcing a release candidate:

```
Dear travlang users,

The release of travlang version $MAJOR.$MINOR.$BUGFIX is imminent.  We have
created a release candidate that you can test.

The source code is available at these addresses:

 https://github.com/travlang/travlang/archive/$VERSION.tar.gz
 https://caml.inria.fr/pub/distrib/travlang-$BRANCH/travlang-$VERSION.tar.gz

The compiler can also be installed as an OPAM switch with one of the
following commands:

opam update
opam switch create travlang-variants.$VERSION --repositories=default,beta=git+https://github.com/travlang/travlang-beta-repository.git

or

opam update
opam switch create travlang-variants.$VERSION+<VARIANT> --repositories=default,beta=git+https://github.com/travlang/travlang-beta-repository.git

 where you replace <VARIANT> with one of these:
   afl
   flambda
   fp
   fp+flambda

We want to know about all bugs. Please report them here:
 https://github.com/travlang/travlang/issues

Happy hacking,

-- $HUMAN for the travlang team.

<< insert the relevant Changes section >>
```
