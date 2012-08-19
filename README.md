DesignMC
========

A [GAP](http://www.gap-system.org) package for generating uniformly distributed random generalised 2-designs with block size 3.

Licence
-------

GNU GENERAL PUBLIC LICENSE, Version 3

Requirements
------------

[GAP v4.5.5](http://www.gap-system.org)

### Required GAP Packages
 
* [GRAPE Package](http://www.maths.qmul.ac.uk/~leonard/grape/)
* [DESIGN Package](http://designtheory.org/software/gap_design/)
* [JSON Package](https://github.com/andydrizen/JSONGAP/)

Installation
------------

To initialise the DesignMC Package, put the Strings folder in the pkg directory of your GAP 
root and in GAP type:

`gap> LoadPackage("DesignMC");`

Alternatively, you can download the source to any/folder/you/like/DesignMC and then run GAP with

`gap -l 'path/to/you/GAP4r5r5/bin/;any/folder/you/like/;'`

Quick Start
-----------



References
----------

* [Generating uniformly distributed random latin squares](http://onlinelibrary.wiley.com/doi/10.1002/\(SICI\)1520-6610\(1996\)4:6%3C405::AID-JCD3%3E3.0.CO;2-J/abstract), Jacobson/Matthews 1998
* [The DESIGN package for GAP](http://designtheory.org/software/gap_design/), Soicher, 2011
* [The GRAPE package for GAP](http://www.maths.qmul.ac.uk/~leonard/grape/), Soicher, 2012
* [Generating Uniformly Distributed Random 2-Designs with Block Size 3](http://onlinelibrary.wiley.com/doi/10.1002/jcd.21301/abstract), Drizen, 2012
