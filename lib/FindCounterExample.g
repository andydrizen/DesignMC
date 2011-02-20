################################################################################
# DesignMC/lib/Scan.g	                                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# FindCounterExample will help you find designs that do not satisfy the 
# counterExampleWillFailFunction
#
################################################################################

FindCounterExample:=function( D, counterExampleWillFailFunction )
	local D2, numberScanned;
	D2:=ShallowCopy(D);

	numberScanned:=0;
	while( true ) do
		if (D2.improper) then
			D2:=ManyStepsImproper(D2, 300);
		else
			D2:=ManyStepsProper(D2, 300);
		fi;
		numberScanned:=numberScanned+1;
		if(counterExampleWillFailFunction(D2) = false) then
			return [D2];
		fi;
		ShowProgressIndicator(numberScanned);
	od;
	return [];
end;

HasTransversal:=function(D)
	if(Size(FindTransversal(D, D.tSubsetStructure.lambdas[1], true))>0) then
		return true;
	else
		return false;
	fi;
end;

HasNoTransversal:=function(D)
	if(Size(FindTransversal(D, D.tSubsetStructure.lambdas[1], true))>0) then
		return false;
	else
		return true;
	fi;
end;