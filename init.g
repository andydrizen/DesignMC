#############################################################################
#  
#  DesignMC                                                     A. L. Drizen
#  15th February 2011                                                           
# 
#############################################################################

LoadPackage("DESIGN");
LoadPackage("JSONGAP");

BindGlobal("DMC_MAX_NEGATIVE_BLOCKS", 1);
BindGlobal("DMC_CURRENT_TIME", fail);
DMC_SUDOKU_FOUND := [];

RereadDesignMC:=function()
	RereadPackage("DesignMC","lib/StringFunctions.g");
	RereadPackage("DesignMC","lib/JSON.g");
	RereadPackage("DesignMC","lib/DMCGenericFunctions.g");
	RereadPackage("DesignMC","lib/DMCBlockDesignFunctions.g");
	RereadPackage("DesignMC","lib/DMCDesignWrapper.g");
	RereadPackage("DesignMC","lib/DMCMarkovChain.g");
	RereadPackage("DesignMC","lib/DMCHillclimbing.g");
	RereadPackage("DesignMC","lib/DMCPairGraph.g");
	RereadPackage("DesignMC","lib/DMCMySQL.g");
	RereadPackage("DesignMC","lib/DMCIO.g");
	RereadPackage("DesignMC","lib/DMCJSON.g");
 	RereadPackage("DesignMC","lib/DMCSudoku.g");
	RereadPackage("DesignMC","lib/DMCCompleteLatinSquares.g");
	RereadPackage("DesignMC","lib/DMCLatinSquareAnalysis.g");
	RereadPackage("DesignMC","lib/DMCSteinerTripleSystems.g");
	RereadPackage("DesignMC","lib/DMCMisc.g");
	RereadPackage("DesignMC","lib/DMCDMCFindCounterExample.g");
	RereadPackage("DesignMC","lib/DMCSurveyDesigns.g");
	RereadPackage("DesignMC","lib/DMCGenetic.g");
	RereadPackage("DesignMC","lib/DMCEstimateSizeOfSubsets.g");
end;

RereadDesignMC();
