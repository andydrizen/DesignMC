################################################################################
# DesignMC/lib/PairGraph.g                                      Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# The CreatePairGraph function takes as input two BlockDesigns D1, D2 and two points
# p1_red and p2_blue. p1_red should be a point in D1 and p2_blue should be a point
# in D2. We now integrate with Mathematica to produce a pair graph in the following 
# way: Let the vertices of the graph be all of the points in D1 union D2. Now for
# every pair of points a, b join a and b with a red edge if (a,b,p1_red) is a block
# in D1 and join a,b with a blue edge if (a,b,p2_blue) is a block in D2.
#
# The FindAlternatingTrail function finds an alternating trail in the BlockDesign B
# from starting_vertex to finishing_vertex, where the colours of the trail 
# alternate between edgeColour1 and edgeColour2 and a successful trail must 
# include all edges found in include_edge_lists and none of the edges in 
# forbidden_edge_list. NOTE: if you have two blocks [a,b,c] in your BlockDesign, and
# forbidden_edge_list:=[[a,b,c]]; then only ONE of the two blocks is forbidden. If
# you want to ensure that the alternating trail doesn't use either, then put two
# copies of [a,b,c] in the forbidden_edge_list.
# 
# The FindAlternatingTrailWithoutGivenBlueEdge (for factorisations only (i.e. 
# 2-(V, [2,1], L) designs)) 
# 
# A third (and hopefully self-explanatory function), FindAllAlternatingTrails
#
# ComponentsOfGraph: 'B' is a 2-design (|K|=3) and 'pointsList' is list of points. 
# Construct a graph 'G' by forming an edge [x,y] if [x,y,a] is a block of 'B' and 'a' 
# is in pointsList. This function returns the number of points seen from a random 
# starting location. For pair graphs, you can check whether the red/blue 
# subgraph is connected.
# 
# IsChordedDG: Checks to see if a given graph is bridged of chorded.
#
# ScanForBridgedDG: Search MC to find designs with the property that the subgraph 
# created by deleted a blue edge between the ``special vertices'' is disconnected.
# 
################################################################################

BindGlobal("CreatePairGraph",function(D1,p1_red, D2,p2_blue ,path)
	local mystring,list1, i,temp,j, file,num,s,l;

	file:=Concatenation(path,".nb");

	mystring:="g={";

	# first point 
	list1:=get_blocks_containing_list(D1, [p1_red]);
	for i in [1..Size(list1)] do
		j:=MultisetDifference(list1[i], [p1_red]);
		temp:=Concatenation("{\"",String(j[1]),"\"->\"",String(j[2]),"\", \"D1-",String(p1_red),"\"},\n");
		mystring:=Concatenation(mystring,temp);
	od;
	
	# second point 
	list1:=get_blocks_containing_list(D2, [p2_blue]);
	for i in [1..Size(list1)] do
		j:=MultisetDifference(list1[i], [p2_blue]);
		temp:=Concatenation("{\"",String(j[1]),"\"->\"",String(j[2]),"\", \"D2-",String(p2_blue),"\"}");
		mystring:=Concatenation(mystring,temp);
		if not i = Size(list1) then
			mystring:=Concatenation(mystring,", \n");
		fi;
	od;

	mystring:=Concatenation(mystring,"}; \n mygraph=GraphPlot[g, EdgeRenderingFunction -> ({If[#3 == \"D1-",String(p1_red),"\", Red, Blue],\n AbsoluteThickness[2],\n  Line[#1]} &),\n	VertexRenderingFunction -> ({White, EdgeForm[Black],\n  Black, \n   Text[Style[#2, Background -> White], #1]} &),\n VertexLabeling -> True]\n  Export[",path,".eps\",{ mygraph } ]\n");

	Print("EXPORTING USING MATHEMATICA ======== Export id: ",num,"\nAt most two error messages are admissible.\n\n");
	PrintTo(file, mystring);
	Print("\n Trying the \"math\" command....\c");
	Exec("math -run < ",file);
	Print("\n Trying the full path for LINUX....\c");
	Exec("/usr/local/mathematica/Executables/math -run < ",file);
	Print("\n Trying the full path for MAC OS X....\c");
	Exec("/Applications/Mathematica.app/Contents/MacOS/MathKernel < ",file);
	Exec(Concatenation("open -a Preview sync/rbmc2/mathematica/",String(num),".eps"));
	Exec(Concatenation("evince sync/rbmc2/mathematica/",String(num),".eps &"));
	
end);


