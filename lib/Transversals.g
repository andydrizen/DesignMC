################################################################################
# DesignMC/lib/Sudoku.g                                         Andy L. Drizen
#                                                                   15/02/2011
# File overview:
# 
# BlockDesignsModified is a modified version of L H Soicher's DESIGN package
# function called BlockDesigns. It gives the user the ability to ignore the 
# computation of the AutGroup for the given BlockDesign if isoLevel = 0. To use  
# the modification, pass ignoreAutGroupComputationForBlockDesign:=true in the 
# param.
# 
# PartialTransversals will (in a brute force fashion) try to find all partial 
# transversals.
# 
# FindAllTransversals will filter PartialTransversals to remove any items
# which are not full transversals.
#
################################################################################

BindGlobal("BlockDesignsModified",function(param)
#
# Function to classify block designs with given properties. 
#
# These block designs need not be simple and block sizes 
# need not be constant.  These block designs need not even be
# binary, although this is the default.
#
local t,v,b,blocksizes,k,lambda,blocknumbers,blockmaxmultiplicities,
   r,blockintersectionnumbers,isolevel,C,G,B,N,ntflags,
   act,rel,weightvector,gamma,KK,L,S,s,hom,GG,CC,NN,leastreps,
   clique,ans,blockbags,c,d,i,j,jj,issimple,allbinary,tsubsetstructure,
   blocks,blockdesign,A,kk,AA,tsubsets,maxlambda,targetvector,weightvectors,
   designinfo,lambdavec,lambdamat,m,T,bb,justone,isnormal,issylowtowergroup,
   testfurther;

act := function(x,g) 
# The boolean variable  allbinary  is global, and  allbinary=true 
# iff all possible blocks are sets.
if allbinary or IsSet(x.comb) then
   return rec(comb:=OnSets(x.comb,g),mult:=x.mult); 
else
   return rec(comb:=OnMultisetsRecursive(x.comb,g),mult:=x.mult); 
fi;
end;
             
weightvector := function(x)
# param, v, t, blocksizes, and tsubsets are global
local wv,c,i,xx;
wv:=ListWithIdenticalEntries(Length(tsubsets),0);
xx:=ListWithIdenticalEntries(v,0);
for i in x.comb do 
   xx[i]:=xx[i]+1;
od;
for c in Combinations(Set(x.comb),t) do
   wv[PositionSorted(tsubsets,c)]:=x.mult*Product(xx{c});
od;
if IsBound(param.r) then 
   Append(wv,x.mult*xx);
fi;
if IsBound(param.blockNumbers) then 
   for i in [1..Length(blocksizes)] do
      if Length(x.comb)=blocksizes[i] then
         Add(wv,x.mult);
      else
         Add(wv,0);
      fi;
   od;
fi;
if IsBound(param.b) then
   Add(wv,x.mult);
fi;
return wv;
end;
rel := function(x,y) 
# v, blocksizes, targetvector, blockbags, weightvectors, 
# and blockintersectionnumbers are global.
# The parameters x and y are indices into blockbags (and weightvectors).
local i,xx,yy,s;
if blockbags[x].comb=blockbags[y].comb then
   return false;
fi;
s:=weightvectors[x]+weightvectors[y];
if HasLargerEntry(s,targetvector) then
   return false;
fi;
if allbinary or (IsSet(x) and IsSet(y)) then
   s:=Size(Intersection(blockbags[x].comb,blockbags[y].comb));
else 
   xx:=ListWithIdenticalEntries(v,0);
   yy:=ListWithIdenticalEntries(v,0);
   for i in blockbags[x].comb do 
      xx[i]:=xx[i]+1;
   od;
   for i in blockbags[y].comb do 
      yy[i]:=yy[i]+1;
   od;
   s:=0;
   for i in [1..v] do
      s:=s+Minimum(xx[i],yy[i]);
   od;
fi;
return 
   s in blockintersectionnumbers[Position(blocksizes,Length(blockbags[x].comb))][Position(blocksizes,Length(blockbags[y].comb))]; 
end;

#
# begin BlockDesigns
# 
if not IsRecord(param) then
   Error("usage: BlockDesigns( <Record> )");
fi;
param:=ShallowCopy(param);
if not IsSubset(["v","blockSizes","tSubsetStructure","blockDesign",
                 "blockMaxMultiplicities","blockIntersectionNumbers",
		 "r","blockNumbers","b","isoLevel","isoGroup",
		 "requiredAutSubgroup","ignoreAutGroupComputationForBlockDesign"], 
                RecNames(param)) then
   Error("<param> contains an invalid component-name");
fi;   
if not IsSubset(RecNames(param),["v","blockSizes","tSubsetStructure"]) then
   Error("<param> missing a required component");
fi;   
v:=param.v;
if not IsPosInt(v) then
   Error("<param>.v must be positive integer");
fi;
blocksizes:=ShallowCopy(param.blockSizes);
if not (IsSet(blocksizes) and blocksizes<>[] and ForAll(blocksizes,IsPosInt)) then
   Error("<param>.blockSizes must be a non-empty set of positive integers"); 
fi;
if Length(blocksizes)=1 then 
   k:=blocksizes[1];
fi;
if not IsBound(param.blockDesign) then
   allbinary:=true;
else
   allbinary:=IsBinaryBlockDesign(param.blockDesign);
fi;
# Note: allbinary=true iff all possible blocks are sets.
tsubsetstructure:=ShallowCopy(param.tSubsetStructure);
if not ForAll(tsubsetstructure.lambdas,x->IsInt(x) and x>=0) then
   Error("all <param>.tSubsetStructure.lambdas must be non-negative integers");
fi;
if not IsDuplicateFree(tsubsetstructure.lambdas) then
   Error("<param>.tSubsetStructure.lambdas must not contain duplicates");
fi;
if IsBound(tsubsetstructure.partition) then
   if Length(tsubsetstructure.partition)<>Length(tsubsetstructure.lambdas) then
      Error("<param>.tSubsetStructure.partition must have the same length\n",
            "as <param>.tSubsetStructure.lambdas");
   fi;
elif Length(tsubsetstructure.lambdas)<>1 then
   Error("must have Length(<param>.tSubsetStructure.lambdas)=1\n",
         "if <param>.tSubsetStructure.partition is unbound");
fi;
t:=tsubsetstructure.t;
if not (IsInt(t) and t>=0 and t<=v) then
   Error("<t> must be an integer with 0<=<t><=<v>");
fi;
if not ForAll(blocksizes,x->x>=t) then 
   Error("each element of <blocksizes> must be >= <t>");
fi;
if IsBound(tsubsetstructure.partition) then
   # check it
   if not ForAll(tsubsetstructure.partition,x->IsSet(x) and x<>[]) then 
      Error("the parts of the t-subset partition must be non-empty sets");
   fi;
   c:=Concatenation(tsubsetstructure.partition);
   if not ForAll(c,x->IsSet(x) and Size(x)=t) then
      Error("the parts of the t-subset partition must be sets of t-subsets");
   fi;
   if Length(c)<>Binomial(v,t) or Length(Set(c))<>Binomial(v,t) then
      Error("t-subset partition is not a partition of the t-subsets");
   fi;
fi;
maxlambda:=Maximum(tsubsetstructure.lambdas);
if maxlambda<1 then
   Error("at least one element of <param>.tSubsetStructure.lambdas must be positive");
fi;
if Length(tsubsetstructure.lambdas)=1 then
   # constant lambda 
   lambda:=tsubsetstructure.lambdas[1];
fi;
tsubsets:=Combinations([1..v],t);
if IsBound(param.blockMaxMultiplicities) then
   blockmaxmultiplicities:=ShallowCopy(param.blockMaxMultiplicities);
   if not (IsList(blockmaxmultiplicities) and ForAll(blockmaxmultiplicities,x->IsInt(x) and x>=0)) then
      Error("<param>.blockMaxMultiplicities must be a list of non-negative integers");
   fi;   
   if Length(blockmaxmultiplicities)<>Length(blocksizes) then 
      Error("must have Length(<param>.blockMaxMultiplicities)=Length(<param>.blockSizes)");
   fi;
   blockmaxmultiplicities:=List(blockmaxmultiplicities,x->Minimum(x,maxlambda));
   # since *every* possible block is required to contain at least 
   # t  distinct points.
else 
   blockmaxmultiplicities:=ListWithIdenticalEntries(Length(blocksizes),maxlambda);
fi;
if IsBound(param.blockIntersectionNumbers) then
   blockintersectionnumbers:=StructuralCopy(param.blockIntersectionNumbers);
   if Length(blockintersectionnumbers)<>Length(blocksizes) then 
      Error("must have Length(<param>.blockIntersectionNumbers>)=Length(<param>.blockSizes>)");
   fi;
   blockintersectionnumbers:=List(blockintersectionnumbers,x->List(x,Set));
   if blockintersectionnumbers<>TransposedMat(blockintersectionnumbers) then
      Error("<blockintersectionnumbers> must be a symmetric matrix");
   fi;
else 
   blockintersectionnumbers:=List([1..Length(blocksizes)],x->List([1..Length(blocksizes)],
                      y->[0..Minimum(blocksizes[x],blocksizes[y])]));
fi;
if allbinary and maxlambda<=1 then 
   blockintersectionnumbers:=List(blockintersectionnumbers,x->List(x,y->Intersection(y,[0..t-1])));
fi;
# Compute the number  ntflags  of (t-subset,block)-flags 
# (counting multiplicities). 
if IsBound(lambda) then
   ntflags:=lambda*Binomial(v,t); 
else
   ntflags:=tsubsetstructure.lambdas*List(tsubsetstructure.partition,Length);
fi;
if IsBound(param.blockNumbers) then
   blocknumbers:=ShallowCopy(param.blockNumbers);
   # We will require  blocknumbers[i]  blocks of size  blocksizes[i] 
   # for i=1,...,Length(blocknumbers).
   if not (IsList(blocknumbers) and ForAll(blocknumbers,x->IsInt(x) and x>=0)) then
      Error("<param>.blockNumbers must be a list of non-negative integers"); 
   fi;
   if Length(blocknumbers)<>Length(blocksizes) then
      Error("must have Length(<param>.blockNumbers)=Length(<param>.blockSizes)");
   fi;
   b:=Sum(blocknumbers);
   if b=0 then
      Error("At least one element of <param>.blockNumbers must be positive");  
   fi;
   if allbinary and IsBound(ntflags) then 
      # compute the number  s  of (t-subset,block)-flags and compare to  ntflags
      s:=Sum([1..Length(blocknumbers)],i->blocknumbers[i]*Binomial(blocksizes[i],t));
      if s<>ntflags then
         return [];
      fi;
   fi;
   if t=0 and tsubsetstructure.lambdas[1]<>Sum(blocknumbers) then 
      # contradictory blocknumbers
       return [];
   fi;
fi;
if IsBound(param.b) then
   # We will require exactly  param.b > 0 blocks.
   if not IsPosInt(param.b) then
      Error("<param>.b must be a positive integer");  
   fi;
   if IsBound(b) and b<>param.b then
      # required block design cannot have  param.b  blocks. 
      return [];
   fi;
   b:=param.b;
   if IsBound(k) and allbinary and IsBound(ntflags) and
      b<>ntflags/Binomial(k,t) then
      # required block design cannot exist. 
      return [];
   fi;
fi;
if IsBound(param.r) then
   # We will require constant replication number = param.r > 0.
   if not IsPosInt(param.r) then
      Error("<param>.r must be a positive integer");
   fi;
   r:=param.r;
fi;
if t>=1 and allbinary and IsBound(k) and IsBound(lambda) and k<=v then
   # compute the replication number  s  (and compare to  r,  if bound).
   s:=lambda*Binomial(v-1,t-1)/Binomial(k-1,t-1);
   if not IsInt(s) or IsBound(r) and r<>s then
      # no possible design
      return [];
   else 
      r:=s;
   fi;
fi;
if t=1 and IsBound(lambda) then
   # compute the replication number  s  (and compare to  r,  if bound).
   s:=lambda;
   if IsBound(r) and r<>s then
      # no possible design
      return [];
   else 
      r:=s;
   fi;
fi;
if allbinary and IsBound(k) and IsBound(lambda) then
   if k>v then
      # requirements force at least one block, but this is impossible
      return [];
   fi;
   #
   # We now have v,k,lambda>0, 0<=t<=k<=v, 
   # and are looking for t-(v,k,lambda) designs. 
   #
   s:=TDesignLambdas(t,v,k,lambda);
   if s=fail then
      # parameters t-(v,k,lambda) inadmissible
      return [];
   fi;
   blockmaxmultiplicities[1]:=Minimum(blockmaxmultiplicities[1],
      TDesignBlockMultiplicityBound(t,v,k,lambda));
   if blockmaxmultiplicities[1]<1 then
      return [];
   fi;
   if t>=2 then 
      if k<v and s[1]=v then
         # Possible SBIBD; each pair of distinct blocks must meet 
         # in exactly  s[3]  points.
         blockintersectionnumbers[1][1]:=
            Intersection(blockintersectionnumbers[1][1],[s[3]]);
      fi;
      designinfo:=rec(lambdavec:=Immutable(s));
      if lambda=1 then
         # We are looking for Steiner systems, so we know how many blocks
         # intersect a given block in a given number of points.
         designinfo.blockmmat:=[];
         T:=SteinerSystemIntersectionTriangle(t,v,k);
         T:=List([1..k+1],i->Binomial(k,i-1)*T[i][k+2-i]);
         designinfo.blockmmat[k]:=Immutable(T);
         for i in [0..k-1] do
            if T[i+1]=0 then
               RemoveSet(blockintersectionnumbers[1][1],i);
            fi;
         od;
      fi;
   fi;   
   if blockintersectionnumbers[1][1]=[] and s[1]>1 then
      return [];
   fi;
elif allbinary and t=2 and IsBound(lambda) then
   # We are looking for pairwise-balanced designs. 
   if (lambda*(v-1)) mod Gcd(List(blocksizes,x->x-1)) <> 0 then
      return [];
   fi;
   if (lambda*v*(v-1)) mod Gcd(List(blocksizes,x->x*(x-1))) <> 0 then
      return [];
   fi;
   if IsBound(b) then
      if b<lambda*Binomial(v,2)/Binomial(Maximum(blocksizes),2) 
         # b is too small
         or b>lambda*Binomial(v,2)/Binomial(Minimum(blocksizes),2) then
         # or b is too big
         return [];
      fi;
      if not (v in blocksizes) and b<v then
         # Generalized Fisher inequality is not satisfied.
         return [];
      fi;
   elif not (v in blocksizes) and 
      lambda*Binomial(v,2)/Binomial(Minimum(blocksizes),2)<v then
      # Generalized Fisher inequality is not satisfied.
      return [];
   fi;
   if IsBound(r) and IsBound(b) then
      designinfo:=rec(lambdavec:=Immutable([b,r,lambda]));
   fi;
elif allbinary and t=2 and IsBound(k) then
   lambdamat:=NullMat(v,v,Rationals);
   for i in [1..Length(tsubsetstructure.partition)] do
      for c in tsubsetstructure.partition[i] do
         lambdamat[c[1]][c[2]]:=tsubsetstructure.lambdas[i];
         lambdamat[c[2]][c[1]]:=lambdamat[c[1]][c[2]];
      od;
   od;
   for i in [1..v] do
      lambdamat[i][i]:=Sum(lambdamat[i])/(k-1);
      if not IsInt(lambdamat[i][i]) or 
        (IsBound(r) and lambdamat[i][i]<>r) then
         return [];
      fi;
   od; 
   if ForAll([1..v],i->lambdamat[i][i]=lambdamat[1][1]) then
      r:=lambdamat[1][1];
   fi;
   bb:=Sum(List([1..v],i->lambdamat[i][i]))/k;
   if not IsInt(bb) or (IsBound(b) and b<>bb) then 
      return [];
   else
      b:=bb;
   fi;
   if IsBound(r) then
      designinfo:=
         rec(lambdavec:=Immutable([b,r]),lambdamat:=Immutable(lambdamat));
   else
      designinfo:=
         rec(lambdavec:=Immutable([b]),lambdamat:=Immutable(lambdamat));
   fi;
fi;
for i in [1..Length(blockmaxmultiplicities)] do 
   if blockmaxmultiplicities[i]>1 and 
      not (blocksizes[i] in blockintersectionnumbers[i][i]) then 
      blockmaxmultiplicities[i]:=1;
   fi;
od;
if IsBound(designinfo) and Length(designinfo.lambdavec)>=3 then
   # Apply bound of Cameron and Soicher to each block max-multiplicity, 
   # and each block intersection size. 
   if Length(designinfo.lambdavec) mod 2 = 0 then
      lambdavec:=designinfo.lambdavec{[1..Length(designinfo.lambdavec)-1]};
   else
      lambdavec:=designinfo.lambdavec;
   fi;
   for i in [1..Length(blockmaxmultiplicities)] do
      m:=ListWithIdenticalEntries(blocksizes[i]+1,0);
      while m[blocksizes[i]+1]<=blockmaxmultiplicities[i] and 
         BlockIntersectionPolynomialCheck(m,lambdavec) do
         m[blocksizes[i]+1]:=m[blocksizes[i]+1]+1;
      od;
      blockmaxmultiplicities[i]:=m[blocksizes[i]+1]-1;
      if blockmaxmultiplicities[i]<0 then
         return [];
      fi;
      for jj in [0..blocksizes[i]] do
         m:=ListWithIdenticalEntries(blocksizes[i]+1,0);
         m[blocksizes[i]+1]:=1;
         m[jj+1]:=m[jj+1]+1;
         if not BlockIntersectionPolynomialCheck(m,lambdavec) then
            for j in [1..Length(blockmaxmultiplicities)] do
               RemoveSet(blockintersectionnumbers[i][j],jj);
            od;
         fi;
      od;
   od;
fi;
if ForAll(blockmaxmultiplicities,x->x=0) then
   # no blocks, but the given parameters force at least one block
   return [];
fi;
if IsBound(param.isoLevel) then 
   isolevel:=param.isoLevel;
else
   isolevel:=2;
fi;
if IsBound(param.blockDesign) then
   # We are computing subdesigns of  param.blockDesign
   if not IsBlockDesign(param.blockDesign) then
      Error("<param>.blockDesign must be a block design");
   fi;
   if v<>param.blockDesign.v then
      Error("must have <param>.v=<param>.blockDesign.v");
   fi;
fi;
if IsBound(param.isoGroup) then
   G:=param.isoGroup;
   # 
   # G  must preserve the point-set structure of the required subdesign(s),
   # as well as the multiset  param.blockDesign.blocks  
   # (if  param.blockDesign is given).  
   #
   if not IsPermGroup(G) or v<LargestMovedPoint(GeneratorsOfGroup(G)) then 
      Error("<param>.isoGroup must be a permutation group on [1..<v>]");
   fi;
   if IsBound(tsubsetstructure.partition) then
      for i in [1..Length(tsubsetstructure.partition)-1] do
         s:=tsubsetstructure.partition[i];
         if not ForAll(GeneratorsOfGroup(G),x->OnSetsSets(s,x)=s) then
            Error("t-subset structure not invariant under <param>.isoGroup");
         fi;
      od;
   fi;
   if IsBound(param.blockDesign) then 
      s:=param.blockDesign.blocks;
      if not ForAll(GeneratorsOfGroup(G),x->OnMultisetsRecursive(s,x)=s) then
         Error("<param>.blockDesign.blocks not invariant under <param>.isoGroup");
      fi;
   fi;
else
   if IsBound(param.blockDesign) then
      if (IsBound(param.ignoreAutGroupComputationForBlockDesign) and param.isoLevel=0) then
            G:=Group(());
	  else
            G:=AutGroupBlockDesign(param.blockDesign);
      fi;
   else
      G:=SymmetricGroup(v);
      SetSize(G,Factorial(v));
   fi;
   if IsBound(tsubsetstructure.partition) and 
      Length(tsubsetstructure.partition)>1 then
      # G:=the subgroup of G fixing the t-subset structure (ordered) partition
      hom:=ActionHomomorphism(G,tsubsets,OnSets,"surjective");
      GG:=Image(hom);
      StabChainOp(GG,rec(limit:=Size(G)));
      for i in [1..Length(tsubsetstructure.partition)-1] do
         GG:=Stabilizer(GG,
             List(tsubsetstructure.partition[i],x->PositionSorted(tsubsets,x)),
             OnSets);
      od;
      G:=PreImage(hom,GG);
   fi;
fi;
if IsBound(param.requiredAutSubgroup) then 
   if not IsSubgroup(G,param.requiredAutSubgroup) then
      Error("<param>.requiredAutSubgroup must be a subgroup of <G>");
   fi;
   C:=param.requiredAutSubgroup;
else
   C:=Group(());
fi;
C:=AsSubgroup(G,C);
if IsBound(param.blockDesign) then
   B:=Collected(param.blockDesign.blocks);
   blockbags:=[]; # initialize list of possible blocks and multiplicities
   for c in B do 
      if IsSet(c[1]) then
         s:=c[1];
      else 
         s:=Set(c[1]);
      fi;
      if Length(s)<t then
         Error("cannot give possible block with fewer than <t> distinct elements");
      fi;
      if Length(c[1]) in blocksizes then
         # cannot reject this possible block out of hand
         d:=blockmaxmultiplicities[Position(blocksizes,Length(c[1]))];
         for i in Reversed([1..Minimum(c[2],d)]) do 
            Add(blockbags,rec(comb:=c[1],mult:=i)); 
         od;
      fi;
   od;
else 
   for i in [1..Length(blocksizes)] do
      if blocksizes[i]>v then
         blockmaxmultiplicities[i]:=0;
         # since allbinary=true here
      fi;
   od;
   if ForAll(blockmaxmultiplicities,x->x=0) then
      # no blocks, but the given parameters force at least one block
      return [];
   fi;
   blockbags:=Concatenation(List(Reversed([1..Length(blocksizes)]),i->
       List(Cartesian(Reversed([1..blockmaxmultiplicities[i]]),
               Combinations([1..v],blocksizes[i])),
               x->rec(mult:=x[1],comb:=x[2]))));
fi;
if IsBound(lambda) then 
   targetvector:=ListWithIdenticalEntries(Length(tsubsets),lambda);
else
   targetvector:=[];
   for i in [1..Length(tsubsetstructure.lambdas)] do
      for c in tsubsetstructure.partition[i] do
         targetvector[PositionSorted(tsubsets,c)]:=tsubsetstructure.lambdas[i];
      od;
   od;
fi;
if IsBound(param.r) then 
   targetvector:=Concatenation(targetvector,ListWithIdenticalEntries(v,r));
fi;
if IsBound(param.blockNumbers) then 
   Append(targetvector,blocknumbers);
fi;
if IsBound(param.b) then 
   Add(targetvector,b);
fi;
hom:=ActionHomomorphism(G,blockbags,act,"surjective");
GG:=Image(hom);
StabChainOp(GG,rec(limit:=Size(G)));
weightvectors:=List(blockbags,weightvector); # needed for function  rel
# Determine the least C-orbit representatives for the action
# of C on the positions in weightvectors.
L:=List(OrbitsDomain(C,tsubsets,OnSets),Minimum);
leastreps:=Set(List(L,x->PositionSorted(tsubsets,x)));
s:=Length(tsubsets);
if IsBound(param.r) then
   Append(leastreps,Set(List(OrbitsDomain(C,[1..v]),x->s+Minimum(x)))); 
   s:=s+v;
fi;
if IsBound(param.blockNumbers) then
   Append(leastreps,[s+1..s+Length(blocknumbers)]);
   s:=s+Length(blocknumbers);
fi;
if IsBound(param.b) then
   Add(leastreps,s+1);
fi;
# Make graph on "appropriate" collapsed Image(hom,C)-orbits.
CC:=Image(hom,C);
StabChainOp(CC,rec(limit:=Size(C)));
N:=Normalizer(G,C);
NN:=Image(hom,N);
StabChainOp(NN,rec(limit:=Size(N)));
S:=OrbitsDomain(NN,[1..Length(blockbags)]);
L:=[]; # initialize list of appropriate CC-orbits
for s in S do
   c:=Orbit(CC,s[1]);
   # check if  c  is appropriate
   if (not IsBound(designinfo) or PartialDesignCheck(designinfo,blockbags[c[1]].comb,blockbags{c})) and
      ForAll([2..Length(c)],x->rel(c[1],c[x])) and
      not HasLargerEntry(Sum(weightvectors{c}),targetvector) then
      #  c  is appropriate 
      Append(L,Orbit(NN,Set(c),OnSets));
   fi;
od;
testfurther:=IsBound(designinfo) and Size(NN)/Size(CC)>=Length(L); 
gamma:=Graph(NN,L,OnSets,
   function(x,y)
   local c;
   if not ForAll(y,z->rel(x[1],z)) or HasLargerEntry(
      Sum(weightvectors{x})+Sum(weightvectors{y}),targetvector) then
      return false;
   fi;
   if not testfurther then
      return true;
   fi;
   c:=Concatenation(blockbags{x},blockbags{y});
   return PartialDesignCheck(designinfo,blockbags[x[1]].comb,c) and 
      PartialDesignCheck(designinfo,blockbags[y[1]].comb,c); 
   end,
  true);     
KK:=CompleteSubgraphsMain(gamma,targetvector{leastreps},isolevel,
      false,false,
      List(gamma.names,x->Sum(weightvectors{x}){leastreps}),
      [1..Length(leastreps)]);
KK:=List(KK,x->rec(clique:=Union(List(x,y->gamma.names[y]))));
if isolevel=0 and Length(KK)>0 then
   # Compute the G-stabilizer of the single design.
   KK[1].stabpreim:=PreImage(hom,Stabilizer(GG,KK[1].clique,OnSets));
fi;
if isolevel=2 then
   #
   # Compute the G-stabilizers of the designs, and perform
   # any GG-isomorph rejection which is not already known to 
   # have been performed by  Image(hom,Normalizer(G,C)).
   #
   justone:=Length(KK)=1;
   if not justone then
      isnormal:=IsNormal(G,C);
      if not isnormal then
         issylowtowergroup:=IsSylowTowerGroupOfSomeComplexion(C);
      fi;
   fi;
   L:=[];
   S:=[];
   for kk in KK do
      AA:=Stabilizer(GG,kk.clique,OnSets);
      A:=PreImage(hom,AA);
      kk.stabpreim:=A;
      if justone or isnormal or Size(C)=Size(A) or 
         Gcd(Size(C),Size(A)/Size(C))=1 and (issylowtowergroup or IsSolvableGroup(A)) or
         IsCyclic(C) and IsNilpotentGroup(A) and 
            ForAll(Set(FactorsInt(Size(C))),
               p->Index(A,SubgroupNC(A,List(GeneratorsOfGroup(A),g->g^p)))=p) or
         IsSimpleGroup(C) and IsNormal(A,C) and (Size(A) mod (Size(C)^2) <> 0) 
            then
         # KK  has just one element  or  C is normal in G  or  
         # C=A  or  C is a Hall subgroup of A and C has a Sylow tower  or
         # A is solvable and C is a Hall subgroup of A  or
         # A is nilpotent and C is contained in a cyclic
         # Hall pi(C)-subgroup of A  or
         # C is a simple normal subgroup of A and is the only
         # subgroup of A of its isomorphism type. 
         # Thus, Length(KK)=1  or  C is normal in G,  or
         # C is a "friendly" subgroup of A
         # (see: L.H. Soicher, Computational group theory problems arising 
         # from computational design theory, Oberwolfach Rep. 3 (2006), 
         # Report 30/2006: Computational group theory, 1809-1811,  
         # (preprint at: http://designtheory.org/library/preprints/ ), and
         # P. Hall, Theorems like Sylow's, Proc. LMS 6, 1956).
         # It follows that isomorph-rejection of GG-images of kk.clique 
         # has already been handled by  Image(hom,Normalizer(G,C)),  
         # and so no further isomorph-rejection (using GG) is needed.
         Add(L,kk);
      else
         s:=SmallestImageSet(GG,kk.clique,AA);
         if not (s in S) then 
            Add(S,s);
            Add(L,kk);
         fi;
      fi;
   od;
   KK:=L; 
fi;
ans:=[];
for kk in KK do
   blocks:=[];
   issimple:=true;
   for c in kk.clique do
      if blockbags[c].mult>1 then 
         issimple:=false;
      fi;
      for d in [1..blockbags[c].mult] do
         Add(blocks,blockbags[c].comb);
      od;
   od;
   blockdesign:=rec(isBlockDesign:=true,v:=v,blocks:=AsSortedList(blocks),
      tSubsetStructure:=Immutable(tsubsetstructure),  
      isBinary:=allbinary or ForAll(blocks,IsSet),isSimple:=issimple);
   blockdesign.blockSizes:=BlockSizes(blockdesign); 
   blockdesign.blockNumbers:=BlockNumbers(blockdesign);
   c:=ReplicationNumber(blockdesign);
   if c<>fail then
      blockdesign.r:=c;
   fi;
   if isolevel<>1 then
      if not IsBound(param.isoGroup) and 
         ( not IsBound(param.blockDesign) or 
            IsBound(param.blockDesign.autGroup) and 
               param.blockDesign.autGroup=SymmetricGroup(v) ) then
         blockdesign.autGroup:=kk.stabpreim;
      else 
         blockdesign.autSubgroup:=kk.stabpreim;
      fi;
   fi;
   if IsBound(param.blockDesign) and IsBound(param.blockDesign.pointNames) then
      blockdesign.pointNames:=Immutable(param.blockDesign.pointNames);
   fi;
   Add(ans,blockdesign);
od;
if (IsBound(param.ignoreAutGroupComputationForBlockDesign) and param.isoLevel=0) then
	Unbind(ans[1].autSubgroup);
fi;
return ans;
end);

