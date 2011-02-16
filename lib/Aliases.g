################################################################################
# DesignMC/lib/Aliases.g	                                    Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# A collection of wrappers for the Produce2Design function (which in turn is a 
# wrapper of Soicher's BlockDesigns function.
#
# Also we have separate enumeration functions where the user can set the
# isoLevel (NOTE: setting an isoLevel of 0 in EnumerateXX() is the same as 
# XX() e.g. EnumerateSTS(7, 1, 0) = STS(7, 1).
#
################################################################################

BindGlobal("LS",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n,n,n], k:=[1,1,1], lambdas:=[lambdaInt,lambdaInt,lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("ILS",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n,n,n], k:=[1,1,1], improper:=true, lambdas:=[lambdaInt,lambdaInt,lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("LF",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n,n-1], k:=[2,1], lambdas:=[lambdaInt,lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("ILF",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n,n-1], k:=[2,1],improper:=true,  lambdas:=[lambdaInt,lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("STS",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n], k:=[3], lambdas:=[lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

BindGlobal("ISTS",function(n,lambdaInt)
	local results;
	results:=Produce2Design( rec(v:=[n], k:=[3],improper:=true, lambdas:=[lambdaInt]) );
	if Size(results)>0 then
		return results[1];
	else
		return [];
	fi;
end);

#
# Enumeration functions (like above but with an isoLevel option).
#

BindGlobal("EnumerateLS",function(n,lambdaInt, isoLevel)
	return Produce2Design( rec(v:=[n,n,n], k:=[1,1,1], lambdas:=[lambdaInt,lambdaInt,lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateILS",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n,n,n], k:=[1,1,1], improper:=true, lambdas:=[lambdaInt,lambdaInt,lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateLF",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n,n-1], k:=[2,1], lambdas:=[lambdaInt,lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateILF",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n,n-1], k:=[2,1],improper:=true,  lambdas:=[lambdaInt,lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateSTS",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n], k:=[3], lambdas:=[lambdaInt], isoLevel:=isoLevel) );
end);

BindGlobal("EnumerateISTS",function(n,lambdaInt,isoLevel)
	return Produce2Design( rec(v:=[n], k:=[3], improper:=true, lambdas:=[lambdaInt], isoLevel:=isoLevel) );
end);