BindGlobal("FindAlternatingTrail",function(B, starting_vertex, finishing_vertex, IsPathEvenLength, edgeColour1, edgeColour2, include_edge_lists, forbidden_edge_list)
	local path,onColour,choice,j, visited_blocks, checks,tmpblock,blockCopy,tmpblock2,p;
	checks:=0;
	blockCopy:=GetMutableListList(B.blocks);
	visited_blocks:=[];
	if B.improper = false then
		Print("This is for improper designs only.\n");
		return;
	fi;	

	path:=[starting_vertex];
	p:=0;
	while checks=0 or not path[Size(path)]=finishing_vertex or Size(path) mod 2 = IsPathEvenLength do
		if Size(path) mod 2 = 1 then 
			onColour:=edgeColour1;
		else
			onColour:=edgeColour2;
		fi;
		j:=0;
		for tmpblock2 in blockCopy do
			for tmpblock in forbidden_edge_list do
				if tmpblock in Combinations(tmpblock2,1) 
or tmpblock in Combinations(tmpblock2,2)
or tmpblock in Combinations(tmpblock2,3) then

					# If we find a block that is disallowed because of something in the fobidden edge list, remove both the block from the block list and the fobidden edge from the forbidden edge list. This means if you want to prevent ALL, say, blue edges from point 1, you need to include q after this: 
					#q:=[]; for i in [1..10] do Add(q, [1,2]); od;

					blockCopy:=MultisetDifference(blockCopy,[tmpblock2]);
					forbidden_edge_list:=MultisetDifference(forbidden_edge_list, [tmpblock]);
				fi;
			od;
		od;
		while j = 0 do
			j:=1;
			choice:=Random(get_blocks_containing_list_from_blockList(blockCopy, [path[Size(path)], onColour]));

			if choice=fail then
				# we're stuck, try again.
				p:=p+1;
				Print(p,": Stuck - restarting...\n");
				
				path:=[starting_vertex];
				blockCopy:=GetMutableListList(B.blocks);
				visited_blocks:=[];
			else
				choice:=MultisetDifference(choice, [path[Size(path)], onColour])[1];
				
				if j = 1 then
					blockCopy:=MultisetDifference(blockCopy,[Sort2([choice,path[Size(path)],onColour]) ]);
					Add(visited_blocks, Sort2([choice,path[Size(path)],onColour]));
					Add(path, choice);
				fi;
			fi;
		od;
		
		
		# perform include_edge_lists check

		checks:=1;
		for tmpblock in include_edge_lists do
			if Size(get_blocks_containing_list_from_blockList(visited_blocks, tmpblock))=0 then
				checks:=0;
				break;
			fi;
		od;
	od;

	return path;
end);


BindGlobal("FindAlternatingTrailWithoutGivenBlueEdge",function(lf)
	local pivot,edgeColours,badBlue,tmp,tmp2,a,b,c;

	if (not (lf.k = [2,1]) ) then
		Error("<lf> must be a factorisation (i.e. k must be [2,1]).");
	fi;

	edgeColours:=[];
	for tmp in [lf.vType[1]+1..lf.vType[1]+lf.vType[2]] do
		if not tmp = lf.negatives[1][3] then
			Add(edgeColours, [lf.negatives[1][3], tmp]);
		fi;
	od;

	pivot:=[MultisetDifference(lf.negatives[1], edgeColours), Reversed(MultisetDifference(lf.negatives[1], edgeColours))];
	for a in edgeColours do
		for b in pivot do
			badBlue:=get_blocks_containing_list(lf, [a[2],b[1]]);
			for c in badBlue do
				Print("\npiv1: ", b[1], ", piv2: ",b[2],", ed1: ",a[1],", ed2: ",a[2],", badBlue:",c,"\n");
				Print(FindAlternatingTrail(lf, b[1], b[2], 1, a[1], a[2], [], [c]),"\n");
			od;
		od;
	od;
end);

# 
# Not sure how to BindGlobal with recursive function...
# 
FindAllAlternatingTrails:=function(ImpD, startingPoint, endingPoint, startingColour, otherColour, bannedEdgesList, depth)
	local colours,neighbours_of_vertex, i,next_vertex,newD,count,newDepth,tmpneg;
	
	# Find all possible extensions of current trail
	# put them all in a multi-dimensional array and work on them one at a time

	if (not ImpD.k = [2,1]) or Size(ImpD.negatives)=0 then
		Print("This function is for ILF(n,l) only.\n");
		return;
	fi;
	
	count:=0;newDepth:=depth+1;
	colours:=[startingColour, otherColour];
	if depth = 0 then
		tmpneg:=ShallowCopy(ImpD.negatives);
		ImpD := BlockDesign(ImpD.v, MultisetDifference(ImpD.blocks, SortListList(bannedEdgesList)));
		ImpD.k := [2,1];
		ImpD.negatives:=tmpneg;
	fi;
	neighbours_of_vertex:=get_blocks_containing_list(ImpD, [startingPoint, startingColour]);
	for i in neighbours_of_vertex do
		if (endingPoint in i and not startingPoint=endingPoint and colours[(depth mod 2)+1] in i) then
			count:=count+1;
		else
			next_vertex := MultisetDifference(i, [startingPoint, startingColour])[1];
			tmpneg:=ShallowCopy(ImpD.negatives);
			newD:=BlockDesign(ImpD.v, MultisetDifference(ImpD.blocks, [i]));

			newD.k := [2,1];
			newD.negatives:=tmpneg;
			count:=count+FindAllAlternatingTrails(newD, next_vertex, endingPoint, otherColour, startingColour, bannedEdgesList, newDepth);
		fi;
		
	od;
	
	return count;
