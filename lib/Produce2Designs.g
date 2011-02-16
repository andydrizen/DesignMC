################################################################################
# DesignMC/lib/Produce2Designs.g                                Andy L. Drizen
#                                                                   15/02/2011
# File overview:
#  
# This file is really just a wrapper for Soicher's DESIGN function BlockDesigns.
# 
# ProduceLS
#
# Produce1F
#
# ProduceSTS
#
# Produce2Design
#
################################################################################

BindGlobal("ProduceLS",function(input)
	#input is a rec. You should, at the very least, include these:
	
		# "v" (list): 	A tuple of positive integers, e.g. [2,4,6]. This means your square 
		# 						has 2 Row, 4 Cols, 6 Symbols
		
	# optional extras:
	
		#lambdas (list): 	A tuple of positive integers for the lambda values RC, RS and CS 
		#						(in that order) e.g. [1,1,1].
		
		# isoLevel (int): as in DESIGN.
		# requiredAutSubgroup (GROUP): as in DESIGN.
		# isoGroup (GROUP): as in DESIGN.
		

		# show_output (BOOL):	Shows a little output about your query.
		# improper (BOOL):		return only proper or improper designs

	local k,t,Y,RC,RS,CS,NrR,NrC,NrS,L0,rl,cl,sl, partition,DL,lambdas,typeVector,lambdaVectorRCS, isoLevel,requiredAutSubgroup,imp,pivot,tmp, imp1, imp2, imp3,results,i,requirements, negatives,blocksAvailable,isoGroup;

	
	if IsBound(input.lambdas) then
		lambdaVectorRCS:=input.lambdas;
	else
		lambdaVectorRCS:=[1,1,1];
	fi;

	if IsBound(input.isoLevel) then	
		isoLevel:=input.isoLevel;
	else
		isoLevel:=0;
	fi;

	
	if IsBound(input.requiredAutSubgroup) then	
		requiredAutSubgroup:=input.requiredAutSubgroup;
	else
		requiredAutSubgroup:=Group([()]);
	fi;
	
	if IsBound(input.improper) then
		imp:=input.improper;
	else
		imp:=false;
	fi;
	
	k:=[3];
	t:=2;
	negatives:=[];

	typeVector:=input.v;
	NrR:=typeVector[1];
	NrC:=typeVector[2];
	NrS:=typeVector[3];
	
	RC:=Cartesian([1..NrR], [NrR+1..NrR+NrC]); #rows & cols
	RS:=Cartesian([1..NrR], [NrR+NrC+1..NrR+NrC+NrS]); #rows & symb
	CS:=Cartesian([NrR+1..NrR+NrC], [NrR+NrC+1..NrR+NrC+NrS]); #cols & symb
	
	blocksAvailable:=Cartesian([1..NrR],[NrR+1..NrR+NrC],[NrR+NrC+1..NrR+NrC+NrS]);
	
	Y:=Union(RC,RS,CS);	
	L0:=MultisetDifference(Combinations([1..NrS+NrR+NrC], 2), Y);	

	if imp=true then
		pivot:=[1, NrR+1, NrR+NrC+1];
		blocksAvailable:=Difference(blocksAvailable, [pivot]);
		
		Add(negatives, pivot);
		
		imp1:=lambdaVectorRCS[1]+1;
		RC:=MultisetDifference(RC, [[pivot[1], pivot[2]]]);

		imp2:=lambdaVectorRCS[2]+1;
		RS:=MultisetDifference(RS, [[pivot[1], pivot[3]]]);
	
		imp3:=lambdaVectorRCS[3]+1;
		CS:=MultisetDifference(CS, [[pivot[2], pivot[3]]]);

		Y:=Union(RC,RS,CS);	
		L0:=MultisetDifference(L0, [[pivot[1], pivot[2]], [pivot[1], pivot[3]], [pivot[2], pivot[3]]]);
	fi;
	blocksAvailable:=DuplicateList(blocksAvailable, Maximum(lambdaVectorRCS+1));
		
	if Size(Unique(lambdaVectorRCS)) = 1 then
		partition:=[Y, L0];
		lambdas:=Flat([Unique(lambdaVectorRCS),0]);		
	fi;
	if Size(Unique(lambdaVectorRCS)) = 2 then
		if lambdaVectorRCS[1] = lambdaVectorRCS[2] then
			partition:=[Union(RC,RS), CS,L0];
			lambdas:=Flat([lambdaVectorRCS[1],lambdaVectorRCS[3],0]);
		fi;
		if lambdaVectorRCS[1] = lambdaVectorRCS[3] then
			partition:=[Union(RC,CS), RS,L0];
			lambdas:=Flat([lambdaVectorRCS[1],lambdaVectorRCS[2],0]);
		fi;
		if lambdaVectorRCS[2] = lambdaVectorRCS[3] then
			partition:=[RC,Union(RS,CS),L0];
			lambdas:=Flat([lambdaVectorRCS[1],lambdaVectorRCS[2],0]);
		fi;
	fi;
	if Size(Unique(lambdaVectorRCS)) = 3 then
		partition:=[RC,RS,CS,L0];		
		lambdas:=Flat([lambdaVectorRCS,0]);
	fi;
	
	if imp=true then
		for tmp in [1..Size(lambdas)] do
			i:=0;
			if imp1 = lambdas[tmp] then
				Add(partition[tmp], Set([pivot[1], pivot[2]]));
				partition[tmp]:=Set(partition[tmp]);
				i:=1;
				break;
			fi;
		od;
		if i = 0 then
			Add(partition, [Set([pivot[1], pivot[2]])]);
			Add(lambdas, imp1);
		fi;
	
		for tmp in [1..Size(lambdas)] do
			i:=0;
			if imp2 = lambdas[tmp] then
				Add(partition[tmp], Set([pivot[1], pivot[3]]));
				partition[tmp]:=Set(partition[tmp]);
				i:=1;
				break;
			fi;
		od;
		if i = 0 then
			Add(partition, [Set([pivot[1], pivot[3]])]);
			Add(lambdas, imp2);
		fi;
	
		for tmp in [1..Size(lambdas)] do
			i:=0;
			if imp3 = lambdas[tmp] then
				Add(partition[tmp], Set([pivot[2], pivot[3]]));
				partition[tmp]:=Set(partition[tmp]);
				i:=1;
				break;
			fi;
		od;
		if i = 0 then
			Add(partition, [Set([pivot[2], pivot[3]])]);
			Add(lambdas, imp3);
		fi;
		
	fi;
	requirements:=rec(	v:=NrS+NrC+NrR, 
								blockSizes:=k, 
								tSubsetStructure:=rec(	t:=t,
																partition:=partition,
																lambdas:=lambdas
																),
								isoLevel:=isoLevel,
								blockDesign:=BlockDesign(NrS+NrC+NrR,blocksAvailable),
								requiredAutSubgroup:=requiredAutSubgroup
								
						);
	if IsBound(input.isoGroup) then	
		requirements.isoGroup:=input.isoGroup;
	fi;

	DL:=BlockDesigns(requirements);
	for tmp in DL do
		tmp.k:=input.k;
		tmp.improper:=input.improper;
		tmp.vType:=input.v;
		tmp.negatives:=Immutable(negatives);
	od;
	results:=ShallowCopy(DL);
	
	if IsBound(input.show_output) and input.show_output = true then
		Print("\n",t,"-((",typeVector[1],", ",typeVector[2],", ",typeVector[3],"), (1,1,1), (",lambdaVectorRCS[1],", ", lambdaVectorRCS[2], ", ",lambdaVectorRCS[3],")) designs\n\n");
	fi;
	return results;
end);

