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
# The DMCGetSpecialBlocksForImproperDesign Returns a list of blocks containing two points a,b, 
# from the negative block and a third point c such that [a,b,c] is NOT a negative 
# triple.
#
################################################################################

BindGlobal("DMCGetBlocksContainingList",function(B, i)

	# This function finds all the blocks containing a given list of elements.

	local b, j,k;
	i:=DMCSort2(i);
	b:=DMCSortListList(DMCListListMutableCopy(ShallowCopy(B).blocks));
	for j in b do 
		if not i in Combinations(j, Size(i)) then 
			b:=DMCMultisetDifference(b, [j]); 
		fi; 
	od;
	return b;
end);

BindGlobal("DMCGetBlocksContainingListWithBlockList",function(blockList, i)

	# This function finds all the blocks containing a given list of elements.

	local b, j,k;
	i:=DMCSort2(i);
	b:=DMCSortListList(ShallowCopy(blockList));
	for j in b do 
		if not i in Combinations(j, Size(i)) then 
			b:=DMCMultisetDifference(b, [j]); 
		fi; 
	od;
	return b;
end);

BindGlobal("DMCTotalNumberOfBlockDesigns",function(BList)
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

BindGlobal("DMCGetSpecialBlocksForImproperDesign",function(B)

	local i,choices,j,filterchoices,help;
	choices:=[]; 
	help:=[];
	for i in [1..Size(B.blocks)] do
		if Size(DMCMultisetIntersection(B.blocks[i], B.negatives[1])) = 2 then
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
			Add(help, [B.negatives[1][j],DMCMultisetDifference(filterchoices[i], B.negatives[1])[1]]);
		od;
	od;
	return help;
end);
# a:=DMCLambdaFactorisationMake(4,1);;DMCPrintDesign(a);

BindGlobal("DMCPrintDesign",function(LS)
	local row,col,imp, i, notprinted;
	row:=1;
	if LS.k=[1,1,1] then
		col:=LS.v/3+1;
	fi;
	if LS.k=[2,1] or LS.k=[3] then
		col:=1;
	fi;
	notprinted:=true;
	for i in [1..Size(LS.blocks)] do
		
		if not LS.blocks[i][1]=row then
			Print("\n\n");
			row:=LS.blocks[i][1];
			if LS.k=[1,1,1] then
				col:=LS.v/3+1;
			fi;
			if LS.k=[2,1] or LS.k=[3] then
				col:=1;
			fi;
			notprinted:=true;
		fi;

		while not col = LS.blocks[i][2] do
			if notprinted = true then
				Print("x");
			fi;
			Print("\t");
			col:=col+1;
		od;			

		if LS.k=[1,1,1] then			
			Print(LS.blocks[i][3]-2*LS.v/3,", ");
			notprinted:=false;
		fi;

		if LS.k=[2,1] or LS.k=[3] then
			Print(LS.blocks[i][3],", ");
			notprinted:=false;
		fi;

	od;
	Print("\n");
end);

BindGlobal("DMCExportToMapleWithLatinSquare",function(LS)
	local row,col,imp, i, notprinted;
	row:=1;
	if LS.k=[1,1,1] then
		col:=LS.v/3+1;
	fi;
	if LS.k=[2,1] or LS.k=[3] then
		col:=1;
	fi;
	notprinted:=true;
	Print("Matrix([\n[");
	for i in [1..Size(LS.blocks)] do
		
		if not LS.blocks[i][1]=row then
			Print("\b\b],\n[");
			row:=LS.blocks[i][1];
			if LS.k=[1,1,1] then
				col:=LS.v/3+1;
			fi;

			notprinted:=true;
		fi;

		while not col = LS.blocks[i][2] do
			if notprinted = true then
				Print("x");
			fi;
			col:=col+1;
		od;			

		if LS.k=[1,1,1] then			
			Print("x[",LS.blocks[i][3]-2*LS.v/3,"], ");
			notprinted:=false;
		fi;

	od;
	Print("\b\b]]):\n");
end);

BindGlobal("DMCExportToLaTeXWithLatinSquare",function(LS)
	local row,col,imp, i, notprinted;
	row:=1;
	if LS.k=[1,1,1] then
		col:=LS.v/3;
	fi;
	if LS.k=[2,1] or LS.k=[3] then
		col:=1;
	fi;
	notprinted:=true;
	Print("\\begin{tabular}{");
	for i in [1..col] do
		Print("| c ");
	od;
	Print("|}\n\t\\hline\n\t\t");
		
	for i in [1..Size(LS.blocks)] do
		
		if not LS.blocks[i][1]=row then
			Print("\\\\ \n\t\\hline\n\t\t");
			row:=LS.blocks[i][1];
			if LS.k=[1,1,1] then
				col:=LS.v/3+1;
			fi;

			notprinted:=true;
		fi;

		if LS.k=[1,1,1] then			
			if(notprinted = false) then
				Print(" & ");
			fi;
			Print(" ",LS.blocks[i][3]-2*LS.v/3,"  ");
			notprinted:=false;
		fi;

	od;
	Print("\\\\\n\t\\hline\n\\end{tabular}\n");
end);