end;

BindGlobal("ComponentsOfGraph",function(B, pointsList)
	local B2, blocksTmp, blocks, i, j, points_seen, start_from_block, o, start_from_point, blocks_seen, tmp_block, blocks_to_scan,grand_seen, grand_blocks_seen,i2;
	B2:=ShallowCopy(B);
	blocksTmp:=GetMutableListList(B2.blocks);
	blocks:=[];
	for i in blocksTmp do
		if Size(Intersection(pointsList, i))=1 then
			for j in [1..Size(i)] do
				if i[j] in pointsList then
					i[j]:=pointsList[1];
				fi;
			od;
			Add(blocks, i);
		fi;
	od;

	blocks:=get_blocks_containing_list_from_blockList(blocks,[pointsList[1]]);
	grand_seen:=[];
	grand_blocks_seen:=[];
	

	while Size(blocks)>0 do
		points_seen:=[];
		blocks_seen:=[];
		blocks_to_scan:=[blocks[1]];
		
		while Size(blocks_to_scan)>0 do
		
			# Get a block to scan

			start_from_block:=Random(blocks_to_scan);

			# Remove the block we're scanning

			blocks_to_scan:=MultisetDifference(blocks_to_scan, [start_from_block]);
		
			for o in [1,2] do
				start_from_point:=MultisetDifference(start_from_block, [pointsList[1]])[o];

				# Record that we've seen this block and this point

				Add(points_seen, start_from_point);
				Add(blocks_seen, start_from_block);

				i:=1;		
				tmp_block:=get_blocks_containing_list_from_blockList(blocks,[pointsList[1],start_from_point]);

				while i<=Size(tmp_block) do
					if(not tmp_block[i] in blocks_seen) then
						Add(blocks_to_scan, tmp_block[i]);
					fi;
					i:=i+1;
				od;
			od;
		od;
		Add(grand_seen, Unique(points_seen));
		Add(grand_blocks_seen, blocks_seen);
		blocks:=MultisetDifference(blocks, blocks_seen);
	od;

	return Unique(grand_blocks_seen);
end);

BindGlobal("IsChordedDG",function(B,pointsList)
	local col,blocks,block_to_remove,a,b;
	a:=pointsList[1];
	b:=pointsList[2];
	col:=MultisetDifference(Sort2([a,b]), MultisetIntersection(B.negatives[1],Sort2(pointsList)))[1];
	blocks:=GetMutableListList(B.blocks);
	block_to_remove:=MultisetDifference(B.negatives[1], MultisetIntersection(B.negatives[1],Sort2(pointsList)));
	Add(block_to_remove, col);
	blocks:=MultisetDifference(blocks, [Sort2(block_to_remove)]);
	return Size(ComponentsOfGraph(BlockDesign(B.v, SortListList(blocks)), [a,b])) = Size(ComponentsOfGraph(B, [a,b])) ;
end);


BindGlobal("ScanForBridgedDG",function(v)
	local B,found,flag,i,res,j,it,galf,found_non_iso;
	Print("Generating design...\n");
	B:=ISTS(v,1);
	found:=[];it:=0;found_non_iso:=[];
	Print("Searching...\n");
	while true do
		it:=it+1;

		flag:=1;j:=0;
		for i in ImproperDesignSpecialBlocks(B) do
			j:=j+1;
			res:=IsChordedDG(B,i);
			if res then
				flag:=0;
				break;
			fi;
		od;
		galf:=0;
		for i in found do
			if IsEqualBlockDesign(i, B) then
				galf:=1;
				break;
			fi;
		od;
		if flag=1 and galf=0 then
			Add(found, B);
			Add(found_non_iso, B);
			found_non_iso:=BlockDesignIsomorphismClassRepresentatives(found_non_iso);
			Print(": Found non-iso: ",Size(found_non_iso),"\t total: ",Size(found), " totally bridged.\n");
		fi;
		B:=ManyStepsImproper(B, 1);

		ShowProgressIndicator(it);
		
	od;
end);