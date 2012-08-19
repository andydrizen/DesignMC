################################################################################
# DesignMC/lib/SteinerTripleSystems.g	                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# IsBlockDesignPartialSTS
#
################################################################################

BindGlobal("IsBlockDesignPartialSTS",function(B)
	local seen,i,tmp;
	seen:=[];
	for i in B.blocks do
		tmp:=Combinations(i, 2);
		if tmp[1] in seen or tmp[2] in seen  or tmp[3] in seen then
			return 0;
		else 
			Add(seen, tmp[1]);
			Add(seen, tmp[2]);
			Add(seen, tmp[3]);
		fi;
	od;
	return 1;
end);
