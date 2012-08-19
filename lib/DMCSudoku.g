################################################################################
# DesignMC/lib/Sudoku.g                                         Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# IsSudoku
# 
# ScanForSudoku performs a random walk on the MC looking for Sudoku grids.
#
# a_sudoku_grid below is an example of a grid found by the ScanForSudoku function.
# 
################################################################################

BindGlobal("IsSudoku",function(B)
	local testSet,i,j,k,blocks,k2;
	blocks:=DMCListListMutableCopy(B.blocks);
	if not B.k=[1,1,1] or not IsRat(Sqrt(B.v/3)) then
		Print("The side length of a Sudoku grid must be a perfect square.");
		return 0;
	fi;
	
	for k in [1..Sqrt(B.v/3)] do
		for j in [1..Sqrt(B.v/3)] do
			testSet:=[];
			for i in [1..Sqrt(B.v/3)] do
				for k2 in [1..Sqrt(B.v/3)] do
					Add(testSet, DMCGetBlocksContainingListWithBlockList(blocks, [i+(k-1)*Sqrt(B.v/3), B.v/3+k2+(j-1)*Sqrt(B.v/3)])[1][3]);
				od;
			od;
			if not Size(Unique(testSet))=B.v/3 then
				return 0;
			fi;
		od;
	od;
	
	return 1;
end);

BindGlobal("ScanForSudoku",function(B)
	local i,non_iso_found,j,k,flag;
	
	if not B.k=[1,1,1] or not IsRat(Sqrt(B.v/3)) then
		Print("The side length of a Sudoku grid must be a perfect square.");
		return 0;
	fi;
	
	non_iso_found:=[];
	DMC_SUDOKU_FOUND:=[];
	i:=0;

	Print("Iteration: ");

	while true do
		i:=i+1;flag:=1;
		if IsSudoku(B)=1 then
			flag:=0;
			for k in DMC_SUDOKU_FOUND do
				if IsEqualBlockDesign(k, B) then
					flag:=1; 
					break;
				fi;
			od;
			
			if flag=0 then
			
				Add(DMC_SUDOKU_FOUND, B);
				Add(non_iso_found, B);
				non_iso_found:=BlockDesignIsomorphismClassRepresentatives(non_iso_found);
				
			fi;
			
		fi;
		
		if not Size(Unique(DMC_SUDOKU_FOUND)) = Size(DMC_SUDOKU_FOUND) then
			break;
		fi;
		
		B:=OneStep(B);

		DMCShowProgressIndicator(i);
		
		if flag=0 then
			Print(": NonIso Found = ",Size(non_iso_found),",\t Total Found: ",Size(DMC_SUDOKU_FOUND),"\n");
		fi;
	od;
end);

# a_sudoku_grid:=rec( isBlockDesign := true, v := 27, 
#   blocks := [ [ 1, 10, 21 ], [ 1, 11, 20 ], [ 1, 12, 27 ], [ 1, 13, 24 ], [ 1, 14, 23 ], [ 1, 15, 25 ], [ 1, 16, 26 ], [ 1, 17, 22 ], [ 1, 18, 19 ], 
# [ 2, 10, 25 ], [ 2, 11, 22 ], [ 2, 12, 23 ], [ 2, 13, 26 ], [ 2, 14, 21 ], [ 2, 15, 19 ], [ 2, 16, 20 ], [ 2, 17, 27 ], [ 2, 18, 24 ],
#  [ 3, 10, 24 ], [ 3, 11, 19 ], [ 3, 12, 26 ], [ 3, 13, 20 ], [ 3, 14, 22 ], [ 3, 15, 27 ], [ 3, 16, 21 ], [ 3, 17, 25 ], [ 3, 18, 23 ], 
# [ 4, 10, 19 ], [ 4, 11, 27 ], [ 4, 12, 21 ], [ 4, 13, 22 ], [ 4, 14, 24 ], [ 4, 15, 26 ], [ 4, 16, 23 ], [ 4, 17, 20 ], [ 4, 18, 25 ],
#  [ 5, 10, 20 ], [ 5, 11, 25 ], [ 5, 12, 24 ], [ 5, 13, 19 ], [ 5, 14, 27 ], [ 5, 15, 23 ], [ 5, 16, 22 ], [ 5, 17, 26 ], [ 5, 18, 21 ],
#  [ 6, 10, 26 ], [ 6, 11, 23 ], [ 6, 12, 22 ], [ 6, 13, 21 ], [ 6, 14, 25 ], [ 6, 15, 20 ], [ 6, 16, 24 ], [ 6, 17, 19 ], [ 6, 18, 27 ], 
# [ 7, 10, 22 ], [ 7, 11, 21 ], [ 7, 12, 20 ], [ 7, 13, 25 ], [ 7, 14, 19 ], [ 7, 15, 24 ], [ 7, 16, 27 ], [ 7, 17, 23 ], [ 7, 18, 26 ], 
# [ 8, 10, 23 ], [ 8, 11, 26 ], [ 8, 12, 25 ], [ 8, 13, 27 ], [ 8, 14, 20 ], [ 8, 15, 21 ], [ 8, 16, 19 ], [ 8, 17, 24 ], [ 8, 18, 22 ], 
# [ 9, 10, 27 ], [ 9, 11, 24 ], [ 9, 12, 19 ], [ 9, 13, 23 ], [ 9, 14, 26 ], [ 9, 15, 22 ], [ 9, 16, 25 ], [ 9, 17, 21 ], [ 9, 18, 20 ] ], 
#    
#   isBinary := true, isSimple := true, blockSizes := [ 3 ], 
#   blockNumbers := [ 81 ], r := 9, autGroup := Group(()), k := [ 1, 1, 1 ], 
#   vType := [ 9, 9, 9 ], negatives := [  ] );
