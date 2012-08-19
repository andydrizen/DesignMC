################################################################################
# DesignMC/lib/MySQL.g 		                                    Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# The ExportToMySQLWithBlockDesign function outputs a MySQL query so that you can store 
# your designs in a MySQL Database, if you like. Example usage is:
#
# for j in [1..2] do 
#	for i in [4..19] do 
#		e:=EnumerateImproperTripleSystems(i,j,0);;
#		tot:=0;
#		ExportToMySQLWithBlockDesign(e, tot); 
#	od; 
# od;
#
################################################################################

BindGlobal("ExportToMySQLWithBlockDesign",function(e,total_systems)
	local lambdas,L;
	if Size(e)=0 then 
		return 0;
	else
		e[1].r:=ReplicationNumber(e[1]);
		L:=e[1].tSubsetStructure.lambdas[1];
		if e[1].k=[1,1,1] then
			lambdas:=[L,L,L];
		fi;
		if e[1].k=[2,1] then
			lambdas:=[L,L];
		fi;
		if e[1].k=[3] then
			lambdas:=[L];
		fi;

		AppendTo("~/mysql_code.sql","INSERT INTO `tdesigns`.`biglist` (`id`, `t`, `v`, `k`, `lambdas`, `replication`, `b`,  `negatives`, `example`, \n`total_non_isomorphic`, `total_isomorphic`, `notes`, `tags`, `live`, `active`) VALUES (NULL, '",e[1].tSubsetStructure.t,"', '",e[1].vType,"', '",e[1].k,"', '",lambdas,"', '",e[1].r,"', '",e[1].blockNumbers[1],"', '",Size(e[1].negatives),"', '",e[1],"', '",Size(e),"', '",total_systems,"', '', '', '1', '1');\n");
	fi;
end);
