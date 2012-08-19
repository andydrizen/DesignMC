################################################################################
# DesignMC/lib/DMCJSON.g					                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
#
################################################################################

BindGlobal("DMCJSONStringifyListOfDesigns", function( inputList, path )
	local i,out,total_number,j,tmp,i2;
	out:=OutputTextFile(path, false);
	SetPrintFormattingStatus(out, false);
	total_number:=DMCTotalNumberOfBlockDesigns(inputList);
	PrintTo(out, 
	"{\"t\":",inputList[1].tSubsetStructure.t,", \
	\n\"vType\":",inputList[1].vType,", \
	\n\"k\":",inputList[1].k,", \
	\n\"l\":",inputList[1].tSubsetStructure.lambdas,", \
	\n\"b\":",inputList[1].blockNumbers,", \
	\n\"negatives\":",Size(inputList[1].negatives),", \
	\n\"number_up_to_isomorphism\":",Size(inputList),", \
	\n\"total_number\":",total_number,", \
	\n\"notes\":[], \
	\n\"tags\":[], \
	\n\"enumeration\":[\n"); 
	
	j:=1;
	for i2 in inputList do
		i:=ShallowCopy(i2);
		AppendTo(out, "\t");
		tmp:=i.tSubsetStructure.t;
		Unbind(i.tSubsetStructure);
		i.tSubsetStructure:=rec(t:=tmp);
		AppendTo(out, ReplacedString(CreateJSONStringFromRecord(i),"\n",""));
		if j < Size(inputList) then
			AppendTo(out, ",\n");
		fi;
		j:=j+1;
	od;
	
	AppendTo(out, "]}\n");
end);
