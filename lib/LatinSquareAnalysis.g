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

BindGlobal("FindTransversal",function(Design,lambda)
	return BlockDesigns(
		rec(
		    v:=Design.v, 
			blockDesign:=Design,
		    blockSizes:=[3],
		    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
		    isoLevel:=0,
			isoGroup:=Group(())
		)
	);
end);

BindGlobal("FindAllTransversals",function(Design,lambda)
	return BlockDesigns(
		rec(
		    v:=Design.v, 
			blockDesign:=Design,
		    blockSizes:=[3],
		    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
		    isoLevel:=2,
			isoGroup:=Group(()),
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
BindGlobal("NumTransversals",function(Design)
	return Size(FindAllTransversals(Design, 1, true));
end);
BindGlobal("NumIntercalates",function(Design)
	return Size(FindAllSubSquaresOfSize(Design, 2));
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

GetIndexOfElementInList:=function(element, list)
	local i;
	for i in [1..Size(list)] do
		if list[i] = element then
			return i;
		fi;
	od;
	return -1;
end;

GetIndexOfIsomorphicElementInList:=function(element, list)
	local i;
	for i in [1..Size(list)] do
		if IsIsomorphicBlockDesign(list[i], element) then
			return i;
		fi;
	od;
	return -1;
end;

UniqueBlockDesigns:=function(squares)
	local i,j,new,flag;
	new:=[];
	for i in [1..Size(squares)] do
		flag:=0;
		for j in [i+1..Size(squares)] do
			if IsEqualBlockDesign(squares[i],squares[j]) then
				flag:=1;
				break;
			fi;
		od;
		if flag = 0 then
			Add(new, squares[i]);
		fi;
	od;
	return new;
end;

TransitionMatrix:=function(squares)
	local transition_matrix, i,j, new_square, prop_moves, imp_moves,index,sum;

	transition_matrix:=[];

	# zero the transition_matrix

	for i in [1..Size(squares)] do
		Add(transition_matrix, DuplicateList([0], Size(squares)));
	od;
	
	# only compute the proper moves once.
	prop_moves:=Cartesian([1..squares[i].vType[1]], [squares[i].vType[1]+1..squares[i].vType[1]+squares[i].vType[2]], [squares[i].vType[1]+squares[i].vType[2]+1..squares[i].vType[1]+squares[i].vType[2]+squares[i].vType[3]]);

	for i in [1..Size(squares)] do
		ShowProgressIndicator(i);
		if Size(squares[i].negatives)>0 then
			# get all 8 possible moves, and then try them all.
			imp_moves:=RemovableBlocks(squares[i], squares[i].negatives[1]);
			for j in [1..Size(imp_moves)] do
				new_square:=Hopper(squares[i], squares[i].negatives[1],imp_moves[j]);
			
				# now we've got a square, find it in the kth position of the squares array
				# and then add 1 to the (i,k)th entry in the transition matrix.
				
				#index:=GetIndexOfElementInList(new_square, squares);
				index:=GetIndexOfIsomorphicElementInList(new_square, squares);
				transition_matrix[i][index]:=transition_matrix[i][index]+1;
				
			od;
		
		else
			for j in [1..Size(prop_moves)] do
				new_square:=Hopper(squares[i], prop_moves[j],[]);
				
				#index:=GetIndexOfElementInList(new_square, squares);
				index:=GetIndexOfIsomorphicElementInList(new_square, squares);
				transition_matrix[i][index]:=transition_matrix[i][index]+1;
			od;
		fi;
	od;
	
	for i in [1..Size(transition_matrix)] do
		sum:=Sum(transition_matrix[i]);
		for j in [1..Size(transition_matrix[i])] do
			transition_matrix[i][j]:=transition_matrix[i][j]/sum;
		od;
	od;
	PrintTo("~/Desktop/matrix.txt",transition_matrix);
	return transition_matrix;
end;

FindSquareWithLeastTransversals:=function(m)
	local prop_moves, imp_moves,new_square, potentials,tmp,m2,best,j,flag;
	m2:=ShallowCopy(m);
	Print("Intialising...");
	prop_moves:=Cartesian([1..m2.vType[1]], [m2.vType[1]+1..m2.vType[1]+m2.vType[2]], [m2.vType[1]+m2.vType[2]+1..m2.vType[1]+m2.vType[2]+m2.vType[3]]);
	Print("Done!\n");
	best:=99999999;
	while(best>0) do
		potentials:=[];
		if Size(m2.negatives)>0 then
			# get all 8 possible moves, and then try them all.
			imp_moves:=RemovableBlocks(m2, m2.negatives[1]);
			for j in [1..Size(imp_moves)] do
				tmp:=Hopper(m2, m2.negatives[1],imp_moves[j]);
				Add(potentials,[tmp,NumTransversals(tmp)]);
			od;
		else
			for j in [1..Size(prop_moves)] do
				tmp:=Hopper(m2, prop_moves[j],[]);
				Add(potentials,[tmp,NumTransversals(tmp)]);
			od;
		fi;
		flag:=0;
		for tmp in potentials do
			if tmp[2] < best then
				flag:=1;
				best:=tmp[2];
				m2:=tmp[1];
				Print("New best: ",m2,"\n\n---NumTransversals: ",best,"---\n");
			fi;
		od;
		if flag = 0 then
			Print("Found local minima; jumping.");
			m2:=ManyStepsProper(m2, 10);
		fi;
	od;
end;

FindMaximallyIntersectingDistinctTransversals:=function(D)
	local transversals, i, j, best_match,r;
	best_match:=rec(t1:=0, t2:=0, difference:=0);
	transversals:=FindAllTransversals(D, 1);
	if Size(transversals) = 0 then
		Print("Square has no transversals\n");
		return;
	fi;
	for i in [1..Size(transversals)] do
		for j in [i+1..Size(transversals)] do
			r:=Size(Intersection(transversals[i].blocks, transversals[j].blocks));
			if  r > best_match.difference then
				Print("New best! ",i," and ",j," only differ in ",D.vType[1]-r," places.\n");
				best_match:=rec(t1:=transversals[i], t2:=transversals[j], difference:=D.vType[1]-r);
			fi;
		od;
	od;
	return best_match;
end;

HopTransversal:=function(square, transversal)
	local i,subtransversal, possible_subgrids,subgridA,subgridB,subgridC,subgrids,t2, new_subtransversal, all_possible,m,c;
	all_possible:=[];
	c:=Combinations(transversal.blocks,3);
	for m in c do
		#Print("Working with ",m,"\n");
		subtransversal:=m;
		subgridA:=[];
		subgridB:=[];
		subgridC:=[];
	
		Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[1][2]])[1]);
		Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[2][2]])[1]);
		Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[3][2]])[1]);
	
		Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[1][2]])[1]);
		Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[2][2]])[1]);
		Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[3][2]])[1]);

		Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[1][2]])[1]);
		Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[2][2]])[1]);
		Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[3][2]])[1]);
	
		possible_subgrids:=Cartesian(subgridA,subgridB,subgridC);
		possible_subgrids:=MultisetDifference(possible_subgrids, [subtransversal]);
		subgrids:=[];
		t2:=ShallowCopy(transversal);
	
		for i in [1..Size(possible_subgrids)] do
			if Sort2(Unique(Flat(possible_subgrids[i]))) = Sort2(Unique(Flat(subtransversal))) then
				Add(subgrids, possible_subgrids[i]);
			fi;
		od;
		#Print("subgrids = ",subgrids,"\n");
		if Size(subgrids)>0 then
			Add(all_possible, [subtransversal, subgrids]);
		fi;
	od;
	
	if(Size(all_possible) = 0) then
		Print("THIS TRANSVERSAL HAS NO FRIENDS\n");
		return [];
	fi;
	new_subtransversal:=Random(all_possible);
	t2.blocks:=MultisetDifference(t2.blocks, new_subtransversal[1]);
	Append(t2.blocks, Random(new_subtransversal[2]));
	t2.blocks:=SortListList(t2.blocks);
	return t2;
