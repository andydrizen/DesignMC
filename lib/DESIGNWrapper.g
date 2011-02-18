################################################################################
# DesignMC/lib/DESIGNWrapper.g	                                Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# A collection of wrappers for the Produce2Design function (which in turn is a 
# wrapper of Soicher's BlockDesigns function.
#
# Also we have separate enumeration functions where the user can set the
# isoLevel (NOTE: setting an isoLevel of 0 in EnumerateXX() is the same as 
# XX() e.g. EnumerateSTS(7, 1, 0) = STS(7, 1).
#
# BlockDesignsModified is a modified version of L H Soicher's DESIGN package
# function called BlockDesigns. It gives the user the ability to ignore the 
# computation of the AutGroup for the given BlockDesign if isoLevel = 0. To use  
# the modification, pass ignoreAutGroupComputationForBlockDesign:=true in the 
# param.
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
	
	k:=[1,1,1];
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
		tmp.k:=k;
		tmp.improper:=imp;
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
	
	k:=[2,1];
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
		tmp.k:=k;
		tmp.vType:=input.v;
		tmp.improper:=imp;
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
		tmp.k:=k;
		tmp.improper:=imp;
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

BindGlobal("LS",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n,n,n], k:=[1,1,1], lambdas:=[lambdaInt,lambdaInt,lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("ILS",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n,n,n], k:=[1,1,1], improper:=true, lambdas:=[lambdaInt,lambdaInt,lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("LF",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n,n-1], k:=[2,1], lambdas:=[lambdaInt,lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("ILF",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n,n-1], k:=[2,1],improper:=true,  lambdas:=[lambdaInt,lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("STS",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n], k:=[3], lambdas:=[lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("ISTS",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n], k:=[3],improper:=true, lambdas:=[lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

#
# Enumeration functions (like above but with an isoLevel option).
#

BindGlobal("EnumerateLS",function(n,lambdaInt, isoLevel)
	return Produce2Design( rec(v:=[n,n,n], k:=[1,1,1], lambdas:=[lambdaInt,lambdaInt,lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateILS",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n,n,n], k:=[1,1,1], improper:=true, lambdas:=[lambdaInt,lambdaInt,lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateLF",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n,n-1], k:=[2,1], lambdas:=[lambdaInt,lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateILF",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n,n-1], k:=[2,1],improper:=true,  lambdas:=[lambdaInt,lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateSTS",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n], k:=[3], lambdas:=[lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateISTS",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n], k:=[3], improper:=true, lambdas:=[lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("BlockDesignsModified",function(param)
#
# Function to classify block designs with given properties. 
#
# These block designs need not be simple and block sizes 
# need not be constant.  These block designs need not even be
# binary, although this is the default.
#
local t,v,b,blocksizes,k,lambda,blocknumbers,blockmaxmultiplicities,
   r,blockintersectionnumbers,isolevel,C,G,B,N,ntflags,
   act,rel,weightvector,gamma,KK,L,S,s,hom,GG,CC,NN,leastreps,
   clique,ans,blockbags,c,d,i,j,jj,issimple,allbinary,tsubsetstructure,
   blocks,blockdesign,A,kk,AA,tsubsets,maxlambda,targetvector,weightvectors,
   designinfo,lambdavec,lambdamat,m,T,bb,justone,isnormal,issylowtowergroup,
   testfurther;

act := function(x,g) 
# The boolean variable  allbinary  is global, and  allbinary=true 
# iff all possible blocks are sets.
if allbinary or IsSet(x.comb) then
   return rec(comb:=OnSets(x.comb,g),mult:=x.mult); 
else
   return rec(comb:=OnMultisetsRecursive(x.comb,g),mult:=x.mult); 
fi;
end;
             
weightvector := function(x)
# param, v, t, blocksizes, and tsubsets are global
local wv,c,i,xx;
wv:=ListWithIdenticalEntries(Length(tsubsets),0);
xx:=ListWithIdenticalEntries(v,0);
for i in x.comb do 
   xx[i]:=xx[i]+1;
od;
for c in Combinations(Set(x.comb),t) do
   wv[PositionSorted(tsubsets,c)]:=x.mult*Product(xx{c});
od;
if IsBound(param.r) then 
   Append(wv,x.mult*xx);
fi;
if IsBound(param.blockNumbers) then 
   for i in [1..Length(blocksizes)] do
      if Length(x.comb)=blocksizes[i] then
         Add(wv,x.mult);
      else
         Add(wv,0);
      fi;
   od;
fi;
if IsBound(param.b) then
   Add(wv,x.mult);
fi;
return wv;
end;
rel := function(x,y) 
# v, blocksizes, targetvector, blockbags, weightvectors, 
# and blockintersectionnumbers are global.
# The parameters x and y are indices into blockbags (and weightvectors).
local i,xx,yy,s;
if blockbags[x].comb=blockbags[y].comb then
   return false;
fi;
s:=weightvectors[x]+weightvectors[y];
if HasLargerEntry(s,targetvector) then
   return false;
fi;
if allbinary or (IsSet(x) and IsSet(y)) then
   s:=Size(Intersection(blockbags[x].comb,blockbags[y].comb));
else 
   xx:=ListWithIdenticalEntries(v,0);
   yy:=ListWithIdenticalEntries(v,0);
   for i in blockbags[x].comb do 
      xx[i]:=xx[i]+1;
   od;
   for i in blockbags[y].comb do 
      yy[i]:=yy[i]+1;
   od;
   s:=0;
   for i in [1..v] do
      s:=s+Minimum(xx[i],yy[i]);
   od;
fi;
return 
   s in blockintersectionnumbers[Position(blocksizes,Length(blockbags[x].comb))][Position(blocksizes,Length(blockbags[y].comb))]; 
end;

#
# begin BlockDesigns
# 
if not IsRecord(param) then
   Error("usage: BlockDesigns( <Record> )");
fi;
param:=ShallowCopy(param);
if not IsSubset(["v","blockSizes","tSubsetStructure","blockDesign",
                 "blockMaxMultiplicities","blockIntersectionNumbers",
		 "r","blockNumbers","b","isoLevel","isoGroup",
		 "requiredAutSubgroup","ignoreAutGroupComputationForBlockDesign"], 
                RecNames(param)) then
   Error("<param> contains an invalid component-name");
fi;   
if not IsSubset(RecNames(param),["v","blockSizes","tSubsetStructure"]) then
   Error("<param> missing a required component");
fi;   
v:=param.v;
if not IsPosInt(v) then
   Error("<param>.v must be positive integer");
fi;
blocksizes:=ShallowCopy(param.blockSizes);
if not (IsSet(blocksizes) and blocksizes<>[] and ForAll(blocksizes,IsPosInt)) then
   Error("<param>.blockSizes must be a non-empty set of positive integers"); 
fi;
if Length(blocksizes)=1 then 
   k:=blocksizes[1];
fi;
if not IsBound(param.blockDesign) then
   allbinary:=true;
else
   allbinary:=IsBinaryBlockDesign(param.blockDesign);
fi;
# Note: allbinary=true iff all possible blocks are sets.
tsubsetstructure:=ShallowCopy(param.tSubsetStructure);
if not ForAll(tsubsetstructure.lambdas,x->IsInt(x) and x>=0) then
   Error("all <param>.tSubsetStructure.lambdas must be non-negative integers");
fi;
if not IsDuplicateFree(tsubsetstructure.lambdas) then
   Error("<param>.tSubsetStructure.lambdas must not contain duplicates");
fi;
if IsBound(tsubsetstructure.partition) then
   if Length(tsubsetstructure.partition)<>Length(tsubsetstructure.lambdas) then
      Error("<param>.tSubsetStructure.partition must have the same length\n",
            "as <param>.tSubsetStructure.lambdas");
   fi;
elif Length(tsubsetstructure.lambdas)<>1 then
   Error("must have Length(<param>.tSubsetStructure.lambdas)=1\n",
         "if <param>.tSubsetStructure.partition is unbound");
fi;
t:=tsubsetstructure.t;
if not (IsInt(t) and t>=0 and t<=v) then
   Error("<t> must be an integer with 0<=<t><=<v>");
fi;
if not ForAll(blocksizes,x->x>=t) then 
   Error("each element of <blocksizes> must be >= <t>");
fi;
if IsBound(tsubsetstructure.partition) then
   # check it
   if not ForAll(tsubsetstructure.partition,x->IsSet(x) and x<>[]) then 
      Error("the parts of the t-subset partition must be non-empty sets");
   fi;
   c:=Concatenation(tsubsetstructure.partition);
   if not ForAll(c,x->IsSet(x) and Size(x)=t) then
      Error("the parts of the t-subset partition must be sets of t-subsets");
   fi;
   if Length(c)<>Binomial(v,t) or Length(Set(c))<>Binomial(v,t) then
      Error("t-subset partition is not a partition of the t-subsets");
   fi;
fi;
maxlambda:=Maximum(tsubsetstructure.lambdas);
if maxlambda<1 then
   Error("at least one element of <param>.tSubsetStructure.lambdas must be positive");
fi;
if Length(tsubsetstructure.lambdas)=1 then
   # constant lambda 
   lambda:=tsubsetstructure.lambdas[1];
fi;
tsubsets:=Combinations([1..v],t);
if IsBound(param.blockMaxMultiplicities) then
   blockmaxmultiplicities:=ShallowCopy(param.blockMaxMultiplicities);
   if not (IsList(blockmaxmultiplicities) and ForAll(blockmaxmultiplicities,x->IsInt(x) and x>=0)) then
      Error("<param>.blockMaxMultiplicities must be a list of non-negative integers");
   fi;   
   if Length(blockmaxmultiplicities)<>Length(blocksizes) then 
      Error("must have Length(<param>.blockMaxMultiplicities)=Length(<param>.blockSizes)");
   fi;
   blockmaxmultiplicities:=List(blockmaxmultiplicities,x->Minimum(x,maxlambda));
   # since *every* possible block is required to contain at least 
   # t  distinct points.
else 
   blockmaxmultiplicities:=ListWithIdenticalEntries(Length(blocksizes),maxlambda);
fi;
if IsBound(param.blockIntersectionNumbers) then
   blockintersectionnumbers:=StructuralCopy(param.blockIntersectionNumbers);
   if Length(blockintersectionnumbers)<>Length(blocksizes) then 
      Error("must have Length(<param>.blockIntersectionNumbers>)=Length(<param>.blockSizes>)");
   fi;
   blockintersectionnumbers:=List(blockintersectionnumbers,x->List(x,Set));
   if blockintersectionnumbers<>TransposedMat(blockintersectionnumbers) then
      Error("<blockintersectionnumbers> must be a symmetric matrix");
   fi;
else 
   blockintersectionnumbers:=List([1..Length(blocksizes)],x->List([1..Length(blocksizes)],
                      y->[0..Minimum(blocksizes[x],blocksizes[y])]));
fi;
if allbinary and maxlambda<=1 then 
   blockintersectionnumbers:=List(blockintersectionnumbers,x->List(x,y->Intersection(y,[0..t-1])));
fi;
# Compute the number  ntflags  of (t-subset,block)-flags 
# (counting multiplicities). 
if IsBound(lambda) then
   ntflags:=lambda*Binomial(v,t); 
else
   ntflags:=tsubsetstructure.lambdas*List(tsubsetstructure.partition,Length);
fi;
if IsBound(param.blockNumbers) then
   blocknumbers:=ShallowCopy(param.blockNumbers);
   # We will require  blocknumbers[i]  blocks of size  blocksizes[i] 
   # for i=1,...,Length(blocknumbers).
   if not (IsList(blocknumbers) and ForAll(blocknumbers,x->IsInt(x) and x>=0)) then
      Error("<param>.blockNumbers must be a list of non-negative integers"); 
   fi;
   if Length(blocknumbers)<>Length(blocksizes) then
      Error("must have Length(<param>.blockNumbers)=Length(<param>.blockSizes)");
   fi;
   b:=Sum(blocknumbers);
   if b=0 then
      Error("At least one element of <param>.blockNumbers must be positive");  
   fi;
   if allbinary and IsBound(ntflags) then 
      # compute the number  s  of (t-subset,block)-flags and compare to  ntflags
      s:=Sum([1..Length(blocknumbers)],i->blocknumbers[i]*Binomial(blocksizes[i],t));
      if s<>ntflags then
         return [];
      fi;
   fi;
   if t=0 and tsubsetstructure.lambdas[1]<>Sum(blocknumbers) then 
      # contradictory blocknumbers
       return [];
   fi;
fi;
if IsBound(param.b) then
   # We will require exactly  param.b > 0 blocks.
   if not IsPosInt(param.b) then
      Error("<param>.b must be a positive integer");  
   fi;
   if IsBound(b) and b<>param.b then
      # required block design cannot have  param.b  blocks. 
      return [];
   fi;
   b:=param.b;
   if IsBound(k) and allbinary and IsBound(ntflags) and
      b<>ntflags/Binomial(k,t) then
      # required block design cannot exist. 
      return [];
   fi;
fi;
if IsBound(param.r) then
   # We will require constant replication number = param.r > 0.
   if not IsPosInt(param.r) then
      Error("<param>.r must be a positive integer");
   fi;
   r:=param.r;
fi;
if t>=1 and allbinary and IsBound(k) and IsBound(lambda) and k<=v then
   # compute the replication number  s  (and compare to  r,  if bound).
   s:=lambda*Binomial(v-1,t-1)/Binomial(k-1,t-1);
   if not IsInt(s) or IsBound(r) and r<>s then
      # no possible design
      return [];
   else 
      r:=s;
   fi;
fi;
if t=1 and IsBound(lambda) then
   # compute the replication number  s  (and compare to  r,  if bound).
   s:=lambda;
   if IsBound(r) and r<>s then
      # no possible design
      return [];
   else 
      r:=s;
   fi;
fi;
if allbinary and IsBound(k) and IsBound(lambda) then
   if k>v then
      # requirements force at least one block, but this is impossible
      return [];
   fi;
   #
   # We now have v,k,lambda>0, 0<=t<=k<=v, 
   # and are looking for t-(v,k,lambda) designs. 
   #
   s:=TDesignLambdas(t,v,k,lambda);
   if s=fail then
      # parameters t-(v,k,lambda) inadmissible
      return [];
   fi;
   blockmaxmultiplicities[1]:=Minimum(blockmaxmultiplicities[1],
      TDesignBlockMultiplicityBound(t,v,k,lambda));
   if blockmaxmultiplicities[1]<1 then
      return [];
   fi;
   if t>=2 then 
      if k<v and s[1]=v then
         # Possible SBIBD; each pair of distinct blocks must meet 
         # in exactly  s[3]  points.
         blockintersectionnumbers[1][1]:=
            Intersection(blockintersectionnumbers[1][1],[s[3]]);
      fi;
      designinfo:=rec(lambdavec:=Immutable(s));
      if lambda=1 then
         # We are looking for Steiner systems, so we know how many blocks
         # intersect a given block in a given number of points.
         designinfo.blockmmat:=[];
         T:=SteinerSystemIntersectionTriangle(t,v,k);
         T:=List([1..k+1],i->Binomial(k,i-1)*T[i][k+2-i]);
         designinfo.blockmmat[k]:=Immutable(T);
         for i in [0..k-1] do
            if T[i+1]=0 then
               RemoveSet(blockintersectionnumbers[1][1],i);
            fi;
         od;
      fi;
   fi;   
   if blockintersectionnumbers[1][1]=[] and s[1]>1 then
      return [];
   fi;
elif allbinary and t=2 and IsBound(lambda) then
   # We are looking for pairwise-balanced designs. 
   if (lambda*(v-1)) mod Gcd(List(blocksizes,x->x-1)) <> 0 then
      return [];
   fi;
   if (lambda*v*(v-1)) mod Gcd(List(blocksizes,x->x*(x-1))) <> 0 then
      return [];
   fi;
   if IsBound(b) then
      if b<lambda*Binomial(v,2)/Binomial(Maximum(blocksizes),2) 
         # b is too small
         or b>lambda*Binomial(v,2)/Binomial(Minimum(blocksizes),2) then
         # or b is too big
         return [];
      fi;
      if not (v in blocksizes) and b<v then
         # Generalized Fisher inequality is not satisfied.
         return [];
      fi;
   elif not (v in blocksizes) and 
      lambda*Binomial(v,2)/Binomial(Minimum(blocksizes),2)<v then
      # Generalized Fisher inequality is not satisfied.
      return [];
   fi;
   if IsBound(r) and IsBound(b) then
      designinfo:=rec(lambdavec:=Immutable([b,r,lambda]));
   fi;
elif allbinary and t=2 and IsBound(k) then
   lambdamat:=NullMat(v,v,Rationals);
   for i in [1..Length(tsubsetstructure.partition)] do
      for c in tsubsetstructure.partition[i] do
         lambdamat[c[1]][c[2]]:=tsubsetstructure.lambdas[i];
         lambdamat[c[2]][c[1]]:=lambdamat[c[1]][c[2]];
      od;
   od;
   for i in [1..v] do
      lambdamat[i][i]:=Sum(lambdamat[i])/(k-1);
      if not IsInt(lambdamat[i][i]) or 
        (IsBound(r) and lambdamat[i][i]<>r) then
         return [];
      fi;
   od; 
   if ForAll([1..v],i->lambdamat[i][i]=lambdamat[1][1]) then
      r:=lambdamat[1][1];
   fi;
   bb:=Sum(List([1..v],i->lambdamat[i][i]))/k;
   if not IsInt(bb) or (IsBound(b) and b<>bb) then 
      return [];
   else
      b:=bb;
   fi;
   if IsBound(r) then
      designinfo:=
         rec(lambdavec:=Immutable([b,r]),lambdamat:=Immutable(lambdamat));
   else
      designinfo:=
         rec(lambdavec:=Immutable([b]),lambdamat:=Immutable(lambdamat));
   fi;
fi;
for i in [1..Length(blockmaxmultiplicities)] do 
   if blockmaxmultiplicities[i]>1 and 
      not (blocksizes[i] in blockintersectionnumbers[i][i]) then 
      blockmaxmultiplicities[i]:=1;
   fi;
od;
if IsBound(designinfo) and Length(designinfo.lambdavec)>=3 then
   # Apply bound of Cameron and Soicher to each block max-multiplicity, 
   # and each block intersection size. 
   if Length(designinfo.lambdavec) mod 2 = 0 then
      lambdavec:=designinfo.lambdavec{[1..Length(designinfo.lambdavec)-1]};
   else
      lambdavec:=designinfo.lambdavec;
   fi;
   for i in [1..Length(blockmaxmultiplicities)] do
      m:=ListWithIdenticalEntries(blocksizes[i]+1,0);
      while m[blocksizes[i]+1]<=blockmaxmultiplicities[i] and 
         BlockIntersectionPolynomialCheck(m,lambdavec) do
         m[blocksizes[i]+1]:=m[blocksizes[i]+1]+1;
      od;
      blockmaxmultiplicities[i]:=m[blocksizes[i]+1]-1;
      if blockmaxmultiplicities[i]<0 then
         return [];
      fi;
      for jj in [0..blocksizes[i]] do
         m:=ListWithIdenticalEntries(blocksizes[i]+1,0);
         m[blocksizes[i]+1]:=1;
         m[jj+1]:=m[jj+1]+1;
         if not BlockIntersectionPolynomialCheck(m,lambdavec) then
            for j in [1..Length(blockmaxmultiplicities)] do
               RemoveSet(blockintersectionnumbers[i][j],jj);
            od;
         fi;
      od;
   od;
fi;
if ForAll(blockmaxmultiplicities,x->x=0) then
   # no blocks, but the given parameters force at least one block
   return [];
fi;
if IsBound(param.isoLevel) then 
   isolevel:=param.isoLevel;
else
   isolevel:=2;
fi;
if IsBound(param.blockDesign) then
   # We are computing subdesigns of  param.blockDesign
   if not IsBlockDesign(param.blockDesign) then
      Error("<param>.blockDesign must be a block design");
   fi;
   if v<>param.blockDesign.v then
      Error("must have <param>.v=<param>.blockDesign.v");
   fi;
fi;
if IsBound(param.isoGroup) then
   G:=param.isoGroup;
   # 
   # G  must preserve the point-set structure of the required subdesign(s),
   # as well as the multiset  param.blockDesign.blocks  
   # (if  param.blockDesign is given).  
   #
   if not IsPermGroup(G) or v<LargestMovedPoint(GeneratorsOfGroup(G)) then 
      Error("<param>.isoGroup must be a permutation group on [1..<v>]");
   fi;
   if IsBound(tsubsetstructure.partition) then
      for i in [1..Length(tsubsetstructure.partition)-1] do
         s:=tsubsetstructure.partition[i];
         if not ForAll(GeneratorsOfGroup(G),x->OnSetsSets(s,x)=s) then
            Error("t-subset structure not invariant under <param>.isoGroup");
         fi;
      od;
   fi;
   if IsBound(param.blockDesign) then 
      s:=param.blockDesign.blocks;
      if not ForAll(GeneratorsOfGroup(G),x->OnMultisetsRecursive(s,x)=s) then
         Error("<param>.blockDesign.blocks not invariant under <param>.isoGroup");
      fi;
   fi;
else
   if IsBound(param.blockDesign) then
      if (IsBound(param.ignoreAutGroupComputationForBlockDesign) and param.isoLevel=0) then
            G:=Group(());
	  else
            G:=AutGroupBlockDesign(param.blockDesign);
      fi;
   else
      G:=SymmetricGroup(v);
      SetSize(G,Factorial(v));
   fi;
   if IsBound(tsubsetstructure.partition) and 
      Length(tsubsetstructure.partition)>1 then
      # G:=the subgroup of G fixing the t-subset structure (ordered) partition
      hom:=ActionHomomorphism(G,tsubsets,OnSets,"surjective");
      GG:=Image(hom);
      StabChainOp(GG,rec(limit:=Size(G)));
      for i in [1..Length(tsubsetstructure.partition)-1] do
         GG:=Stabilizer(GG,
             List(tsubsetstructure.partition[i],x->PositionSorted(tsubsets,x)),
             OnSets);
      od;
      G:=PreImage(hom,GG);
   fi;
fi;
if IsBound(param.requiredAutSubgroup) then 
   if not IsSubgroup(G,param.requiredAutSubgroup) then
      Error("<param>.requiredAutSubgroup must be a subgroup of <G>");
   fi;
   C:=param.requiredAutSubgroup;
else
   C:=Group(());
fi;
C:=AsSubgroup(G,C);
if IsBound(param.blockDesign) then
   B:=Collected(param.blockDesign.blocks);
   blockbags:=[]; # initialize list of possible blocks and multiplicities
   for c in B do 
      if IsSet(c[1]) then
         s:=c[1];
      else 
         s:=Set(c[1]);
      fi;
      if Length(s)<t then
         Error("cannot give possible block with fewer than <t> distinct elements");
      fi;
      if Length(c[1]) in blocksizes then
         # cannot reject this possible block out of hand
         d:=blockmaxmultiplicities[Position(blocksizes,Length(c[1]))];
         for i in Reversed([1..Minimum(c[2],d)]) do 
            Add(blockbags,rec(comb:=c[1],mult:=i)); 
         od;
      fi;
   od;
else 
   for i in [1..Length(blocksizes)] do
      if blocksizes[i]>v then
         blockmaxmultiplicities[i]:=0;
         # since allbinary=true here
      fi;
   od;
   if ForAll(blockmaxmultiplicities,x->x=0) then
      # no blocks, but the given parameters force at least one block
      return [];
   fi;
   blockbags:=Concatenation(List(Reversed([1..Length(blocksizes)]),i->
       List(Cartesian(Reversed([1..blockmaxmultiplicities[i]]),
               Combinations([1..v],blocksizes[i])),
               x->rec(mult:=x[1],comb:=x[2]))));
fi;
if IsBound(lambda) then 
   targetvector:=ListWithIdenticalEntries(Length(tsubsets),lambda);
else
   targetvector:=[];
   for i in [1..Length(tsubsetstructure.lambdas)] do
      for c in tsubsetstructure.partition[i] do
         targetvector[PositionSorted(tsubsets,c)]:=tsubsetstructure.lambdas[i];
      od;
   od;
fi;
if IsBound(param.r) then 
   targetvector:=Concatenation(targetvector,ListWithIdenticalEntries(v,r));
fi;
if IsBound(param.blockNumbers) then 
   Append(targetvector,blocknumbers);
fi;
if IsBound(param.b) then 
   Add(targetvector,b);
fi;
hom:=ActionHomomorphism(G,blockbags,act,"surjective");
GG:=Image(hom);
StabChainOp(GG,rec(limit:=Size(G)));
weightvectors:=List(blockbags,weightvector); # needed for function  rel
# Determine the least C-orbit representatives for the action
# of C on the positions in weightvectors.
L:=List(OrbitsDomain(C,tsubsets,OnSets),Minimum);
leastreps:=Set(List(L,x->PositionSorted(tsubsets,x)));
s:=Length(tsubsets);
if IsBound(param.r) then
   Append(leastreps,Set(List(OrbitsDomain(C,[1..v]),x->s+Minimum(x)))); 
   s:=s+v;
fi;
if IsBound(param.blockNumbers) then
   Append(leastreps,[s+1..s+Length(blocknumbers)]);
   s:=s+Length(blocknumbers);
fi;
if IsBound(param.b) then
   Add(leastreps,s+1);
fi;
# Make graph on "appropriate" collapsed Image(hom,C)-orbits.
CC:=Image(hom,C);
StabChainOp(CC,rec(limit:=Size(C)));
N:=Normalizer(G,C);
NN:=Image(hom,N);
StabChainOp(NN,rec(limit:=Size(N)));
S:=OrbitsDomain(NN,[1..Length(blockbags)]);
L:=[]; # initialize list of appropriate CC-orbits
for s in S do
   c:=Orbit(CC,s[1]);
   # check if  c  is appropriate
   if (not IsBound(designinfo) or PartialDesignCheck(designinfo,blockbags[c[1]].comb,blockbags{c})) and
      ForAll([2..Length(c)],x->rel(c[1],c[x])) and
      not HasLargerEntry(Sum(weightvectors{c}),targetvector) then
      #  c  is appropriate 
      Append(L,Orbit(NN,Set(c),OnSets));
   fi;
od;
testfurther:=IsBound(designinfo) and Size(NN)/Size(CC)>=Length(L); 
gamma:=Graph(NN,L,OnSets,
   function(x,y)
   local c;
   if not ForAll(y,z->rel(x[1],z)) or HasLargerEntry(
      Sum(weightvectors{x})+Sum(weightvectors{y}),targetvector) then
      return false;
   fi;
   if not testfurther then
      return true;
   fi;
   c:=Concatenation(blockbags{x},blockbags{y});
   return PartialDesignCheck(designinfo,blockbags[x[1]].comb,c) and 
      PartialDesignCheck(designinfo,blockbags[y[1]].comb,c); 
   end,
  true);     
KK:=CompleteSubgraphsMain(gamma,targetvector{leastreps},isolevel,
      false,false,
      List(gamma.names,x->Sum(weightvectors{x}){leastreps}),
      [1..Length(leastreps)]);
KK:=List(KK,x->rec(clique:=Union(List(x,y->gamma.names[y]))));
if isolevel=0 and Length(KK)>0 then
   # Compute the G-stabilizer of the single design.
   KK[1].stabpreim:=PreImage(hom,Stabilizer(GG,KK[1].clique,OnSets));
fi;
if isolevel=2 then
   #
   # Compute the G-stabilizers of the designs, and perform
   # any GG-isomorph rejection which is not already known to 
   # have been performed by  Image(hom,Normalizer(G,C)).
   #
   justone:=Length(KK)=1;
   if not justone then
      isnormal:=IsNormal(G,C);
      if not isnormal then
         issylowtowergroup:=IsSylowTowerGroupOfSomeComplexion(C);
      fi;
   fi;
   L:=[];
   S:=[];
   for kk in KK do
      AA:=Stabilizer(GG,kk.clique,OnSets);
      A:=PreImage(hom,AA);
      kk.stabpreim:=A;
      if justone or isnormal or Size(C)=Size(A) or 
         Gcd(Size(C),Size(A)/Size(C))=1 and (issylowtowergroup or IsSolvableGroup(A)) or
         IsCyclic(C) and IsNilpotentGroup(A) and 
            ForAll(Set(FactorsInt(Size(C))),
               p->Index(A,SubgroupNC(A,List(GeneratorsOfGroup(A),g->g^p)))=p) or
         IsSimpleGroup(C) and IsNormal(A,C) and (Size(A) mod (Size(C)^2) <> 0) 
            then
         # KK  has just one element  or  C is normal in G  or  
         # C=A  or  C is a Hall subgroup of A and C has a Sylow tower  or
         # A is solvable and C is a Hall subgroup of A  or
         # A is nilpotent and C is contained in a cyclic
         # Hall pi(C)-subgroup of A  or
         # C is a simple normal subgroup of A and is the only
         # subgroup of A of its isomorphism type. 
         # Thus, Length(KK)=1  or  C is normal in G,  or
         # C is a "friendly" subgroup of A
         # (see: L.H. Soicher, Computational group theory problems arising 
         # from computational design theory, Oberwolfach Rep. 3 (2006), 
         # Report 30/2006: Computational group theory, 1809-1811,  
         # (preprint at: http://designtheory.org/library/preprints/ ), and
         # P. Hall, Theorems like Sylow's, Proc. LMS 6, 1956).
         # It follows that isomorph-rejection of GG-images of kk.clique 
         # has already been handled by  Image(hom,Normalizer(G,C)),  
         # and so no further isomorph-rejection (using GG) is needed.
         Add(L,kk);
      else
         s:=SmallestImageSet(GG,kk.clique,AA);
         if not (s in S) then 
            Add(S,s);
            Add(L,kk);
         fi;
      fi;
   od;
   KK:=L; 
fi;
ans:=[];
for kk in KK do
   blocks:=[];
   issimple:=true;
   for c in kk.clique do
      if blockbags[c].mult>1 then 
         issimple:=false;
      fi;
      for d in [1..blockbags[c].mult] do
         Add(blocks,blockbags[c].comb);
      od;
   od;
   blockdesign:=rec(isBlockDesign:=true,v:=v,blocks:=AsSortedList(blocks),
      tSubsetStructure:=Immutable(tsubsetstructure),  
      isBinary:=allbinary or ForAll(blocks,IsSet),isSimple:=issimple);
   blockdesign.blockSizes:=BlockSizes(blockdesign); 
   blockdesign.blockNumbers:=BlockNumbers(blockdesign);
   c:=ReplicationNumber(blockdesign);
   if c<>fail then
      blockdesign.r:=c;
   fi;
   if isolevel<>1 then
      if not IsBound(param.isoGroup) and 
         ( not IsBound(param.blockDesign) or 
            IsBound(param.blockDesign.autGroup) and 
               param.blockDesign.autGroup=SymmetricGroup(v) ) then
         blockdesign.autGroup:=kk.stabpreim;
      else 
         blockdesign.autSubgroup:=kk.stabpreim;
      fi;
   fi;
   if IsBound(param.blockDesign) and IsBound(param.blockDesign.pointNames) then
      blockdesign.pointNames:=Immutable(param.blockDesign.pointNames);
   fi;
   Add(ans,blockdesign);
od;
if (IsBound(param.ignoreAutGroupComputationForBlockDesign) and param.isoLevel=0) then
	Unbind(ans[1].autSubgroup);
fi;
return ans;
end);