BindGlobal("ProduceLF",function(input)

	#input is a rec. You should, at the very least, include these:
	
		# "v" (list): 	A tuple of positive integers, e.g. [2,4,6]. This means your square 
		# 						has 2 Row, 4 Cols, 6 Symbols
		
	# optional extras:
	
		#lambdas (list): 	A tuple of positive integers for the lambda values VV, VC
		#						(in that order) e.g. [1,1].
		
		# isoLevel (int): as in DESIGN.
		# requiredAutSubgroup (GROUP): as in DESIGN.

		# show_output (BOOL):	Shows a little output about your query.
		# improper (BOOL):		return only proper or improper designs


	local k,t,Y,RS,CS,NrR,NrC,NrS,L0,rl,cl,sl, partition,DL,lambdas,typeVector,lambdaVectorRCS, isoLevel,requiredAutSubgroup,imp,pivot,tmp, imp1, imp2, imp3,results,i,requirements,negatives,blocksAvailable,i2,i3;
	
	if IsBound(input.lambdas) then
		lambdaVectorRCS:=input.lambdas;
	else
		lambdaVectorRCS:=[1,1];
	fi;

	if IsBound(input.isoLevel) then	
		isoLevel:=input.isoLevel;
	else
		isoLevel:=0;
	fi;
	
	if IsBound(input.requiredAutSubgroup) then	
		requiredAutSubgroup:=input.requiredAutSubgroup;
	else
		requiredAutSubgroup:=Group([()]);
	fi;
	
	if IsBound(input.improper) then
		imp:=input.improper;
	else
		imp:=false;
	fi;
	
	k:=[3];
	t:=2;
	negatives:=[];
	
	typeVector:=input.v;
	NrR:=typeVector[1];
	NrC:=typeVector[2];
	
	RS:=Combinations([1..NrR], 2); #verts & verts
	CS:=Cartesian([1..NrR], [NrR+1..NrR+NrC]); #verts & colours

	Y:=Union(RS,CS);	

	L0:=MultisetDifference(Combinations([1..NrR+NrC], 2), Y);	

	blocksAvailable:=Cartesian(RS,[NrR+1..NrR+NrC]);
	for i2 in [1..Size(blocksAvailable)] do
		blocksAvailable[i2]:=Flat(blocksAvailable[i2]);
	od;

	if imp=true then
		pivot:=[1, 2, NrR+1];
		Add(negatives, pivot);
		blocksAvailable:=Difference(blocksAvailable, [pivot]);
		
		imp1:=lambdaVectorRCS[1]+1;
		RS:=MultisetDifference(RS, [[pivot[1], pivot[2]]]);

		imp2:=lambdaVectorRCS[2]+1;
		CS:=MultisetDifference(CS, [[pivot[1], pivot[3]]]);
		CS:=MultisetDifference(CS, [[pivot[2], pivot[3]]]);

		Y:=Union(RS,CS);	
		L0:=MultisetDifference(L0, [[pivot[1], pivot[2]], [pivot[1], pivot[3]], [pivot[2], pivot[3]]]);
	fi;
	blocksAvailable:=DuplicateList(blocksAvailable, Maximum(lambdaVectorRCS)+1);
	
	if imp=true then
		for i3 in [1..Int(Maximum(lambdaVectorRCS)/2)] do
			# add [1,1,6] type blocks to blocksAvailable
			for i in [1..NrR] do
				for i2 in [NrR+1..NrR+NrC] do
					Add(blocksAvailable, [i,i,i2]);
				od;
			od;
		od;
	fi;
		
	if Size(Unique(lambdaVectorRCS)) = 1 then
		partition:=[Y, L0];
		lambdas:=Flat([Unique(lambdaVectorRCS),0]);		
	fi;
	if Size(Unique(lambdaVectorRCS)) = 2 then
		partition:=[RS,CS,L0];		
		lambdas:=Flat([lambdaVectorRCS,0]);
	fi;
	
	if imp=true then
		for tmp in [1..Size(lambdas)] do
			i:=0;
			if imp1 = lambdas[tmp] then
				Add(partition[tmp], Set([pivot[1], pivot[2]]));
				partition[tmp]:=Set(partition[tmp]);
				i:=1;
				break;
			fi;
		od;
		if i = 0 then
			Add(partition, [Set([pivot[1], pivot[2]])]);
			Add(lambdas, imp1);
		fi;
	
		for tmp in [1..Size(lambdas)] do
			i:=0;
			if imp2 = lambdas[tmp] then
				Add(partition[tmp], Set([pivot[1], pivot[3]]));
				Add(partition[tmp], Set([pivot[2], pivot[3]]));
				partition[tmp]:=Set(partition[tmp]);
				i:=1;
				break;
			fi;
		od;
		if i = 0 then
			Add(partition, [Set([pivot[1], pivot[3]]),Set([pivot[2], pivot[3]])]);
			Add(lambdas, imp2);
		fi;
		
	fi;
	for i in [1..Size(partition)] do
		if partition[i]=[] then
			Remove(partition, i);
			Remove(lambdas, i);
		fi;
	od;
	requirements:=rec(	v:=NrC+NrR, 
								blockSizes:=k, 
								tSubsetStructure:=rec(	t:=t,
																partition:=partition,
																lambdas:=lambdas
																),
								isoLevel:=isoLevel,
								requiredAutSubgroup:=requiredAutSubgroup,
								blockDesign:=BlockDesign(NrC+NrR,blocksAvailable)
						);
	DL:=BlockDesigns(requirements);

	for tmp in DL do
		tmp.k:=input.k;
		tmp.vType:=input.v;
		tmp.improper:=input.improper;
	tmp.negatives:=Immutable(negatives);
	od;
	
	results:=ShallowCopy(DL);
	
	if IsBound(input.show_output) and input.show_output = true then
		Print("\n",t,"-((",typeVector[1],", ",typeVector[2],"), (2,1), (",lambdaVectorRCS[1],", ", lambdaVectorRCS[2], ")) designs\n\n");
		Print(requirements,"\n");
	fi;
	return results;
end);

