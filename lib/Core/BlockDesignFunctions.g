################################################################################
# DesignMC/lib/BlockDesignFunctions.g	                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# Two functions to get all of the blocks containing some list. The difference between
# the two functions is that one requires a BlockDesign, the other jus requires a 
# list of lists.
#
# Another function to test whether a BlockDesign is a Partial Steiner Triple System.
#
# Also function which returns the total number of isomorphic systems to a given
# system.
#
# The GetSpecialBlocksForImproperDesign Returns a list of blocks containing two points a,b, 
# from the negative block and a third point c such that [a,b,c] is NOT a negative 
# triple.
#
# GetBlocksContainingList
# GetBlocksContainingListWithBlockList
# TotalNumberOfBlockDesigns
# GetSpecialBlocksForImproperDesign
#
################################################################################

BindGlobal("GetBlocksContainingList",function(B, i)

	# This function finds all the blocks containing a given list of elements.

	local b, j,k;
	i:=CopyAndSort(i);
	b:=CopyAndSortListList(ListListMutableCopy(ShallowCopy(B).blocks));
	for j in b do 
		if not i in Combinations(j, Size(i)) then 
			b:=MultisetDifference(b, [j]); 
		fi; 
	od;
	return b;
end);

BindGlobal("GetBlocksContainingListWithBlockList",function(blockList, i)

	# This function finds all the blocks containing a given list of elements.

	local b, j,k;
	i:=CopyAndSort(i);
	b:=CopyAndSortListList(ShallowCopy(blockList));
	for j in b do 
		if not i in Combinations(j, Size(i)) then 
			b:=MultisetDifference(b, [j]); 
		fi; 
	od;
	return b;
end);

BindGlobal("TotalNumberOfBlockDesigns",function(BList)
	local a,k;
	a:=0;
	if Size(BList)=0 then return 0; fi;
	if BList[1].k=[1,1,1] and BList[1].vType[1]=BList[1].vType[2] and BList[1].vType[1]=BList[1].vType[3] then
		for k in BList do
			a:=a+Factorial(3)*Factorial(k.vType[1])*Factorial(k.vType[2])*Factorial(k.vType[3])/Size(AutomorphismGroup(k));
		od;
	fi;
	if BList[1].k=[2,1] then
		for k in BList do
			a:=a+Factorial(k.vType[1])*Factorial(k.vType[2])/Size(AutomorphismGroup(k));
		od;
	fi;
	if BList[1].k=[3] then
		for k in BList do
			a:=a+Factorial(k.v)/Size(AutomorphismGroup(k));
		od;
	fi;
	return a;
end);

BindGlobal("GetSpecialBlocksForImproperDesign",function(B)

	local i,choices,j,filterchoices,help;
	choices:=[]; 
	help:=[];
	for i in [1..Size(B.blocks)] do
		if Size(MultisetIntersection(B.blocks[i], B.negatives[1])) = 2 then
			Add(choices, B.blocks[i]);
		fi;
	od;
	for j in [1,2,3] do
		filterchoices:=[];
		for i in [1..Size(choices)] do
			if not B.negatives[1][j] in choices[i] then
				Add(filterchoices, choices[i]);
			fi;
		od;
		for i in [1..Size(filterchoices)] do
			Add(help, [B.negatives[1][j],MultisetDifference(filterchoices[i], B.negatives[1])[1]]);
		od;
	od;
	return help;
end);

