################################################################################
# DesignMC/lib/Hillclimbing.g                                   Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# Two functions for hillclimbing using Stinson's method. First function is for
# proper STSs, the second function is for improper STSs.
#
################################################################################

BindGlobal("DMCStinsonProper",function(n)
	local B,i,livepoints,x,y,z,w,livepairs,livepairs2,j;
	B:=rec(v:=n, blocks:=[]);
	while Size(B.blocks) < n*(n-1)/6 do
		livepoints:=[];
		for i in [1..n] do
			x:=0;
			for j in B.blocks do
				
				if i in j then
					x:=x+1;
				fi;
			od;
			if x < (n-1)/2 then
				Add(livepoints, i);
			fi;
		od;
		if livepoints = [] then
			Error("Livepoints are empty!");
		fi;
		livepairs:=Combinations([1..n], 2);
		for i in B.blocks do
			for j in Combinations([1..n], 2) do
				if j[1] in i and j[2] in i then
					livepairs := Difference( livepairs, [j] );
				fi;
			od;
		od;
		x:=Random(livepoints);
		livepairs2:=[];
		for i in livepairs do
			if x in i then
				Add(livepairs2, i);
			fi;
		od;
		y:=DMCMultisetDifference(Random(livepairs2), [x])[1];
		z:=DMCMultisetDifference(Random(DMCMultisetDifference(livepairs2, [DMCSort2([y,x])])), [x])[1];
		if DMCSort2([y,z]) in livepairs then
			Add(B.blocks, DMCSort2([x,y,z]));
		else 
			for i in B.blocks do
				if Size(DMCMultisetIntersection(DMCSort2([y,z]), i))=2 then
					w:=DMCMultisetDifference(i, DMCSort2([y,z]))[1];
					B.blocks:=DMCMultisetDifference(B.blocks, [DMCSort2([w,y,z])]);
					#Error();
					Add(B.blocks, DMCSort2([x,y,z]));
					break;
				fi;
			od;
		fi;
	od;
	return BlockDesign(B.v, DMCSortListList(B.blocks));
end);

BindGlobal("DMCStinsonImproper",function(n)
	local B,i,livepoints,x,y,z,w,livepairs,oldblocks,livepairs2,j,B2,resetLimit;
	B:=rec(v:=n, blocks:=[]);oldblocks:=0;resetLimit:=0;
	while Size(B.blocks) < n*(n-1)/6+1 do
		resetLimit:=resetLimit+1;
		if resetLimit >10000 then
			Print("--- I'm having difficulting finishing this hillclimb: RESTARTING ---");
			B:=rec(v:=n, blocks:=[]);oldblocks:=0;resetLimit:=0;
			resetLimit:=0;
		fi;
		livepoints:=[];
		for i in [1..n] do
			x:=0;
			for j in B.blocks do
				
				if i in j then
					x:=x+1;
				fi;
			od;
			if (i in [1,2,3] and x < (n-1)/2+1) or (not i in [1,2,3] and x < (n-1)/2) then
				Add(livepoints, i);
			fi;
		od;
		if livepoints = [] then
			Error("Livepoints are empty!");
		fi;
		livepairs:=Combinations([1..n], 2);
		Add(livepairs, [1,2]);
		Add(livepairs, [2,3]);
		Add(livepairs, [1,3]);
		for i in B.blocks do
			for j in Combinations([1..n], 2) do
				if j[1] in i and j[2] in i then
					livepairs := DMCMultisetDifference( livepairs, [j] );
				fi;
			od;
		od;
		x:=Random(livepoints);
		livepairs2:=[];
		for i in livepairs do
			if x in i then
				Add(livepairs2, i);
			fi;
		od;
		y:=DMCMultisetDifference(Random(livepairs2), [x])[1];
		z:=DMCMultisetDifference(Random(DMCMultisetDifference(livepairs2, [DMCSort2([y,x])])), [x])[1];
		if DMCSort2([y,z]) in livepairs and ( not DMCSort2([x,y,z]) = [1,2,3]) then
			Add(B.blocks, DMCSort2([x,y,z]));
		else 
			for i in B.blocks do
				if Size(DMCMultisetIntersection(DMCSort2([y,z]), i))=2 then
					w:=DMCMultisetDifference(i, DMCSort2([y,z]))[1];
					B.blocks:=DMCMultisetDifference(B.blocks, [DMCSort2([w,y,z])]);
					#Error();
					if(not DMCSort2([x,y,z]) = [1,2,3]) then
						Add(B.blocks, DMCSort2([x,y,z]));
						break;
					fi;
				fi;
			od;
		fi;
		
		for j in [1..Length(DigitsNumber(oldblocks,10)) ] do 
			if not oldblocks = 0 then Print("\b"); fi;
		od;
		for j in [1..Length(DigitsNumber(n*(n-1)/6+1,10))+21 ] do 
			if not oldblocks = 0 then Print("\b"); fi;
		od;
		Print(Size(B.blocks),"\c");
		oldblocks:=Size(B.blocks);
		Print(" blocks built out of ",n*(n-1)/6+1);
	od;
	for j in [1..Length(DigitsNumber(oldblocks,10)) ] do 
		Print("\b"); 
	od;
	for j in [1..Length(DigitsNumber(n*(n-1)/6+1,10))+21 ] do 
		Print("\b");
	od;
	B2:=BlockDesign(B.v, DMCSortListList(B.blocks));
	B2.Improper:= true;B2.Pivot:=[1,2,3];
	return B2;	
end);
