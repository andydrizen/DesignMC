################################################################################
# DesignMC/lib/EstimateSizeOfSubsets.g	                    Andy L. Drizen
#                                                                   06/03/2011
# File overview:
#
#
################################################################################

GetRandomSample:=function(D, mixingTime, sampleSize)
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
end;

GetRandomImproperSample:=function(D, mixingTime, sampleSize)
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
end;

GetRandomHopSample:=function(D,sampleSize)
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
end;

# k:=[];; for m in q do Add(k,NumTransversals(m)); od;k;

# a:=0;;for i in k do if i <= 20 then a:=a+1; fi; od;a;

# all transversal values for LS(7,1);
# q:=[ 33, 18, 22, 43, 14, 20, 21, 21, 15, 13, 29, 31, 17, 63, 21, 18, 20, 28, 21,  23, 30, 21, 13, 16, 25, 21, 45, 23, 25, 32, 13, 15, 18, 19, 30, 21, 19, 25,   24, 27, 16, 15, 23, 15, 43, 3, 15, 24, 19, 19, 13, 23, 16, 15, 19, 23, 22,   19, 12, 30, 23, 24, 18, 14, 20, 19, 33, 17, 18, 19, 7, 32, 25, 23, 26, 25,   25, 22, 22, 37, 16, 20, 22, 25, 7, 16, 22, 19, 33, 16, 11, 14, 22, 27, 31,   13, 47, 15, 24, 23, 133, 17, 26, 11, 23, 18, 26, 28, 25, 21, 22, 23, 55,   21, 28, 9, 26, 20, 19, 17, 34, 19, 28, 17, 24, 36, 19, 14, 15, 31, 14, 19, 25, 22, 34, 12, 19, 24, 11, 41, 14, 25, 15, 31, 21, 24, 21 ]
