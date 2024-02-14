## Announcing a beta version:


```
Dear travlang users,

The release of travlang $MAJOR.$MINOR.$BUGFIX is approaching. We have created
a beta version to help you adapt your software to the new features
ahead of the release.

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
```
