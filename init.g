#############################################################################
##  
##  DesignMC                                                     A. L. Drizen
##  15th February 2011                                                           
## 


LoadPackage("design");
LoadPackage("JSONGAP");

BindGlobal("MAX_NEGATIVE_BLOCKS", 1);
CURRENT_TIME:=fail;

RereadDesignMC:=function()
	RereadPackage("DesignMC","lib/StringFunctions.g");
	RereadPackage("DesignMC","lib/JSON.g");
	RereadPackage("DesignMC","lib/GenericFunctions.g");
	RereadPackage("DesignMC","lib/BlockDesignFunctions.g");
	RereadPackage("DesignMC","lib/DESIGNWrapper.g");
	RereadPackage("DesignMC","lib/MarkovChain.g");
	RereadPackage("DesignMC","lib/Hillclimbing.g");
	RereadPackage("DesignMC","lib/PairGraph.g");
	RereadPackage("DesignMC","lib/Database.g");
	RereadPackage("DesignMC","lib/Sudoku.g");
	RereadPackage("DesignMC","lib/CompleteLatinSquares.g");
	RereadPackage("DesignMC","lib/LatinSquareAnalysis.g");
	RereadPackage("DesignMC","lib/Misc.g");
	RereadPackage("DesignMC","lib/FindCounterExample.g");
	RereadPackage("DesignMC","lib/SurveyDesigns.g");
	RereadPackage("DesignMC","lib/Genetic.g");
	RereadPackage("DesignMC","lib/EstimateSizeOfSubsets.g");
end;

RereadDesignMC();