BindGlobal("ProduceSTS",function(input)

	#input is a rec. You should, at the very least, include these:
	
		# v (vector): number of points in your STS
		
	# optional extras:
	
		#lambdas (vector): 
		
		# isoLevel (int): as in DESIGN.
		# requiredAutSubgroup (GROUP): as in DESIGN.

		# show_output (BOOL):	Shows a little output about your query.
		# improper (BOOL):		return only proper or improper designs

	local k,t,Y,L0,Ll,rl,cl,sl, partition,DL,lambdas,typeVector,lambdaVector, isoLevel,requiredAutSubgroup,imp,pivot,tmp, imp1, imp2, imp3,results,i,i2,i3,requirements,negatives,blocksAvailable;

	if IsBound(input.lambdas) then
		lambdaVector:=input.lambdas;
	else
		lambdaVector:=[1];
	fi;

	if IsBound(input.isoLevel) then	
		isoLevel:=input.isoLevel;
	else
		isoLevel:=0;
	fi;
	
	if IsBound(input.requiredAutSubgroup) then	
		requiredAutSubgroup:=input.requiredAutSubgroup;
	else
		requiredAutSubgroup:=Group([()]);
	fi;
	
	if IsBound(input.improper) then
		imp:=input.improper;
	else
		imp:=false;
	fi;
	
	k:=[3];
	t:=2;
	negatives:=[];
	
	Ll:=Combinations([1..input.v[1]],2);
	
	blocksAvailable:=Combinations([1..input.v[1]],3);

	if imp=true then
		pivot:=[1,2,3];
		blocksAvailable:=Difference(blocksAvailable, [pivot]);
		Add(negatives, pivot);
		imp1:=lambdaVector[1]+1;
		Ll:=MultisetDifference(Ll, [[1,2],[1,3],[2,3]]);
	fi;
	blocksAvailable:=DuplicateList(blocksAvailable, lambdaVector[1]+1);

	if imp=true then
		for i3 in [1..Int(lambdaVector[1]/2)] do
			# add [1,1,6] type blocks to blocksAvailable
			for i in [1..input.v[1]] do
				for i2 in [i+1..input.v[1]] do
					Add(blocksAvailable, [i,i,i2]);
				od;
			od;

			# add [1,1,1] type blocks to blocksAvailable
			for i in [1..input.v[1]] do
				Add(blocksAvailable, [i,i,i]);
			od;
		od;
	fi;

	partition:=[Ll];
	lambdas:=lambdaVector;

	if imp=true then
		Add(partition, [Set([pivot[1], pivot[2]])]);
		Add(partition[2], Set([pivot[1], pivot[3]]));
		Add(partition[2], Set([pivot[2], pivot[3]]));
		partition[2]:=Set(partition[2]);
		Add(lambdas, imp1);
	fi;
	requirements:=rec(	v:=input.v[1], 
								blockSizes:=k, 
								tSubsetStructure:=rec(	t:=t,
																partition:=partition,
																lambdas:=lambdas
																),
								isoLevel:=isoLevel,
								blockDesign:=BlockDesign(input.v[1],blocksAvailable),
								requiredAutSubgroup:=requiredAutSubgroup
								
						);

	DL:=BlockDesigns(requirements);
	for tmp in DL do
		tmp.k:=input.k;
		tmp.improper:=input.improper;
		tmp.negatives:=Immutable(negatives);
		tmp.vType:=input.v;
	od;
	results:=ShallowCopy(DL);
	
	if IsBound(input.show_output) and input.show_output = true then
		Print("\n",t,"-((",typeVector[1],", ",typeVector[2],", ",typeVector[3],"), (1,1,1), (",lambdaVector[1],", ", lambdaVector[2], ", ",lambdaVector[3],")) designs\n\n");
	fi;
	return results;
end);


BindGlobal("Produce2Design",function(input)
	if input.k = [1,1,1] then
		return ProduceLS(input);
	fi;
	if input.k = [3] then
		return ProduceSTS(input);
	fi;
	if input.k = [2,1] then
		return ProduceLF(input);
	fi;
end);
