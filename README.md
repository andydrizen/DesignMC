DesignMC
========

A [GAP](http://www.gap-system.org) package for generating uniformly distributed random generalised 2-designs with block size 3 with the following core features:

* Interface with the [DESIGN Package](http://designtheory.org/software/gap_design/) to generate the proper and improper designs;
* Implementation of Jacobson and Matthews' Markov chain for sampling the designs;
* Mathematica integration for creating and analysing pair graphs;
* Algorithms for finding alternating trails;

There are also some extras included for the advanced user. These include exporting to different file types (JSON etc.) and testing various types of designs.

Licence
-------

GNU GENERAL PUBLIC LICENSE, Version 3

Requirements
------------

[GAP v4.5.5](http://www.gap-system.org)

### Required GAP Packages
 
* [GRAPE Package](http://www.maths.qmul.ac.uk/~leonard/grape/)
* [DESIGN Package](http://designtheory.org/software/gap_design/)
* [JSONGAP Package](https://github.com/andydrizen/JSONGAP/)
    * JSONGAP depends on the [Strings Package](https://github.com/andydrizen/Strings/)

Installation
------------

To initialise the DesignMC Package, put the Strings folder in the pkg directory of your GAP 
root and in GAP type:

`gap> LoadPackage("DesignMC");`

Alternatively, you can download the source to any/folder/you/like/DesignMC and then run GAP with

`gap -l 'path/to/your/GAP4r5r5/bin/;any/folder/you/like/;'`

Quick Start
-----------

### Generating Generalised 2-designs

The DESIGN package is able to construct generalised t-designs, but due to its generality, the code required to do so is often cumbersome. As we are working strictly with squares, factorisations and triple systems of block size 3, the DesignMC package is able to considerably simplify the construction experience by abstracting the appropriate functions from the [DESIGN Package](http://designtheory.org/software/gap_design/).

---

### QuickLatinSquare

#### Required Parameters
* `n` _Positive integer_

#### Returns
___Record___

#### Description
Returns the cyclic Latin square of order n.

#### Usage
    gap> square:=QuickLatinSquare(4);
    rec( blocks := [ [ 1, 5, 9 ], [ 1, 6, 10 ], [ 1, 7, 11 ], [ 1, 8, 12 ], 
	   [ 2, 5, 10 ], [ 2, 6, 11 ], [ 2, 7, 12 ], [ 2, 8, 9 ], [ 3, 5, 11 ], 
	   [ 3, 6, 12 ], [ 3, 7, 9 ], [ 3, 8, 10 ], [ 4, 5, 12 ], [ 4, 6, 9 ], 
	   [ 4, 7, 10 ], [ 4, 8, 11 ] ], improper := false, isBlockDesign := true, 
	k := [ 1, 1, 1 ], negatives := [  ], 
	tSubsetStructure := rec( lambdas := [ 1, 0 ] ), v := 12, 
	vType := [ 4, 4, 4 ] )

---

### ProduceSquare

#### Required Parameters
* `input` ___Record___
* `input.v` ___List___ A tuple of positive integers

#### Optional Parameters

* `input.lambdas` ___List___ A tuple of positive integers for the lambda values RC, RS and CS (in that order).
* `isoLevel` ___0, 1, 2___: See [DESIGN Documentation](http://www.maths.qmul.ac.uk/~leonard/design/manual/CHAP007.htm).
* `requiredAutSubgroup` ___Group___: See [DESIGN Documentation](http://www.maths.qmul.ac.uk/~leonard/design/manual/CHAP007.htm).
* `isoGroup` ___Group___ See [DESIGN Documentation](http://www.maths.qmul.ac.uk/~leonard/design/manual/CHAP007.htm).
* `show_output` ___Boolean___ Set to `true` for verbose mode.
* `improper` ___Boolean___ Set to `true` if you only want improper designs.

#### Returns
___List___

#### Description

Returns a square with the specified parameters. 

#### Usage

    gap> input:=rec(v:=[4,4,4], lambdas:=[2,2,2], isoLevel:=0, improper:=true);;
    gap> ProduceSquare(input);
    [ rec( 
      autSubgroup := Group(
        [ (1,5)(2,6)(3,7)(4,8), (1,9,5)(2,12,6)(3,10,7)(4,11,8) ]), 
      blockNumbers := [ 33 ], blockSizes := [ 3 ], 
      blocks := [ [ 1, 5, 10 ], [ 1, 5, 10 ], [ 1, 5, 11 ], [ 1, 6, 12 ], 
          [ 1, 6, 12 ], [ 1, 7, 9 ], [ 1, 7, 9 ], [ 1, 8, 9 ], [ 1, 8, 11 ], 
          [ 2, 5, 12 ], [ 2, 5, 12 ], [ 2, 6, 9 ], [ 2, 6, 9 ], [ 2, 7, 11 ], 
          [ 2, 7, 11 ], [ 2, 8, 10 ], [ 2, 8, 10 ], [ 3, 5, 9 ], [ 3, 5, 9 ], 
          [ 3, 6, 11 ], [ 3, 6, 11 ], [ 3, 7, 10 ], [ 3, 7, 10 ], 
          [ 3, 8, 12 ], [ 3, 8, 12 ], [ 4, 5, 9 ], [ 4, 5, 11 ], 
          [ 4, 6, 10 ], [ 4, 6, 10 ], [ 4, 7, 12 ], [ 4, 7, 12 ], 
          [ 4, 8, 9 ], [ 4, 8, 11 ] ], improper := true, isBinary := true, 
      isBlockDesign := true, isSimple := false, k := [ 1, 1, 1 ], 
      negatives := [ [ 1, 5, 9 ] ], 
      tSubsetStructure := 
        rec( lambdas := [ 2, 0, 3 ], 
          partition := 
            [ 
              [ [ 1, 6 ], [ 1, 7 ], [ 1, 8 ], [ 1, 10 ], [ 1, 11 ], [ 1, 12 ], 
                  [ 2, 5 ], [ 2, 6 ], [ 2, 7 ], [ 2, 8 ], [ 2, 9 ], 
                  [ 2, 10 ], [ 2, 11 ], [ 2, 12 ], [ 3, 5 ], [ 3, 6 ], 
                  [ 3, 7 ], [ 3, 8 ], [ 3, 9 ], [ 3, 10 ], [ 3, 11 ], 
                  [ 3, 12 ], [ 4, 5 ], [ 4, 6 ], [ 4, 7 ], [ 4, 8 ], 
                  [ 4, 9 ], [ 4, 10 ], [ 4, 11 ], [ 4, 12 ], [ 5, 10 ], 
                  [ 5, 11 ], [ 5, 12 ], [ 6, 9 ], [ 6, 10 ], [ 6, 11 ], 
                  [ 6, 12 ], [ 7, 9 ], [ 7, 10 ], [ 7, 11 ], [ 7, 12 ], 
                  [ 8, 9 ], [ 8, 10 ], [ 8, 11 ], [ 8, 12 ] ], 
              [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ], 
                  [ 5, 6 ], [ 5, 7 ], [ 5, 8 ], [ 6, 7 ], [ 6, 8 ], [ 7, 8 ], 
                  [ 9, 10 ], [ 9, 11 ], [ 9, 12 ], [ 10, 11 ], [ 10, 12 ], 
                  [ 11, 12 ] ], [ [ 1, 5 ], [ 1, 9 ], [ 5, 9 ] ] ], t := 2 ), 
      v := 12, vType := [ 4, 4, 4 ] ) ]

---

### ProduceLamdaFactorisation

---

### ProduceTripleSystem

---

### Make2Design

---

### MakeSquare

---

### MakeImproperSquare

---

### MakeLambdaFactorisation

---

### MakeImproperLambdaFactorisation

---

### MakeTripleSystem

---

### MakeImproperTripleSystem

---

## Enumerating Generalised 2-designs

---

### EnumerateSquares

---

### EnumerateImproperSquares

---

### EnumerateLambdaFactorisations

---

### EnumerateImproperLambdaFactorisations

---

### EnumerateTripleSystems

---

### EnumerateImproperTripleSystems

---

## Moving Around the Markov Chain

---

### GeneratePivot

---

### RemovableBlocks

---

### Hopper

---

### OneStep

---

### ManyStepsProper

---

### ManyStepsImproper

---

### RandomWalkOnMarkovChain

---

## Pair Graphs

---

### CreatePairGraph

---

### FindAlternatingTrail

---

### FindAlternatingTrailWithoutGivenBlueEdge

---

### FindAllAlternatingTrails

---

### ComponentsOfGraph

---

### IsChordedDG

---

References
----------

* [Generating uniformly distributed random latin squares](http://onlinelibrary.wiley.com/doi/10.1002/\(SICI\)1520-6610\(1996\)4:6%3C405::AID-JCD3%3E3.0.CO;2-J/abstract), M. Jacobson and P. Matthews, 1998
* [The DESIGN package for GAP](http://designtheory.org/software/gap_design/), L. Soicher, 2011
* [The GRAPE package for GAP](http://www.maths.qmul.ac.uk/~leonard/grape/), L. Soicher, 2012
* [Generating Uniformly Distributed Random 2-Designs with Block Size 3](http://onlinelibrary.wiley.com/doi/10.1002/jcd.21301/abstract), A. Drizen, 2012
