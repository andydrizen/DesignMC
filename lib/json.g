CreateJSONString:=function( input )
	local names,item, str,i,tmp;
	names:=RecNames(input);
	str:="{";
	for item in [1..Size(names)] do
		str:=Concatenation(str, "\"",names[item],"\"");
		str:=Concatenation(str, ":");
		if IsRecord(input.(names[item])) then
			str:=Concatenation(str, CreateJSONString(input.(names[item])) );
		else
			
			# this is pretty grim, but we need to separate the long lists to avoid newline characters (\)
			
			tmp:=input.(names[item]);
			if IsList(tmp) and Size(tmp)>0 and IsList(tmp[1]) then
				str:=Concatenation(str, "[");
				for i in input.(names[item]) do
					str:=Concatenation(str, String(i) );
					if not i=input.(names[item])[Size(input.(names[item]))] then
						str:=Concatenation(str, ",");
					fi;
					str:=Concatenation(str, "\n");
				od;
				str:=Concatenation(str, "]");
			else
				str:=Concatenation(str, String(input.(names[item])) );
			fi;

		fi;

		if item < Size(names) then
			str:=Concatenation(str, ", \n");
		fi;
	od;
	str:=Concatenation(str, "}");
	return str;
end;

Rec2JSON:=function( input, path )
	PrintTo(path, CreateJSONString(input));
end;
