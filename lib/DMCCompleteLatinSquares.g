################################################################################
# DesignMC/lib/DMCCompleteLatinSquares.g                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# Three functions relating to Complete Latin squares (see: 
# http://designtheory.org/library/encyc/glossary/#cls ). Firstly, a function to 
# check whether or not a BlockDesign is row or column complete. Secondly, we
# move around the Markov chain to find these squares. Thirdly, given a list of 
# BlockDesigns, check which are row/column complete.
#
################################################################################

BindGlobal("DMCIsBlockDesignCompleteLatinSquare",function(B,IsRowComplete,IsColumnComplete)
	local res,tmp,block,elt,elt2,i,flag,j;
	res:=[];

		
	for elt in [B.v/3*2+1..B.v] do
		tmp:=DMCGetBlocksContainingList(B, [elt]);
		Add(res, [[],[],[],[]]);
		for block in tmp do
			if block[3] = elt then
				# get elts on down
				if not block[1]=B.v/3 then
					Add(res[Size(res)][1], DMCGetBlocksContainingList(B,[block[1]+1,block[2]])[1][3]);
				fi;
				# get elts on right
				if not block[2]=B.v/3*2 then
					Add(res[Size(res)][2], DMCGetBlocksContainingList(B,[block[1],block[2]+1])[1][3]);
				fi;
				# get elts on left
				if not block[2]=B.v/3+1 then
					Add(res[Size(res)][3], DMCGetBlocksContainingList(B,[block[1],block[2]-1])[1][3]);
				fi;
				# get elts on up
				if not block[1]=1 then
					Add(res[Size(res)][4], DMCGetBlocksContainingList(B,[block[1]-1,block[2]])[1][3]);
				fi;
			fi;
		od;
	od;

	flag:=1;
	if IsRowComplete=1 then
		for i in res do
			for j in [2,3] do
				if Size(Unique(i[j]))<B.v/3-1 then
					flag:=0;
					break;
				fi;
			od;
		od;
	fi;
	
	if IsColumnComplete=1 then
		for i in res do
			for j in [1,4] do
				if Size(Unique(i[j]))<B.v/3-1 then
					flag:=0;
					break;
				fi;
			od;
		od;
	fi;
	if flag=1 then
		return 1;
	else
		return 0;
	fi;
end);

BindGlobal("DMCScanForCompleteLatinSquares",function(B,IsRowComplete,IsColumnComplete)
	local B2,non_iso_found,found,i,flag,k,got;
	found:=[];
	i:=0;
	non_iso_found:=[];
	B2:=ShallowCopy(B);
	while true do
		i:=i+1;
		flag:=DMCIsBlockDesignCompleteLatinSquare(B2,IsRowComplete,IsColumnComplete);
		if flag=1 then
			got:=0;
			for k in found do
				if IsEqualBlockDesign(k, B2) then
					got:=1;flag:=0;
					break;
				fi;
			od;
			if got=0 then
				Add(found, B2);
				Add(non_iso_found, B2);
				non_iso_found:=BlockDesignIsomorphismClassRepresentatives(non_iso_found);
			fi;
		fi;
		DMCShowProgressIndicator(i);
		
		if flag=1 then
			Print(": NonIso Found = ",Size(non_iso_found),",\t Total Found: ",Size(found),"\n");
		fi;
		B2:=OneStep(B2);
	od;
end);

BindGlobal("DMCScanForCompleteLatinSquaresInList",function(List, IsRowComplete, IsColumnComplete)
	local B2,non_iso_found,found,i,flag,k,got,start_time;
	found:=[];
	i:=0;
	start_time:=DMCTime();
	non_iso_found:=[];

	for B2 in List do
		i:=i+1;
		flag:=DMCIsBlockDesignCompleteLatinSquare(B2,IsRowComplete,IsColumnComplete);
		if flag=1 then
			got:=0;
			for k in found do
				if IsEqualBlockDesign(k, B2) then
					got:=1;flag:=0;
					break;
				fi;
			od;
			if got=0 then
				Add(found, B2);
				Add(non_iso_found, B2);
				non_iso_found:=BlockDesignIsomorphismClassRepresentatives(non_iso_found);
			fi;
		fi;
		
		DMCShowPercentIndicator(i,Size(List),start_time);
	
		if flag=1 then
			Print(": NonIso Found = ",Size(non_iso_found),",\t Total Found: ",Size(found),"\n");
		fi;
	od;
	return non_iso_found;
end);