end;

HopTransversal2:=function(square, transversal,numImps)
	local i,j,subtransversal, possible_subgrids,subgridA,subgridB,subgridC,subgrids,t2, new_subtransversal,improper_match_distance,flag,variable_flag,potentials,t3;

	subtransversal:=Random(Combinations(transversal.blocks,3));

	improper_match_distance:=numImps;

	subgridA:=[];
	subgridB:=[];
	subgridC:=[];

	Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[1][2]])[1]);
	Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[2][2]])[1]);
	Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[3][2]])[1]);

	Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[1][2]])[1]);
	Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[2][2]])[1]);
	Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[3][2]])[1]);

	Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[1][2]])[1]);
	Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[2][2]])[1]);
	Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[3][2]])[1]);

	possible_subgrids:=MultisetDifference(Cartesian(subgridA,subgridB,subgridC), [subtransversal]);
	subgrids:=[];
	t2:=ShallowCopy(transversal);

	potentials:=Sort2(Flat(subtransversal));

	for i in [1..Size(possible_subgrids)] do
		flag:=true;
		variable_flag:=transversal.v/3;
		# check there is a cell in each row
		for j in [1..Size(potentials)/3] do
			if Size(get_blocks_containing_list_from_blockList(possible_subgrids[i], [potentials[j]])) = 0 then
				flag:=false;
			fi;

			if Size(get_blocks_containing_list_from_blockList(possible_subgrids[i], [potentials[j+Size(potentials)/3]])) = 0 then
				flag:=false;
			fi;

		od;
		
		t3:=ShallowCopy(t2);
		t3.blocks:=Union(MultisetDifference(t3.blocks, subtransversal), possible_subgrids[i]);
		t3.blocks:=SortListList(GetMutableListList(t3.blocks));
		if flag=true and Size(Unique(Flat(t3.blocks)))+improper_match_distance >= transversal.v then
			Add(subgrids, t3);
		else
		fi;
	od;

	if(Size(subgrids) = 0) then
		return [];
	fi;
	return Random(subgrids);
