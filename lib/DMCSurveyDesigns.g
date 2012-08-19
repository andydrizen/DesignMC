################################################################################
# DesignMC/lib/SurveyDesigns.g	                                Andy L. Drizen
#                                                                   15/02/2011
# File overview:
#
#
################################################################################

BindGlobal("SurveyDesigns", function( D, experiments, mixingTime, path )
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
end);

BindGlobal("HasIntercalates",function(D)
	local intercalates;
	intercalates:=FindAllSubSquaresOfSize(D, 2);
	return intercalates;
end);

BindGlobal("HasNoSubsquares", function(D)
	local i,res;
	for i in [2..D.v/6] do
		res:=FindAllSubSquaresOfSize(D, i);
		return res;
	od;
	return [];
end);

BindGlobal("DMCHasTransversals", function(D)
	local transversals;
	transversals:=DMCFindAllTransversals(D, D.tSubsetStructure.lambdas[1]);
	return transversals;
end);
