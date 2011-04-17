################################################################################
# DesignMC/lib/LatinSquareAnalysis.g                            Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# FindTransversal
# FindAllTransversals
#
# PartialTransversalsBruteForce will (in a brute force fashion) try to find all partial 
# transversals.
# 
# FindAllTransversalsBruteForce will filter PartialTransversals to remove any items
# which are not full transversals.
#
################################################################################

BindGlobal("FindTransversal2",function(Design,lambda, enhance)
	if enhance then
		return BlockDesignsModified(
			rec(
			    v:=Design.v, 
				blockDesign:=Design,
			    blockSizes:=[3],
			    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
			    isoLevel:=0,
				isoGroup:=Group(())
			)
		);
	else
		return BlockDesigns(
			rec(
			    v:=Design.v, 
				blockDesign:=Design,
			    blockSizes:=[3],
			    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
			    isoLevel:=0
			)
		);
	fi;
end);

BindGlobal("FindTransversal",function(Design,lambda, enhance)
	if enhance then
		return BlockDesignsModified(
			rec(
			    v:=Design.v, 
				blockDesign:=Design,
			    blockSizes:=[3],
			    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
			    isoLevel:=0,
				ignoreAutGroupComputationForBlockDesign:=true
			)
		);
	else
		return BlockDesigns(
			rec(
			    v:=Design.v, 
				blockDesign:=Design,
			    blockSizes:=[3],
			    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
			    isoLevel:=0
			)
		);
	fi;
end);

BindGlobal("FindAllTransversals",function(Design,lambda,enhance)
	if enhance then
		return BlockDesignsModified(
			rec(
			    v:=Design.v, 
				blockDesign:=Design,
			    blockSizes:=[3],
			    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
			    isoLevel:=2,
				isoGroup:=Group(()),
				ignoreAutGroupComputationForBlockDesign:=enhance
			)
		);
	else
		return BlockDesigns(
			rec(
			    v:=Design.v, 
				blockDesign:=Design,
			    blockSizes:=[3],
			    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
			    isoLevel:=2,
				isoGroup:=Group(())
			)
		);
	fi;
end);

# dependencies: 	GetMutableListList, Sort2, SortListList, DuplicateList, get_blocks_containing_list,
#					ShowPercentIndicatorSimple, MultisetDifference

#
# Don't know how to do BindGlobal with recursive functions
#

PartialTransversalsBruteForce:=function( D, lambda, findAll, depth )
local i,j,k,transversal,all_transversals,chosen_block,sub_design_blocks,tmp,D2,E,tmp_point_set,m;
	D2:=ShallowCopy(D);
	all_transversals:=[];
	if( not IsBound(D2.point_set) ) then
	
		# all of the initial setup happens here
	
		D2.blocks:=GetMutableListList(D2.blocks);
		for i in [1..Size(D2.blocks)] do
			Add(D2.blocks[i],[i]);
		od;
		D2.blocks:=SortListList(D2.blocks);
		D2.v:=D2.v+Size(D2.blocks);
		D2.point_set:=Sort2(DuplicateList([1..(D2.v-Size(D2.blocks))],lambda));
	fi;
	
	for i in [1..Size(get_blocks_containing_list(D2, [D2.blocks[1][1]]))] do
	
		if (IsBound(D2.tSubsetStructure)) then
			m:=D2.tSubsetStructure.lambdas[1];
		else
			m:=1;
		fi;
	
		if(depth = 1 and findAll = true) then
			ShowPercentIndicatorSimple(i-1,m*(D2.v-Size(D2.blocks))/3);
		fi;
	
		tmp_point_set:=ShallowCopy(D2.point_set);
		chosen_block:=get_blocks_containing_list(D2, [D2.blocks[1][1]])[i];
		
		sub_design_blocks:=ShallowCopy(D2.blocks);
		sub_design_blocks:=MultisetDifference(sub_design_blocks, [chosen_block]);
		for j in chosen_block do
			tmp_point_set:=MultisetDifference(tmp_point_set, [j]);
			if ( not( j in tmp_point_set )) then
				sub_design_blocks:=MultisetDifference(sub_design_blocks, get_blocks_containing_list(D2, [j]));
			fi;
		od;
		
		if (Size(sub_design_blocks) > 0) then
			# we haven't yet made a full transversal.
			E:=BlockDesign(D2.v, sub_design_blocks);
			E.point_set:=ShallowCopy(tmp_point_set);
			tmp:=PartialTransversalsBruteForce(E,lambda, findAll, depth+1);
			for j in tmp do
				transversal:=[];
				for k in j do
					Add(transversal, k);
				od;
				
				Add(transversal, chosen_block[4]);
				Add(all_transversals,Flat(transversal));
			od;
		else
			Add(all_transversals,[chosen_block[4]]);
		fi;
		if(findAll = false ) then
			for transversal in all_transversals do
				if(Size(transversal) = (D2.v-Size(D2.blocks))/3 ) then
					return Unique(SortListList(all_transversals));
				fi;
			od;
		fi;
	od;
	return Unique(SortListList(all_transversals));