end;

IsTransversal:=function(D)
	return Size(Unique(Flat(D.blocks)))=D.v and Size(D.blocks)=D.v/3;
end;

HopTransversal3:=function(square, transversal,numImps)
	local i,j,subtransversal, possible_subgrids,subgridA,subgridB,subgridC,subgrids,t2, new_subtransversal,improper_match_distance,flag,variable_flag,potentials,t3,m,all;

	all:=[];
	for m in Combinations(transversal.blocks,3) do

		subtransversal:=m;

		improper_match_distance:=numImps;

		subgridA:=[];
		subgridB:=[];
		subgridC:=[];

		Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[1][2]])[1]);
		Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[2][2]])[1]);
		Add(subgridA, get_blocks_containing_list(square, [subtransversal[1][1],subtransversal[3][2]])[1]);

		Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[1][2]])[1]);
		Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[2][2]])[1]);
		Add(subgridB, get_blocks_containing_list(square, [subtransversal[2][1],subtransversal[3][2]])[1]);

		Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[1][2]])[1]);
		Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[2][2]])[1]);
		Add(subgridC, get_blocks_containing_list(square, [subtransversal[3][1],subtransversal[3][2]])[1]);

		possible_subgrids:=MultisetDifference(Cartesian(subgridA,subgridB,subgridC), [subtransversal]);
		subgrids:=[];
		t2:=ShallowCopy(transversal);

		potentials:=Sort2(Flat(subtransversal));

		for i in [1..Size(possible_subgrids)] do
			flag:=true;
			variable_flag:=transversal.v/3;
			# check there is a cell in each row
			for j in [1..Size(potentials)/3] do
				if Size(get_blocks_containing_list_from_blockList(possible_subgrids[i], [potentials[j]])) = 0 then
					flag:=false;
				fi;

				if Size(get_blocks_containing_list_from_blockList(possible_subgrids[i], [potentials[j+Size(potentials)/3]])) = 0 then
					flag:=false;
				fi;

			od;
		
			t3:=ShallowCopy(t2);
			t3.blocks:=Union(MultisetDifference(t3.blocks, subtransversal), possible_subgrids[i]);
			t3.blocks:=SortListList(GetMutableListList(t3.blocks));
			if flag=true and Size(Unique(Flat(t3.blocks)))+improper_match_distance >= transversal.v then
				Add(all,t3);
			else
			fi;
		od;
	od;
	if(Size(all) = 0) then
		return [];
		#Error("There are no moves from this square.");
	else
		#Print("\t-- ",Size(all)," moves -- available from this ");
		if(IsTransversal(transversal)) then
			#Print("transversal\n");
		else
			#Print("NON-transversal\n");
		fi;
	fi;
	return Random(all);
