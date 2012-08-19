################################################################################
# DesignMC/lib/DMCIO.g						                        Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# Allows the user to save and load lists of designs. The DesignStructure parameter 
# is the same as the input of the BlockDesigns function
#
################################################################################

BindGlobal("DMCSaveDesigns",function( DesignStructure, path )
	PrintTo(path, "return ");
	AppendTo(path, DMC2DesignMake( DesignStructure ) );
	AppendTo(path, ";");
	return;
end);

BindGlobal("DMCLoadDesigns",function ( path )
	return ReadAsFunction(path)();
end);