BindGlobal("FindTransversal",function(Design,lambda)
	return BlockDesignsModified(
		rec(
		    v:=Design.v, 
			blockDesign:=Design,
		    blockSizes:=[3],
		    tSubsetStructure:=rec(t:=1, lambdas:=[lambda]),
		    isoLevel:=0,
			ignoreAutGroupComputationForBlockDesign:=true
		)
	);
end);

# dependencies: 	GetMutableListList, Sort2, SortListList, DuplicateList, get_blocks_containing_list,
#					ShowPercentIndicatorSimple, MultisetDifference

#
# Don't know how to do BindGlobal with recursive functions
#

PartialTransversals:=function( D, lambda, findAll, depth )
local i,j,k,transversal,all_transversals,chosen_block,sub_design_blocks,tmp,D2,E,tmp_point_set,m;
	D2:=ShallowCopy(D);
	all_transversals:=[];
	if( not IsBound(D2.point_set) ) then
	
		# all of the initial setup happens here
	
		D2.blocks:=GetMutableListList(D2.blocks);
		for i in [1..Size(D2.blocks)] do
			Add(D2.blocks[i],[i]);
		od;
		D2.blocks:=SortListList(D2.blocks);
		D2.v:=D2.v+Size(D2.blocks);
		D2.point_set:=Sort2(DuplicateList([1..(D2.v-Size(D2.blocks))],lambda));
	fi;
	
	for i in [1..Size(get_blocks_containing_list(D2, [D2.blocks[1][1]]))] do
	
		if (IsBound(D2.tSubsetStructure)) then
			m:=D2.tSubsetStructure.lambdas[1];
		else
			m:=1;
		fi;
	
		if(depth = 1 and findAll = true) then
			ShowPercentIndicatorSimple(i-1,m*(D2.v-Size(D2.blocks))/3);
		fi;
	
		tmp_point_set:=ShallowCopy(D2.point_set);
		chosen_block:=get_blocks_containing_list(D2, [D2.blocks[1][1]])[i];
		
		sub_design_blocks:=ShallowCopy(D2.blocks);
		sub_design_blocks:=MultisetDifference(sub_design_blocks, [chosen_block]);
		for j in chosen_block do
			tmp_point_set:=MultisetDifference(tmp_point_set, [j]);
			if ( not( j in tmp_point_set )) then
				sub_design_blocks:=MultisetDifference(sub_design_blocks, get_blocks_containing_list(D2, [j]));
			fi;
		od;
		
		if (Size(sub_design_blocks) > 0) then
			# we haven't yet made a full transversal.
			E:=BlockDesign(D2.v, sub_design_blocks);
			E.point_set:=ShallowCopy(tmp_point_set);
			tmp:=PartialTransversals(E,lambda, findAll, depth+1);
			for j in tmp do
				transversal:=[];
				for k in j do
					Add(transversal, k);
				od;
				
				Add(transversal, chosen_block[4]);
				Add(all_transversals,Flat(transversal));
			od;
		else
			Add(all_transversals,[chosen_block[4]]);
		fi;
		if(findAll = false ) then
			for transversal in all_transversals do
				if(Size(transversal) = (D2.v-Size(D2.blocks))/3 ) then
					return Unique(SortListList(all_transversals));
				fi;
			od;
		fi;
	od;
	return Unique(SortListList(all_transversals));
