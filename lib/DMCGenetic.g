################################################################################
# DesignMC/lib/Genetic.g                                        Andy L. Drizen
#                                                                   25/02/2011
# File overview:
# 
# DMCBeginEvolution on a design D for a property that you want o optimise.
#
################################################################################

BindGlobal("DMCCreatePopulation",function(D, population_size)
	local population,i;
	population:=[];
	for i in [1..population_size] do
		DMCShowProgressIndicator(i);
		Add(population, ManyStepsProper(D, 10));
	od;
	return population;
end);

BindGlobal("DMCJudgePopulation",function(population, criterion)
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

BindGlobal("DMCMutateCitizen",function(citizen)
	#if Random([0,1]) = 0 then
		citizen:=ManyStepsProper(citizen, 1);
	#fi;
	return citizen;
end);

BindGlobal("DMCMateCitizens",function(mother, father)
	local child;
	child:=ShallowCopy(mother[2]);
	return child;
end);

BindGlobal("DMCBreedNewPopulationFromWinners",function(population_size, winners)
	local population, mother, father, child;
	population:=[];
	while Size(population)<population_size do
		mother:=Random(winners);
		father:=Random(winners);
		child:=DMCMateCitizens(mother, father);
		child:=DMCMutateCitizen(child);
		Add(population, child);
	od;
	return population;
end);

BindGlobal("DMCBeginEvolution",function(D, population_size, criterion_to_optimise, ShouldMaximise)
	local population, winners, best_so_far,k;
	if ShouldMaximise then
		k:=0;
	else
		k:=99999999999;
	fi;
	best_so_far:=rec(design:=[], criterion_value:=k);
	Print("Spawning intial population...");
	population:=DMCCreatePopulation(D, population_size);
	Print("\n..done!\n");
	while true do
		winners:=DMCJudgePopulation(population, criterion_to_optimise);
		if (ShouldMaximise and winners[1][1] > best_so_far.criterion_value) or ((not ShouldMaximise) and winners[1][1] < best_so_far.criterion_value) then
			Print("We've found a new best citizen!\n",winners[1][2],"\n\nCriterion Value: ",winners[1][1],"\n---------------------\n\n");
			best_so_far.criterion_value:=winners[1][1];
			best_so_far.design:=ShallowCopy(winners[1][2]);
		else
			#Print("nothing of note in this generation (best was only ",winners[1][1],")\n");
		fi;
		population:=DMCBreedNewPopulationFromWinners(population_size, winners);
	od;
end);
