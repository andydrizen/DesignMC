#############################################################################
##  
##  DesignMC                                                     A. L. Drizen
##  15th February 2011                                                           
## 


LoadPackage("design");

BindGlobal("MAX_NEGATIVE_BLOCKS", 1);
BindGlobal("CURRENT_TIME",fail);

ReadPackage("DesignMC","lib/GenericFunctions.g");
ReadPackage("DesignMC","lib/BlockDesignFunctions.g");
ReadPackage("DesignMC","lib/DESIGNWrapper.g");
ReadPackage("DesignMC","lib/MarkovChain.g");
ReadPackage("DesignMC","lib/Hillclimbing.g");
ReadPackage("DesignMC","lib/PairGraph.g");
ReadPackage("DesignMC","lib/Database.g");
ReadPackage("DesignMC","lib/Sudoku.g");
ReadPackage("DesignMC","lib/CompleteLatinSquares.g");
ReadPackage("DesignMC","lib/Transversals.g");
ReadPackage("DesignMC","lib/Misc.g");
