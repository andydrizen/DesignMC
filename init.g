#############################################################################
#  
#  DesignMC                                                     A. L. Drizen
#  15th February 2011                                                           
# 
#############################################################################

LoadPackage("DESIGN");
LoadPackage("JSONGAP");

BindGlobal("MAX_NEGATIVE_BLOCKS", 1);

CURRENT_TIME:=fail;

RereadDesignMC:=function()

# 	Dependencies

	RereadPackage("Strings","lib/StringFunctions.g");
	RereadPackage("JSONGAP","lib/JSON.g");

# 	Core

	RereadPackage("DesignMC","lib/Core/GenericFunctions.g");
	RereadPackage("DesignMC","lib/Core/BlockDesignFunctions.g");
	RereadPackage("DesignMC","lib/Core/DesignWrapper.g");
	RereadPackage("DesignMC","lib/Core/MarkovChain.g");
	RereadPackage("DesignMC","lib/Core/PairGraph.g");

#	Extras

# 	RereadPackage("DesignMC","lib/Extras/SteinerTripleSystems.g");
# 	RereadPackage("DesignMC","lib/Extras/Misc.g");
# 	RereadPackage("DesignMC","lib/Extras/MySQL.g");
# 	RereadPackage("DesignMC","lib/Extras/SurveyDesigns.g");
#	RereadPackage("DesignMC","lib/Extras/LatinSquareAnalysis.g");
#	RereadPackage("DesignMC","lib/Extras/IO.g");
#	RereadPackage("DesignMC","lib/Extras/JSON.g");
#	RereadPackage("DesignMC","lib/Extras/Hillclimbing.g");
#	RereadPackage("DesignMC","lib/Extras/Genetic.g");
#	RereadPackage("DesignMC","lib/Extras/FindCounterExample.g");
# 	RereadPackage("DesignMC","lib/Extras/EstimateSizeOfSubsets.g");
#	RereadPackage("DesignMC","lib/Extras/CompleteLatinSquares.g");
#  	RereadPackage("DesignMC","lib/Extras/Sudoku.g");
end;

RereadDesignMC();