end;


ScanTrans:=function(square, transversal)
	local found, total,t2;
	total:=Size(FindAllTransversals(square, 1));
	t2:=ShallowCopy(transversal);
	found:=[t2];
	Print("Total found = ",Size(found),"\n");
	while Size(found) < total do
		t2:=HopTransversal(square, t2);

		if t2 = [] then
			return found;
		fi;

		if t2 in found then
			#do nothing
		else
			Add(found, t2);
			Print("Total found = ",Size(found),"\n");
		fi;
	od;
	return found;
end;

ScanTrans2:=function(square, transversal,numImps)
	local found, total,t2,transversals_found,i;
	i:=1;
	if square.v < 40 then
		total:=Size(FindAllTransversals(square, 1));
	else 
		total:="??";
	fi;
	t2:=ShallowCopy(transversal);
	transversals_found:=[t2];
	found:=[t2];
	Print("Total found = ",Size(found),". Total transversals = ",Size(transversals_found),"/",total,"\n");
	while true do
		t2:=HopTransversal3(square, t2,numImps);

		if not t2 in found then
			Add(found, t2);
			if IsTransversal(t2) then
				Add(transversals_found, t2);
			fi;
		fi;
		Print(i,": Total found = ",Size(found),". Total transversals = ",Size(transversals_found),"/",total,"\n");
		i:=i+1;
	od;
	return transversals_found;
end;

couple:=function(x,y)
	local m,x1,y1, coin1, coin2, coin3, pivot, removablesX, removablesY,i, row_choicesX, col_choicesX, sym_choicesX, row_choicesY, col_choicesY, sym_choicesY,pivotX,pivotY,d,k;
	x1:=ShallowCopy(x);
	y1:=ShallowCopy(y);
	d:=Size(x.blocks) - Size(MultisetIntersection(x1.blocks, y1.blocks));
	m:=0;
	while d>0 do
		m:=m+1;
		d:=Size(x.blocks) - Size(MultisetIntersection(x1.blocks, y1.blocks));
		Print(m,": matched ",Size(x.blocks)-d,"/",Size(x.blocks),"\t");
		
		for k in [1..Size(x.blocks)-d] do
			Print("|");
		od;
		for k in [1..d] do
			Print("-");
		od;
		Print("\n");
		
		
		# if both proper
		if x1.improper=false and y1.improper=false then
			#Print("\tBoth proper\n");
			pivot:=GeneratePivot(x1);
			x1:=Hopper(x1,pivot,[]);
			y1:=Hopper(y1,pivot,[]);
			continue;
		fi;
		
		# if both improper
		if (x1.improper and y1.improper) then
			#Print("\tBoth improper\n");
			pivotX:=[];
			pivotY:=[];
			coin1:=Random([0,1]);
			coin2:=Random([0,1]);
			coin3:=Random([0,1]);
			
			removablesX:=SortListList(RemovableBlocks(x1, x1.negatives[1]));
			removablesY:=SortListList(RemovableBlocks(y1, y1.negatives[1]));
			
			row_choicesX:=[];
			col_choicesX:=[];
			sym_choicesX:=[];
		
			for i in removablesX do
				if not i[1] in row_choicesX then
					Add(row_choicesX, i[1]);
				fi;
				if not i[2] in col_choicesX then
					Add(col_choicesX, i[2]);
				fi;
				if not i[3] in sym_choicesX then
					Add(sym_choicesX, i[3]);
				fi;
			od;
	
			row_choicesY:=[];
			col_choicesY:=[];
			sym_choicesY:=[];
		
			for i in removablesY do
				if not i[1] in row_choicesY then
					Add(row_choicesY, i[1]);
				fi;
				if not i[2] in col_choicesY then
					Add(col_choicesY, i[2]);
				fi;
				if not i[3] in sym_choicesY then
					Add(sym_choicesY, i[3]);
				fi;
			od;

			if coin1 = 0 then
				Add(pivotX, Minimum(row_choicesX));
				Add(pivotY, Minimum(row_choicesY));
			else
				Add(pivotX, Maximum(row_choicesX));
				Add(pivotY, Maximum(row_choicesY));
			fi;
	
			if coin2 = 0 then
				Add(pivotX, Minimum(col_choicesX));
				Add(pivotY, Minimum(col_choicesY));
			else
				Add(pivotX, Maximum(col_choicesX));
				Add(pivotY, Maximum(col_choicesY));
			fi;
	
			if coin3 = 0 then
				Add(pivotX, Minimum(sym_choicesX));
				Add(pivotY, Minimum(sym_choicesY));
			else
				Add(pivotX, Maximum(sym_choicesX));
				Add(pivotY, Maximum(sym_choicesY));
			fi;

			x1:=Hopper(x1, x1.negatives[1], pivotX);
			y1:=Hopper(y1, y1.negatives[1], pivotY);
			continue;
		fi;

		# if x1 improper and y1 proper
		
		if x1.improper and y1.improper=false then
			#Print("\tx1 improper, y1 proper\n");
			x1:=Hopper(x1,[],[]);
			continue;
		fi;
		
		
		# if x1 proper and y1 improper
		
		if x1.improper=false and y1.improper then
			#Print("\ty1 improper, x1 proper\n");
			y1:=Hopper(y1,[],[]);
			continue;
		fi;
		
	od;
