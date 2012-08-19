################################################################################
# DesignMC/lib/EstimateSizeOfSubsets.g	                    Andy L. Drizen
#                                                                   06/03/2011
# File overview:
#
# GetRandomSample
# GetRandomImproperSample
# GetRandomHopSample
# 
################################################################################

BindGlobal("GetRandomSample", function(D, mixingTime, sampleSize)
	local i,results,m;
	i:=1;
	m:=ShallowCopy(D);
	results:=[];
	for i in [1..sampleSize] do
		ShowProgressIndicator(i);
		m:=ManyStepsProper(D, mixingTime);
		Add(results, m);
	od;
	return results;
end);

BindGlobal("GetRandomImproperSample", function(D, mixingTime, sampleSize)
	local i,results,m;
	i:=1;
	m:=ShallowCopy(D);
	results:=[];
	for i in [1..sampleSize] do
		ShowProgressIndicator(i);
		m:=ManyStepsImproper(D, mixingTime);
		Add(results, m);
	od;
	return results;
end);

BindGlobal("GetRandomHopSample", function(D,sampleSize)
	local i,results,m;
	i:=1;
	m:=ShallowCopy(D);
	results:=[];
	for i in [1..sampleSize] do
		ShowProgressIndicator(i);
		m:=Hopper(m, [],[]);
		Add(results, m);
	od;
	return results;
end);
