################################################################################
# DesignMC/lib/GenericFunctions.g                               Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# This file contains functions that I wish GAP had by default.
#
# DuplicateList
#
# Sort2 (like GAPs built in Sort funciton, but returns the sorted list.)
#
# SortListList
#
# listPerm (applies a permutation to a list)
#
# checkListPerms (tries to find a permutation connecting mapping ListList1 to 
# ListList2)
#
# MultisetDifference
#
# MultisetIntersection
#
# GetMutableListList
#
# EmailResult
# example usuage:
# e:=EnumerateSTS(15,1);PrintTo("STS15.g", e);EmailResult("sombody@mail.com",
# "someSTS15s", Concatenation("Job Done!\nThere are ",String(Size(e))," STS15s in this group"), "STS15.g");
#
# CurrentTime
#
# ShowProgressIndicator
#
# ShowPercentIndicatorSimple
#
# ShowPercentIndicator
# 
###############################################################################

BindGlobal("DuplicateList",function(list, number_of_times)
	local tmp,i;
	tmp:=[];
	for i in [1..number_of_times] do
		Append(tmp, list);
	od;
	return tmp;
end);

#
# Sorting Lists and a list of lists.
#


BindGlobal("Sort2",function(object)
	local o2;
	o2:=ShallowCopy(object);
	Sort(o2);
	return o2;
end);

BindGlobal("SortListList",function(listlist)
	local i;
	for i in [1..Size(listlist)] do
		listlist[i]:=ShallowCopy(listlist[i]);
		Sort(listlist[i]);
	od; 
	listlist:=ShallowCopy(listlist);
	Sort(listlist);
	return listlist;
end);

BindGlobal("listPerm",function(ListLists, perm,ordered)
	local i2,j2,myList;
	myList:=StructuralCopy(ListLists);
	for i2 in [1..Size(myList)] do
		for j2 in [1..Size(myList[i2])] do
			if IsList(myList[i2][j2])=false then
				myList[i2][j2]:=myList[i2][j2]^perm;
			fi;
		od;
		if ordered=0 then 
			myList[i2]:=Sort2(myList[i2]);
		fi;
	od;
	return myList;
end);

BindGlobal("checkListPerms",function(ListList1, ListList2, SizeOfSn ,ordered)
	local group,i,results,myList1, myList2,j;
	myList1:=StructuralCopy(ListList1);
	myList2:=StructuralCopy(ListList2);
	group:=SymmetricGroup(SizeOfSn);
	results:=[];
	if ordered = 0 then
		for i in [1..Size(myList1)] do
			myList1[i]:=Sort2(myList1[i]);
		od;
		for i in [1..Size(myList2)] do
			myList2[i]:=Sort2(myList2[i]);
		od;
	fi;
	j:=0;
	for i in group do
		j:=j+1;
		Print(j,"/",Size(SymmetricGroup(SizeOfSn)),"\t ",Int(j*100/Size(SymmetricGroup(SizeOfSn))),"% \t Suitable permutations found: ",Size(results),"\n");
		if Sort2(myList2)=Sort2(listPerm(myList1, i,ordered)) then
			Print(i,"\n");
			Add(results, i);
		fi;
	od;
	Print("\n To map \n",myList1," \nto\n ",myList2," \nuse the following permutations from S",SizeOfSn,"\n\nSize");
	return results;
end);

BindGlobal("MultisetDifference",function(A,B)
	local difference,i,j,k,ca;
	if IsSet(A) and IsSet(B) then
		return Difference(A,B);
	fi;
	difference:=[];
	ca:=Collected(A);
	for i in [1..Size(ca)] do
		k:=ca[i][2];
		if ca[i][1] in B then
			k:=k-First(Collected(B), x->x[1]=ca[i][1])[2];
		fi;
		for j in [1..k] do
			Add(difference, ca[i][1]);	
		od;
	od;
	return difference;
end);

BindGlobal("MultisetIntersection",function(A,B)
	local difference,i,j,k,ca;
	if IsSet(A) and IsSet(B) then
		return Intersection(A,B);
	fi;
	difference:=[];
	ca:=Collected(A);
	for i in [1..Size(ca)] do
		k:=0;
		if ca[i][1] in B then
			k:=Minimum(ca[i][2], First(Collected(B), x->x[1]=ca[i][1])[2]);
		fi;
		for j in [1..k] do
			Add(difference, ca[i][1]);	
		od;
	od;
	return difference;
end);

BindGlobal("GetMutableListList",function(ListList)
	local i, newList;
	newList:=[];
	for i in ListList do
		Add(newList, ShallowCopy(i));
	od;
	return newList;
end);

BindGlobal("EmailResult",function(to, subject,message,fileattach)

	local attach;
	if fileattach = 0 then
		attach := "";
	else 
		attach := Concatenation("-a ",fileattach);
	fi;
	Exec("echo \"",message," \"| mutt -s ",subject," ",attach," ",to);
end);


BindGlobal("CurrentTime",function()
	local random_string;
	random_string:=Concatenation(String(Random([10000..99999])),".rd");
	Exec(Concatenation("date \"+CURRENT_TIME:=+%s;\" > ",random_string) );
	Read(random_string);
	Exec(Concatenation("rm ",random_string));
	return CURRENT_TIME;
end);

BindGlobal("CurrentTimeHuman",function()
	local random_string;
	random_string:=Concatenation(String(Random([10000..99999])),".rd");
	Exec(Concatenation("date \"+CURRENT_TIME:=\\\"%H:%M:%S, %d/%m/%Y\\\";\" > ",random_string) );
	Read(random_string);
	Exec(Concatenation("rm ",random_string));
	return CURRENT_TIME;
end);

BindGlobal("ShowProgressIndicator",function(i)
	local j;
	if i > 1 then
		for j in [1..Length(DigitsNumber(i-1,10)) ] do
			Print("\b");
		od;
	fi;
	Print(i,"\c");
end);

BindGlobal("ShowPercentIndicatorSimple",function(i,total)
	local j;
	if i > 0 then
		for j in [1..(Length(DigitsNumber(i-1,10))+1+Length(DigitsNumber(total,10))) ] do
			Print("\b");
		od;
	fi;
	Print(i,"/",total,"\c");
end);

BindGlobal("ShowPercentIndicator",function(i,total,start_time)
	local j,percent_done,average_time,time_remaining,time_remaining_old,percent_done_old;
	
	#it has take this long to do i things. There are total-i left to go
	time_remaining:=Int((total-i)*((CurrentTime()-start_time)/i));
	percent_done:=Int(i*100/total);
	percent_done_old:=Int((i-1)*100/total);
	if i > 1 then
		time_remaining_old:=Int((total-i-1)*((CurrentTime()-start_time)/(i-1)));
		for j in [1..Maximum(1, Length(DigitsNumber(percent_done_old,10)))+19+Maximum(1, Length(DigitsNumber(time_remaining_old,10))) ] do
			Print("\b");
		od;
	fi;
	Print(percent_done,"%, Time remaining=",time_remaining,"\c");
end);

RemoveElement:=function(list, element)
	local i, indices;
	indices:=[];
	for i in [1..Size(list)] do
		if list[i] = element then
			Add(indices, i);
		fi;
	od;
	for i in indices do
		Remove(list, i);
	od;
	return list;
end;

FirstOccurrenceOfElement:=function(list, element)
	local i;
	for i in [1..Size(list)] do
		if list[i] = element then
			return i;
		fi;
	od;
	return -1;
end;
