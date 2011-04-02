################################################################################
# DesignMC/lib/MarkovChain.g                                    Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# Given a proper or improper system, GeneratePivot will generate a block to add to
# the BlockDesign B to initiate the Markov chain move.
# 
# RemovableBlocks returns a list of blocks that we could remove given that we added
# pivot to initiate the move.
# 
# Hopper performs one Markov chain iteration.
#
# OneStep Performs the required number of Hopper iterations to move from a proper
# design to an improper design.
#
# ManyStepsProper performs OneStep i times.
#
# ManyStepsImproper performs at least i hops to find an improper design.
#
# RandomWalkOnMarkovChain performs a random walk on the MC.
# 
################################################################################

BindGlobal("GeneratePivot",function(B)
	local D;
	D:=ShallowCopy(B);
	if D.k = [1,1,1] then
		return Random(MultisetDifference(Cartesian([1..D.vType[1]], [D.vType[1]+1..D.vType[1]+D.vType[2]], [D.vType[1]+D.vType[2]+1..D.vType[1]+D.vType[2]+D.vType[3]]), D.blocks));
	fi;
	if D.k = [2,1] then
		return Flat(Random(MultisetDifference(Cartesian(Combinations([1..D.vType[1]],2), [D.vType[1]+1..D.vType[1]+D.vType[2]]), D.blocks)));
	fi;
	if D.k = [3] then
		return Random(MultisetDifference(Combinations([1..D.v], 3), D.blocks));
	fi;
end);

BindGlobal("RemovableBlocks",function(D, pivot)
	local A,B,C,F,i,j,k,lis;
	F:=ShallowCopy(D);
	F.blocks:=GetMutableListList(F.blocks);
	A:=get_blocks_containing_list(F, Sort2([pivot[1], pivot[2]]));
	B:=get_blocks_containing_list(F, Sort2([pivot[1], pivot[3]]));
	C:=get_blocks_containing_list(F, Sort2([pivot[2], pivot[3]]));
	
	lis:=[];
	for i in A do
		for j in B do
			if j = i and Size(get_blocks_containing_list(F, j))<2 then
				break;
			fi;
			for k in C do
				if (k = j and Size(get_blocks_containing_list(F, j))<2) or (k = i and Size(get_blocks_containing_list(F, k))<2) or (k=j and j=i and Size(get_blocks_containing_list(F, j))<3) then
					break;
				fi;
				
				# Now we have three distinct blocks, i, j and k.
				
				Add(lis, [MultisetDifference(i, [pivot[1], pivot[2]])[1], MultisetDifference(j, [pivot[1], pivot[3]])[1], MultisetDifference(k, [pivot[2], pivot[3]])[1]]);
				
			od;
		od;
	od;

	return lis;
end);

