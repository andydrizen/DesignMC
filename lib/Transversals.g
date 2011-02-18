################################################################################
# DesignMC/lib/Sudoku.g                                         Andy L. Drizen
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

BindGlobal("FindTransversal",function(Design,lambda)
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
end);

BindGlobal("FindAllTransversals",function(Design,lambda)
	return BlockDesignsModified(
		rec(
		    v:=Design.v, 
			blockDesign:=Design,
		    blockSizes:=[3],
		    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
		    isoLevel:=2,
			isoGroup:=Group(());
			ignoreAutGroupComputationForBlockDesign:=true
		)
	);
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
			tmp:=PartialTransversals(E,lambda, findAll, depth+1);
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
	Print("Started Calculation at:",CurrentTime(),"\n");
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
	
	partials:=PartialTransversals(D2, plambda, pfindAll,1);
	Print("\n");
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
	Print("Finished Calculation at:",CurrentTime(),"\n");
	if (pfindAll = false) then
		return [results2[1]];
	fi;
	
	return results2;
end);