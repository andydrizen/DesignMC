################################################################################
# DesignMC/lib/IO.g						                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# Allows the user to save and load lists of designs. The DesignStructure parameter 
# is the same as the input of the BlockDesigns function
#
# SaveDesigns
# LoadDesigns
# PrintDesign
# ExportLatinSquareToMaple
# ExportLatinSquareToLaTeX
#
################################################################################

BindGlobal("SaveDesigns",function( DesignStructure, path )
	PrintTo(path, "return ");
	AppendTo(path, Make2Design( DesignStructure ) );
	AppendTo(path, ";");
	return;
end);

BindGlobal("LoadDesigns",function ( path )
	return ReadAsFunction(path)();
end);

BindGlobal("PrintDesign",function(LS)
	local row,col,imp, i, notprinted;
	row:=1;
	if LS.k=[1,1,1] then
		col:=LS.v/3+1;
	fi;
	if LS.k=[2,1] or LS.k=[3] then
		col:=1;
	fi;
	notprinted:=true;
	for i in [1..Size(LS.blocks)] do
		
		if not LS.blocks[i][1]=row then
			Print("\n\n");
			row:=LS.blocks[i][1];
			if LS.k=[1,1,1] then
				col:=LS.v/3+1;
			fi;
			if LS.k=[2,1] or LS.k=[3] then
				col:=1;
			fi;
			notprinted:=true;
		fi;

		while not col = LS.blocks[i][2] do
			if notprinted = true then
				Print("x");
			fi;
			Print("\t");
			col:=col+1;
		od;			

		if LS.k=[1,1,1] then			
			Print(LS.blocks[i][3]-2*LS.v/3,", ");
			notprinted:=false;
		fi;

		if LS.k=[2,1] or LS.k=[3] then
			Print(LS.blocks[i][3],", ");
			notprinted:=false;
		fi;

	od;
	Print("\n");
end);

BindGlobal("ExportLatinSquareToMaple",function(LS)
	local row,col,imp, i, notprinted;
	row:=1;
	if LS.k=[1,1,1] then
		col:=LS.v/3+1;
	fi;
	if LS.k=[2,1] or LS.k=[3] then
		col:=1;
	fi;
	notprinted:=true;
	Print("Matrix([\n[");
	for i in [1..Size(LS.blocks)] do
		
		if not LS.blocks[i][1]=row then
			Print("\b\b],\n[");
			row:=LS.blocks[i][1];
			if LS.k=[1,1,1] then
				col:=LS.v/3+1;
			fi;

			notprinted:=true;
		fi;

		while not col = LS.blocks[i][2] do
			if notprinted = true then
				Print("x");
			fi;
			col:=col+1;
		od;			

		if LS.k=[1,1,1] then			
			Print("x[",LS.blocks[i][3]-2*LS.v/3,"], ");
			notprinted:=false;
		fi;

	od;
	Print("\b\b]]):\n");
end);

BindGlobal("ExportLatinSquareToLaTeX",function(LS)
	local row,col,imp, i, notprinted;
	row:=1;
	if LS.k=[1,1,1] then
		col:=LS.v/3;
	fi;
	if LS.k=[2,1] or LS.k=[3] then
		col:=1;
	fi;
	notprinted:=true;
	Print("\\begin{tabular}{");
	for i in [1..col] do
		Print("| c ");
	od;
	Print("|}\n\t\\hline\n\t\t");
		
	for i in [1..Size(LS.blocks)] do
		
		if not LS.blocks[i][1]=row then
			Print("\\\\ \n\t\\hline\n\t\t");
			row:=LS.blocks[i][1];
			if LS.k=[1,1,1] then
				col:=LS.v/3+1;
			fi;

			notprinted:=true;
		fi;

		if LS.k=[1,1,1] then			
			if(notprinted = false) then
				Print(" & ");
			fi;
			Print(" ",LS.blocks[i][3]-2*LS.v/3,"  ");
			notprinted:=false;
		fi;

	od;
	Print("\\\\\n\t\\hline\n\\end{tabular}\n");
end);