end;

HowOftenCanWeMove:=function(B)
	local B2, transversals,attempts,successes,t;
	attempts:=0;
	successes:=0;
	B2:=ShallowCopy(B);
	while true do
		B2:=ManyStepsProper(B2,5);;
		transversals:=FindAllTransversals(B2,1);
		if Size(transversals) = 0 then
			continue;
		fi;
		attempts:=attempts+1;
		t:=HopTransversal3(B2, Random(transversals), 0);

		if t <> [] then
			successes:=successes+1;
		fi;
		Print("(",successes,"/",attempts,"): ",Float(successes/attempts),"\n");
	od;
end;

CompleteLS:=function(B)
	local r,c,i,symbols, results,n,out;
	results:=[];
	r:=-1;
	for i in [1..B.v/3] do
		if Size(get_blocks_containing_list(B, [i])) < B.v/3 then
			r:=i;
			break;
		fi;
	od;
	
	if r = -1 then
		#Print("Final--------\n",B,"\n\n");
		return B;
	fi;
	
	for i in [B.v/3+1..2*B.v/3] do
		if Size(get_blocks_containing_list(B, [r,i])) = 0 then
			c:=i;
			break;
		fi;
	od;
	symbols:=[2*B.v/3+1..B.v];
	for i in [2*B.v/3+1..B.v] do
		if Size(get_blocks_containing_list(B, [r,i]))>0 or Size(get_blocks_containing_list(B, [c,i]))>0 then
			symbols:=MultisetDifference(symbols,[i]);
		fi;
	od;
	
	for i in Cartesian([r],[c],symbols) do
		n:=BlockDesign(B.v, Union(B.blocks, [i]));
		n.k:=[1,1,1];
		Add(results,CompleteLS(n));
	od;
	return Unique(Flat(results));
end;
 

CreateLatinRectangle:=function(B,k)
    local B2,ir;
    B2:=StructuralCopy(B);
	for ir in [B2.vType[1]/k+1..B2.vType[1]] do
		B2.blocks:=MultisetDifference(B2.blocks, get_blocks_containing_list(B2,[ir]));
	od;
	B2.vType[1]:=B2.vType[1]/k;
	return B2;
end;  

