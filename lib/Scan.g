################################################################################
# DesignMC/lib/Scan.g	                                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# ScanDesigns will help you find designs that do not satisfy the checkFunction
#
################################################################################

ScanDesigns:=function( D, checkFunction, NumberOfIntermediateSteps, NumberOfDesignsToScan)
	local D2, numberScanned;
	D2:=ShallowCopy(D);

	numberScanned:=0;
	while(numberScanned < NumberOfDesignsToScan) do
		if (D2.improper) then
			D2:=ManyStepsImproper(D2, NumberOfIntermediateSteps);
		else
			D2:=ManyStepsProper(D2, NumberOfIntermediateSteps);
		fi;
		numberScanned:=numberScanned+1;
		if(checkFunction(D2) = false) then
			return [D2];
		fi;
		ShowProgressIndicator(numberScanned);
	od;
	return [];
end;

CTransversal:=function(D)
	if(Size(FindTransversal(D, D.tSubsetStructure.lambdas[1], true))>0) then
		return true;
	else
		return false;
	fi;
end;