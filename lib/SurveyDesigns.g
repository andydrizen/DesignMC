################################################################################
# DesignMC/lib/SurveyDesigns.g	                                Andy L. Drizen
#                                                                   15/02/2011
# File overview:
#
#
################################################################################

SurveyDesigns:=function( D, experiments, mixingTime, path )
	local D2, i, result,test,test_result;
	D2:=ShallowCopy(D);
	PrintTo(path, "SurveyDesigns(",D,", ",experiments,", ",mixingTime,", ",path,");\n\n\n ############\n\n\n ");
	i:=0;
	while( true ) do
		i:=i+1;
		if (D2.improper) then
			D2:=ManyStepsImproper(D2, mixingTime);
		else
			D2:=ManyStepsProper(D2, mixingTime);
		fi;
		result:=[i, D2];
		Print(i,": ");
		for test in experiments do
			test_result:=test.Function(D2);
			Print("\t",test.Name,": ",Size(test_result));
			Add(result, test_result);
		od;
		AppendTo(path, result);
		Print("\n");
	od;
	return [];
end;

FindAllSubSquares:=function(D, subsquareSize)
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
end;

HasIntercalates:=function(D)
	local intercalates;
	intercalates:=FindAllSubSquares(D, 2);
	return intercalates;
end;

HasNoSubsquares:=function(D)
	local i,res;
	for i in [2..D.v/6] do
		res:=FindAllSubSquares(D, i);
		return res;
	od;
	return [];
end;

HasTransversals:=function(D)
	local transversals;
	transversals:=FindAllTransversals(D, D.tSubsetStructure.lambdas[1], true);
	return transversals;
end;