DecomposeLR:=function(B)
	local B2,transversals, i,j,k, transversal, possibilities, cell, choice,max_it;
	B2:=ShallowCopy(B);
	transversals:=[];
	max_it:=1000;
	for j in [1..B2.vType[2]] do
		#Print(transversals,"\n");
		transversal:=[];
		for i in [1..B2.vType[1]] do
			#Print("Entering for loop with i = ",i,"\n");
			cell:=[];
			#get all the blocks in this row
			possibilities:=get_blocks_containing_list(B2, [i]);
			#Print("\tpossibilities = ",possibilities,"\n");
			k:=0;
			while true do
				if max_it<k then
					#Print("I could only get ",Size(transversals),"/",B2.vType[2],"\n");
					return transversals;
				fi;
				k:=k+1;
				choice:=Random(possibilities);
				#Print("\tchoice = ",choice,"\n");
				if Size(Unique(Flat(Union(transversal, choice)))) = (Size(transversal)+1)*3 then
					cell:=choice;
					break;
				fi;
			od;
			Add(transversal,cell);
		od;
		transversal:=SortListList(transversal);
		Add(transversals, transversal);
		B2.blocks:=MultisetDifference(B2.blocks, transversal);
	od;
	return transversals;
end;

FindFullDecomposition:=function(B)
	local d,i,B2;
	B2:=ShallowCopy(B);
	i:=0;
	while true do
		i:=i+1;
		#ShowProgressIndicator(i);
		d:=DecomposeLR(B2);
		if(Size(d) = B2.vType[2]) then
			Print("\n");
			return d;
		fi;
	od;
end;
FindNearDecomposition:=function(B)
	local d,i,B2,random;
	B2:=ShallowCopy(B);
	i:=0;
	while true do
		i:=i+1;
		#ShowProgressIndicator(i);
		d:=DecomposeLR(B2);
		if(Size(d) = B2.vType[2]-1) then
			return d;
		fi;
		if(Size(d) = B2.vType[2]) then
			random:=Random(d);
			return MultisetDifference(d, [random]);
		fi;
		
	od;
end;
FindNearNearDecomposition:=function(B)
	local d,i,B2,random;
	B2:=ShallowCopy(B);
	i:=0;
	while true do
		i:=i+1;
		#ShowProgressIndicator(i);
		d:=DecomposeLR(B2);
		if(Size(d) = B2.vType[2]-2) then
			return d;
		fi;
	od;
end;
FindMNearDecomposition:=function(B,m)
	local d,i,B2,random;
	B2:=ShallowCopy(B);
	i:=0;
	while true do
		i:=i+1;
		#ShowProgressIndicator(i);
		d:=DecomposeLR(B2);
		if(Size(d) >= B2.vType[2]-m) then
			while Size(d) > B2.vType[2]-m do
				random:=Random(d);
				d:=RemoveElement(d, random);
			od;
			return d;
		fi;		
	od;
end;

DecompositionSearch:=function(n)
	local S,D,i;
	S:=LS(n, 1);
	i:=0;
	while true do
		i:=i+1;
		Print("\n\n\n------------------------------------\nIteration ",i,": ",CurrentTimeHuman(),"\n------------------------------------\n\nGenerating new square...\n\n");
		D:=StructuralCopy(S);
		D:=CreateLatinRectangle(D,2);
		Print(D,"\n\nFinding decomposition...\c");
		FindFullDecomposition(D);
		Print("Success.\n");
		S:=ManyStepsProper(S, 30);
	od;
end;
#UncoveredCell:=function(B, transversalDecomposition,row)
#	local transversal,cell,columns_uncovered;
#	columns_uncovered:=[B.vType[2]+1..2*B.vType[2]];
#	# for now, we always use row 1.
#	for transversal in transversalDecomposition do
#		cell:=get_blocks_containing_list_from_blockList(transversal, [row])[1];
#		RemoveElement(columns_uncovered, cell[2]);
#	od;
#	return get_blocks_containing_list(B, [row, Random(columns_uncovered)])[1];
#end;
UncoveredCells:=function(B, transversalDecomposition,row)
	local transversal,cell,columns_uncovered;
	columns_uncovered:=[B.vType[2]+1..2*B.vType[2]];
	# for now, we always use row 1.
	for transversal in transversalDecomposition do
		cell:=get_blocks_containing_list_from_blockList(transversal, [row])[1];
		RemoveElement(columns_uncovered, cell[2]);
	od;
	return get_blocks_containing_list(B, [row, Random(columns_uncovered)]);