end;

BindGlobal("FindAllTransversals",function(input)

	# Finds a set of lambda*n cells, lambda in each row,
	# lambda in each column and each symbol appears in 
	# the cells lambda times.

	local D2,partials,results,i,j,results2,tmp,plambda,pfindAll;
	Print("Started Calculation at:",CurrentTime(),"\n");
	if not (IsRecord(input) ) then 
	   Error("<input> must be a record containing, at the very least, a BlockDesign.");
	fi;
	
	if ( IsBound(input.BlockDesign) and IsBlockDesign(input.BlockDesign)=true) then
		D2:=ShallowCopy(input.BlockDesign);
	else
		Error("<input>.BlockDesign must be the BlockDesign you want work with.");
	fi;
	
	if IsBound(input.lambda) then
		plambda:=input.lambda;
	else
		plambda:=1;
	fi;
	
	if IsBound(input.findAll) then
		pfindAll:=input.findAll;
	else
		pfindAll:=false;
	fi;
	
	partials:=PartialTransversals(D2, plambda, pfindAll,1);
	Print("\n");
	results:=[];
	for i in partials do
		if (Size(i) = D2.v/3 * plambda) then
			Add(results, i);
		fi;
	od;
	
	results2:=[];
	for i in results do
		tmp:=[];
		for j in i do
			Add(tmp, D2.blocks[j]);
		od;
		Add(results2, BlockDesign(D2.v,tmp));
	od;
	Print("Finished Calculation at:",CurrentTime(),"\n");
	if (pfindAll = false) then
		return [results2[1]];
	fi;
	
	return results2;
end);
