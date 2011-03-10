################################################################################
# DesignMC/lib/Genetic.g                                        Andy L. Drizen
#                                                                   25/02/2011
# File overview:
# 
# BeginEvolution on a design D for a property that you want o optimise.
#
################################################################################

BindGlobal("CreatePopulation",function(D, population_size)
	local population,i;
	population:=[];
	for i in [1..population_size] do
		ShowProgressIndicator(i);
		Add(population, ManyStepsProper(D, 10));
	od;
	return population;
end);

BindGlobal("JudgePopulation",function(population, criterion)
	local winners, assessment,i;
	winners:=[];
	assessment:=[];
	for i in [1..Size(population)] do
		Add(assessment, [criterion(population[i]), population[i]]);
	od;
	Sort(assessment);
	assessment:=Reversed(assessment);
	for i in [1..Int(Size(population)/5)] do
		Add(winners, assessment[i]);
	od;
	return winners;
end);

BindGlobal("MutateCitizen",function(citizen)
	#if Random([0,1]) = 0 then
		citizen:=ManyStepsProper(citizen, 1);
	#fi;
	return citizen;
end);

BindGlobal("MateCitizens",function(mother, father)
	local child;
	child:=ShallowCopy(mother[2]);
	return child;
end);

BindGlobal("BreedNewPopulationFromWinners",function(population_size, winners)
	local population, mother, father, child;
	population:=[];
	while Size(population)<population_size do
		mother:=Random(winners);
		father:=Random(winners);
		child:=MateCitizens(mother, father);
		child:=MutateCitizen(child);
		Add(population, child);
	od;
	return population;
end);

BindGlobal("BeginEvolution",function(D, population_size, criterion_to_optimise, ShouldMaximise)
	local population, winners, best_so_far,k;
	if ShouldMaximise then
		k:=0;
	else
		k:=99999999999;
	fi;
	best_so_far:=rec(design:=[], criterion_value:=k);
	Print("Spawning intial population...");
	population:=CreatePopulation(D, population_size);
	Print("\n..done!\n");
	while true do
		winners:=JudgePopulation(population, criterion_to_optimise);
		if (ShouldMaximise and winners[1][1] > best_so_far.criterion_value) or ((not ShouldMaximise) and winners[1][1] < best_so_far.criterion_value) then
			Print("We've found a new best citizen!\n",winners[1][2],"\n\nCriterion Value: ",winners[1][1],"\n---------------------\n\n");
			best_so_far.criterion_value:=winners[1][1];
			best_so_far.design:=ShallowCopy(winners[1][2]);
		else
			#Print("nothing of note in this generation (best was only ",winners[1][1],")\n");
		fi;
		population:=BreedNewPopulationFromWinners(population_size, winners);
	od;
end);

BindGlobal("NumTransversals",function(Design)
	return Size(FindAllTransversals(Design, 1, true));
end);
BindGlobal("NumIntercalates",function(Design)
	return Size(FindAllSubSquaresOfSize(Design, 2));
end);
