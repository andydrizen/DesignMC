################################################################################
# DesignMC/lib/EstimateSizeOfSubsets.g	                    Andy L. Drizen
#                                                                   06/03/2011
# File overview:
#
#
################################################################################

BindGlobal("DMCGetRandomSample", function(D, mixingTime, sampleSize)
	local i,results,m;
	i:=1;
	m:=ShallowCopy(D);
	results:=[];
	for i in [1..sampleSize] do
		DMCShowProgressIndicator(i);
		m:=ManyStepsProper(D, mixingTime);
		Add(results, m);
	od;
	return results;
end);

BindGlobal("DMCGetRandomImproperSample", function(D, mixingTime, sampleSize)
	local i,results,m;
	i:=1;
	m:=ShallowCopy(D);
	results:=[];
	for i in [1..sampleSize] do
		DMCShowProgressIndicator(i);
		m:=ManyStepsImproper(D, mixingTime);
		Add(results, m);
	od;
	return results;
end);

BindGlobal("DMCGetRandomHopSample", function(D,sampleSize)
	local i,results,m;
	i:=1;
	m:=ShallowCopy(D);
	results:=[];
	for i in [1..sampleSize] do
		DMCShowProgressIndicator(i);
		m:=Hopper(m, [],[]);
		Add(results, m);
	od;
	return results;
end);