end;

BindGlobal("FindAllTransversalsBruteForce",function(input)

	# Finds a set of lambda*n cells, lambda in each row,
	# lambda in each column and each symbol appears in 
	# the cells lambda times.

	local D2,partials,results,i,j,results2,tmp,plambda,pfindAll;
	if not (IsRecord(input) ) then 
	   Error("<input> must be a record containing, at the very least, a BlockDesign.");
	fi;
	
	if ( IsBound(input.BlockDesign) and IsBlockDesign(input.BlockDesign)=true) then
		D2:=ShallowCopy(input.BlockDesign);
	else
		Error("<input>.BlockDesign must be the BlockDesign you want work with.");
	fi;
	
	if IsBound(input.lambda) then
		plambda:=input.lambda;
	else
		plambda:=1;
	fi;
	
	if IsBound(input.findAll) then
		pfindAll:=input.findAll;
	else
		pfindAll:=false;
	fi;
	
	partials:=PartialTransversalsBruteForce(D2, plambda, pfindAll,1);
	results:=[];
	for i in partials do
		if (Size(i) = D2.v/3 * plambda) then
			Add(results, i);
		fi;
	od;
	
	results2:=[];
	for i in results do
		tmp:=[];
		for j in i do
			Add(tmp, D2.blocks[j]);
		od;
		Add(results2, BlockDesign(D2.v,tmp));
	od;
	if (pfindAll = false) then
		return results2;
	fi;
	
	return results2;
end);

FindAllSubSquaresOfSizeImproved:=function(D, subsquareSize)
	local rowsInSubSquare, colsInSubSquare, i, j, k,l,m, blocks,symbols, results, B;
	results:=[];
	for i in Combinations([1..D.vType[1]],subsquareSize) do
		rowsInSubSquare:=i;
		for j in Combinations([D.vType[1]+1..2*D.vType[1]],subsquareSize) do
			colsInSubSquare:=j;
			blocks:=[];
			symbols:=[];
			for k in Cartesian(rowsInSubSquare,colsInSubSquare) do
				for l in get_blocks_containing_list(D, k) do
					Add(symbols, l[3]);
					Add(blocks, l);
				od;

				for m in Combinations(blocks, subsquareSize*subsquareSize) do
					if Size(Unique(Flat(m))) = subsquareSize*3 then
						B:=BlockDesign(D.v, m);
						B.k:=[1,1,1];
						B.improper:=D.improper;
						Add(results,B);
					fi;
				od;
			od;
		od;
	od;
	return results;
end;

BindGlobal("FindAllSubSquaresOfSize",function(D, subsquareSize)
	local rowsInSubSquare, colsInSubSquare, i, j, k,l, blocks,symbols, results, B;
	results:=[];
	for i in Combinations([1..D.vType[1]],subsquareSize) do
		rowsInSubSquare:=i;
		for j in Combinations([D.vType[1]+1..2*D.vType[1]],subsquareSize) do
			colsInSubSquare:=j;
			blocks:=[];
			symbols:=[];
			for k in Cartesian(rowsInSubSquare,colsInSubSquare) do
				for l in get_blocks_containing_list(D, k) do
					Add(symbols, l[3]);
					Add(blocks, l);
				od;
			od;
			if Size(Set(symbols)) = subsquareSize then
				B:=BlockDesign(D.v, blocks);
				B.k:=[1,1,1];
				B.improper:=D.improper;
				Add(results,B);
			fi;
		od;
	od;
	return results;
end);

findSquareWithLessThanKTransversals:=function(n, k)
	local q,m;
	q:=LS(n,1);;
	while true do 
		q:=ManyStepsProper(q,10);; 
		m:=Size(FindAllTransversals(q, 1, true)); 
		Print(m, " \c"); 
		if(m < k) then 
			Print("\n\n",q,"\n"); 
			break; 
		fi; 
	od;
end;