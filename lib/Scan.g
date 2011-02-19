################################################################################
# DesignMC/lib/Scan.g	                                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# ScanDesigns takes as input a design and a function. The code will then
# look for many designs of the same kind and pass them to the function, which
# should return true or false. A postive value will increment the counter, 
# whereas a 0 value will leave it unchanged.
#
################################################################################

ScanDesigns:=function( D, counterFunction, NumberOfIntermediateSteps, NumberOfDesignsToScan)
	local D2, numberScanned, items_scanned, items_results;
	D2:=ShallowCopy(D);
	items_scanned:=[];
	items_results:=[];
	numberScanned:=0;
	while(numberScanned < NumberOfDesignsToScan) do
		ShowProgressIndicator(numberScanned);
		if (D2.improper) then
			D2:=ManyStepsImproper(D2, NumberOfIntermediateSteps);
		else
			D2:=ManyStepsProper(D2, NumberOfIntermediateSteps);
		fi;
		Add(items_scanned, D2);
		Add(items_results, counterFunction(D2));
		numberScanned:=numberScanned+1;
	od;
	return [items_scanned, items_results];
end;

CFNumberOfTransversals:=function(D)
	return Size(FindAllTransversals(D, D.tSubsetStructure.lambdas[1], true));
end;