end;
AllUncoveredCells:=function(B, transversalDecomposition)
	local uncovered,i;
	uncovered:=[];
	for i in [1..B.vType[1]] do
		Add(uncovered, UncoveredCells(B, transversalDecomposition, i));
	od;
	return uncovered;
end;
JengaMove:=function(B, transversalDecomposition,r)
	local transversal, cell, columns_uncovered, cell_to_cover, cell_to_uncover,cells_in_selected_column,possibilities,chosen_trans,new_trans,new_transversal_decomposition;
	columns_uncovered:=[B.vType[2]+1..2*B.vType[2]];
	# for now, we always use row 1.
	cell_to_cover:=Random(UncoveredCells(B, transversalDecomposition, r));
	cells_in_selected_column:=get_blocks_containing_list(B, [cell_to_cover[2]]);
	possibilities:=ShallowCopy(transversalDecomposition);
	for cell in cells_in_selected_column do
		for transversal in transversalDecomposition do
			if cell in transversal then
				RemoveElement(possibilities, transversal);
			fi;
		od;
	od;
	for transversal in transversalDecomposition do
		for cell in transversal do
			if cell_to_cover[3] in cell then
				RemoveElement(possibilities, transversal);
			fi;
		od;
	od;
	chosen_trans:=Random(possibilities);
	cell_to_uncover:=get_blocks_containing_list_from_blockList(chosen_trans, [r])[1];
	new_trans:=Union(MultisetDifference(chosen_trans,[cell_to_uncover]), [cell_to_cover]);
	new_transversal_decomposition:=Union(MultisetDifference(transversalDecomposition,[chosen_trans]), [new_trans]);
	return new_transversal_decomposition;
end;

JengaHitTest:=function(B, transversalDecomposition)
	local unseen_cells,newTD,uncovered_cell,uhoh,row,i;
	newTD:=ShallowCopy(transversalDecomposition);
	unseen_cells:=ShallowCopy(B.blocks);
	#uncovered_cell:=UncoveredCell(B, newTD,row);
	#unseen_cells:=RemoveElement(unseen_cells, uncovered_cell);
	uhoh:=0;
	while Size(unseen_cells) > 0 do
		uhoh:=uhoh+1;
		if (uhoh mod 3000) = 0 then
			Print("\nI might be stuck (unseen = ",unseen_cells,"). Uncovered cells: ",AllUncoveredCells(B, newTD),"...\c");
			if Size(Unique(Flat(AllUncoveredCells(B, newTD)))) = 3*Size(AllUncoveredCells(B, newTD)) then
				Print("a transversal!\n");
				#break;
			fi;
		fi;
		row:=Random([1..B.vType[1]]);
		newTD:=JengaMove(B, newTD,row);
		for i in UncoveredCells(B, newTD,row) do
			unseen_cells:=RemoveElement(unseen_cells, i);
		od;
	od;
end;

FindBadJenga:=function(n,k,howNear)
	# this make an n by n/k latin rectangle.
	local B, TD, r, LR,i;
	B:=LS(n, 1);	
	i:=0;
	while true do
		i:=i+1;
		Print("\n\n\n------------------------------------\nIteration ",i,": ",CurrentTimeHuman(),"\n------------------------------------\nGenerating new Latin rectangle of order ",n,"...\n");
		B:=ManyStepsProper(B, 30);
		LR:=ShallowCopy(B);
		LR:=CreateLatinRectangle(LR,k);
		PrettifyDesign(LR);
		Print("\n",LR,"\nFinding near transversal decomposition...\n\n");
		#TD:=FindNearNearDecomposition(LR);
		#TD:=FindNearDecomposition(LR);
		TD:=FindMNearDecomposition(LR, howNear);
		Print(TD,"\n\n");
		Print("Attempting to move the uncovered cell in each row to every position in its row...\c");
		JengaHitTest(LR, TD);
		Print("Succeeded.\n");
	od;
end;