BindGlobal("Hopper",function(B, add, remove)
	local a,b,c,d,x,y,z,B2,atmp,btmp,ctmp,i,g1,g2;
	g1:=fail;
	g2:=fail;
	B2:=ShallowCopy(B);
	B2.blocks:=GetMutableListList(B2.blocks);
	B2.negatives:=GetMutableListList(B2.negatives);

	i:=0;
	while i=0 do

		if add = [] then
			if Size(B2.negatives)>0 then
				if Size(B2.negatives) = MAX_NEGATIVE_BLOCKS then
					add:=Random(B2.negatives);
				else
					if Random([1,2]) = 1 then
						add:=GeneratePivot(B2);
					else
						add:=Random(B2.negatives);
					fi;
				fi;
			else
				add:=GeneratePivot(B2);
			fi;
		fi;
	
		i:=Size(RemovableBlocks(B2, add));
		if i = 0 then 
			add:= []; 
		fi;
	od;



	if remove = [] then
		remove := Random(RemovableBlocks(B2, add));
	fi;

	# Remove the necessary blocks

	if Sort2([remove[1], add[1], add[2]]) in B.blocks and Sort2([remove[2], add[1], add[3]]) in B.blocks and Sort2([remove[3], add[2], add[3]]) in B.blocks then
		a:=Sort2([remove[1], add[1], add[2]]);
		b:=Sort2([remove[2], add[1], add[3]]);
		c:=Sort2([remove[3], add[2], add[3]]);
	fi;

	if Sort2([remove[2], add[1], add[2]]) in B.blocks and Sort2([remove[1], add[1], add[3]]) in B.blocks and Sort2([remove[3], add[2], add[3]]) in B.blocks then
		a:=Sort2([remove[2], add[1], add[2]]);
		b:=Sort2([remove[1], add[1], add[3]]);
		c:=Sort2([remove[3], add[2], add[3]]);
	fi;

	if Sort2([remove[2], add[1], add[2]]) in B.blocks and Sort2([remove[3], add[1], add[3]]) in B.blocks and Sort2([remove[1], add[2], add[3]]) in B.blocks then
		a:=Sort2([remove[2], add[1], add[2]]);
		b:=Sort2([remove[3], add[1], add[3]]);
		c:=Sort2([remove[1], add[2], add[3]]);
	fi;

	if Sort2([remove[3], add[1], add[2]]) in B.blocks and Sort2([remove[2], add[1], add[3]]) in B.blocks and Sort2([remove[1], add[2], add[3]]) in B.blocks then
		a:=Sort2([remove[3], add[1], add[2]]);
		b:=Sort2([remove[2], add[1], add[3]]);
		c:=Sort2([remove[1], add[2], add[3]]);
	fi;

	if Sort2([remove[1], add[1], add[2]]) in B.blocks and Sort2([remove[3], add[1], add[3]]) in B.blocks and Sort2([remove[2], add[2], add[3]]) in B.blocks then
		a:=Sort2([remove[1], add[1], add[2]]);
		b:=Sort2([remove[3], add[1], add[3]]);
		c:=Sort2([remove[2], add[2], add[3]]);
	fi;

	if Sort2([remove[3], add[1], add[2]]) in B.blocks and Sort2([remove[1], add[1], add[3]]) in B.blocks and Sort2([remove[2], add[2], add[3]]) in B.blocks then
		a:=Sort2([remove[3], add[1], add[2]]);
		b:=Sort2([remove[1], add[1], add[3]]);
		c:=Sort2([remove[2], add[2], add[3]]);
	fi;

	#remove the target block if it was in the blocks, or add it to the negatives.

	B2.blocks:=SortListList(B2.blocks);
	if Sort2(remove) in B2.blocks then
		g1:= Size(B2.blocks);
		B2.blocks:=MultisetDifference(B2.blocks, [Sort2(remove)]);
		if not Size(B2.blocks) = g1 -1 then
			g1:= fail;
		else
			g1:=true;
		fi;
	
	else
		g1:=true;
		Add(B2.negatives, Sort2(remove));
	
	fi;

	#remove the other three blocks
	g2:= Size(B2.blocks);
	B2.blocks:=MultisetDifference(B2.blocks, SortListList([a,b,c]));
	if not Size(B2.blocks) = g2-3 then
		g2:=fail;
	else
		g2:=true;
	fi;

	# Add the necessary blocks

	#if the adding block was negative, remove it from negs, otherwise add to blocks.

	B2.negatives:=SortListList(B2.negatives);
	if Sort2(add) in B2.negatives then
		B2.negatives:=MultisetDifference(B2.negatives, Sort2([add]));
		B2.negatives:=SortListList(B2.negatives);
	
	else
		Add(B2.blocks, Sort2(add));
		B2.blocks:=SortListList(B2.blocks);

	fi;

	x:=MultisetDifference(a, [add[1], add[2]])[1];
	y:=MultisetDifference(b, [add[1], add[3]])[1];
	z:=MultisetDifference(c, [add[2], add[3]])[1];
	B2.negatives:=SortListList(B2.negatives);
	if Sort2([add[1], y, x]) in B2.negatives then	
		B2.negatives:=MultisetDifference(B2.negatives, [Sort2([add[1], y, x])]);
	else
		Add(B2.blocks, Sort2([add[1], y, x]));
	
	fi;
	if Sort2([z, add[2], x]) in B2.negatives then	
		B2.negatives:=MultisetDifference(B2.negatives, [Sort2([z, add[2], x])]);
	
	else
		Add(B2.blocks, Sort2([z, add[2], x]));
	
	fi;
	if Sort2([z, y, add[3]]) in B2.negatives then	
		B2.negatives:=MultisetDifference(B2.negatives, [Sort2([z, y, add[3]])]);
	
	else
		Add(B2.blocks, Sort2([z, y, add[3]]));
	
	fi;
	B2.blocks:=SortListList(B2.blocks);

	if Size(B2.negatives)>0 then
		B2.improper:=true;
	else
		B2.improper:=false;
	fi;
	Unbind(B2.autGroup);
	B2.blockNumbers:=[Size(B2.blocks)];
	B2.isBinary:=IsBinaryBlockDesign(B2);
	B2.tSubsetStructure.t:=2;
	B2.isSimple:=IsSimpleBlockDesign(B2);
	#Unbind(B2.tSubsetStructure);
	Unbind(B2.autSubgroup);
	B2.blocks:=SortListList(B2.blocks);

	if g1=fail or g2 = fail then
		return B;
	fi;

	return B2;
	
end);

BindGlobal("OneStep",function(B)
	local B2;
	B2:=ShallowCopy(B);
	B2:=Hopper(B2, [], []);
	while B2.improper = true do
		B2:=Hopper(B2, [], []);
	od;
	return B2;
end);

BindGlobal("ManyStepsProper",function(B, i)
	local B2, j;
	B2:=ShallowCopy(B);
	for j in [1..i] do
		#ShowProgressIndicator(j);
		B2:=OneStep(B2);
	od;
	#Print("\n");
	return B2;
end);

BindGlobal("ManyStepsImproper",function(B, i)
	local B2, j;

	B2:=ShallowCopy(B);
	for j in [1..i] do
		#ShowProgressIndicator(j);
		B2:=Hopper(B2, [], []);
	od;
	while B2.improper = false do
		B2:=Hopper(B2, [], []);
	od;
	#Print("\n");
	return B2;
end);

BindGlobal("RandomWalkOnMarkovChain",function(B, improper)
	local i,foundIso, foundNonIso, a, B2, isom;
	foundNonIso:=[];
	foundIso:=[];
	B2:=ShallowCopy(B);
	i:=0;
	while 1=1 do
		i:=i+1;
		if improper = true then
			B2 := ManyStepsImproper( B2, 10);
		else	
			B2 := ManyStepsProper( B2, 10);
		fi;

		if not B2 in foundIso then
			Add( foundIso, B2 );
		fi;

		if i mod 1000 = 0 then
			foundNonIso:=BlockDesignIsomorphismClassRepresentatives(foundIso);
			Print("\nNumber of non-isomorphic systems found = ", Size(foundNonIso),"; total found = ",Size(foundIso),"\n" );
		fi;
		ShowProgressIndicator(i);
	od;
end);
