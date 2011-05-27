#include <iostream>
#include <vector>
#include <stdlib.h>
#include <time.h>
#include <algorithm>
#include <string>
#include <sstream>
#include <fstream>
#include <cmath>
using namespace std;

typedef vector< int > block;
typedef vector< block > blockSet;

class Square
{
	private:
		blockSet blocks;
		blockSet negatives;
		int v;
		int t;
		bool improper;
		int blockNumbers;
		block k;
		block vType;
		const char* path;
		
	public:
		Square( int n )
		{
			for(int i=0; i < n; i++)
			{
				
				for(int j=0; j < n; j++)
				{
					block tmp_block (3);
					int tmp_blockArr[] = {i,n + j,2*n + (i+j) % n};
					tmp_block.assign(tmp_blockArr, tmp_blockArr+3);
					blocks.push_back(tmp_block);
				}
			}

			this->v = 3*n;
			this->t = 2;
			this->improper = false;
			this->blockNumbers = n*n;

			int k[] = {1,1,1};
			this->k.assign(k, k+3);

			int vType[] = {n,n,n};
			this->vType.assign(vType, vType+3);
		}

		block generatePivot()
		{
			if (this->improper)
			{
				return this->negatives[ rand() % negatives.size() ];
			}
			
			/*
			
			To gain aperiodic status, we allow the chain to add a block that exists.
			
			*/
			//bool IsAlreadyABlock = true;
			block pivot;
			//while(IsAlreadyABlock)
			//{
				int pivotArr[] = {rand() % vType[0], this->vType[1] + rand() % vType[1],2*this->vType[2] + rand() % vType[2]};
				pivot.assign(pivotArr, pivotArr+3);
				
				blockSet::iterator myIt = find (blocks.begin(), blocks.end(), pivot);
				//if( myIt == blocks.end())
					//IsAlreadyABlock = false;
			//}

			return pivot;
		}
		void hopper()
		{
			block pivot = this->generatePivot();
			
			block possibilitiesZ;
			block possibilitiesY;
			block possibilitiesX;

			for (unsigned int i = 0; i < this->blocks.size(); i++)
			{
				if (pivot[0] == blocks[i][0] && pivot[1] == blocks[i][1])
					possibilitiesZ.push_back(blocks[i][2]);
				if (pivot[0] == blocks[i][0] && pivot[2] == blocks[i][2])
					possibilitiesY.push_back(blocks[i][1]);
				if (pivot[1] == blocks[i][1] && pivot[2] == blocks[i][2])
					possibilitiesX.push_back(blocks[i][0]);
			}
			
			int x = possibilitiesX[ rand() % possibilitiesX.size()];
			int y = possibilitiesY[ rand() % possibilitiesY.size()];
			int z = possibilitiesZ[ rand() % possibilitiesZ.size()];
			
			int blockToRemoveArr[] = {x,y,z};
			block blockToRemove;
			blockToRemove.assign(blockToRemoveArr, blockToRemoveArr+3);

			// Exchange blocks
			
			blockSet::iterator myIt1 = find(this->negatives.begin(), this->negatives.end(), pivot);
			if ( myIt1 == negatives.end() )
				this->blocks.push_back(pivot);
			else
				this->negatives.erase(myIt1);

			blockSet::iterator myIt2 = find(this->blocks.begin(), this->blocks.end(), blockToRemove);
			if( myIt2 == blocks.end() )
			{
				this->improper = true;
				this->negatives.push_back(blockToRemove);
			}
			else
			{
				this->improper = false;
				this->blocks.erase(myIt2);
			}
			
			int a1Arr[] = {pivot[0], y, z};
			block a1;
			a1.assign(a1Arr, a1Arr+3);
			this->blocks.push_back(a1);
			
			int a2Arr[] = {x, pivot[1], z};
			block a2;
			a2.assign(a2Arr, a2Arr+3);
			this->blocks.push_back(a2);
			
			int a3Arr[] = {x, y, pivot[2]};
			block a3;
			a3.assign(a3Arr, a3Arr+3);
			this->blocks.push_back(a3);

			int r1Arr[] = {pivot[0], pivot[1], z};
			block r1;
			r1.assign(r1Arr, r1Arr+3);
			blockSet::iterator myIt3 = find(this->blocks.begin(), this->blocks.end(), r1);
			this->blocks.erase(myIt3);
			
			int r2Arr[] = {pivot[0], y, pivot[2]};
			block r2;
			r2.assign(r2Arr, r2Arr+3);
			blockSet::iterator myIt4 = find(this->blocks.begin(), this->blocks.end(), r2);
			this->blocks.erase(myIt4);
			
			int r3Arr[] = {x, pivot[1], pivot[2]};
			block r3;
			r3.assign(r3Arr, r3Arr+3);
			blockSet::iterator myIt5 = find(this->blocks.begin(), this->blocks.end(), r3);
			this->blocks.erase(myIt5);

			sort(this->blocks.begin(), this->blocks.end());
			this->blockNumbers = blocks.size();
		}
		void oneStep()
		{
			do
			{
				this->hopper();
			}
			while (this->improper);
		}
		void manyStepsProper( int j )
		{
			for(int i=0; i<j; i++)
			{
				this->oneStep();
			}
		}
		void manyStepsImproper( int j )
		{
			for(int i=0; i<j; i++)
			{
				this->hopper();
			}
			while(this->improper == false)
			{
				this->hopper();
			}
		}
		
		bool isMainDiagonalTransversal()
		{
			block pointsOnDiagonal;
			for(int i=0; i < this->vType[0]; i++)
			{
				for(int k=vType[0]+vType[1]; k < vType[0]+vType[1]+vType[2]; k++)
				{
					int potentialBlock[] = {i,i+vType[0],k};
					block diagonalPerhaps;
					diagonalPerhaps.assign(potentialBlock, potentialBlock+3);
					blockSet::iterator myIt = find(this->blocks.begin(), this->blocks.end(), diagonalPerhaps);
					if( myIt != blocks.end() )
					{
						pointsOnDiagonal.push_back(k);
						break;
					}
				}
			}
			sort(pointsOnDiagonal.begin(), pointsOnDiagonal.end());

			for (int i = vType[0]+vType[1]; i < vType[0]+vType[1]+vType[2]; i++)
			{
				if (i!=pointsOnDiagonal[i-vType[0]-vType[1]])
					return false;
			}

			return true;
		}

		/* Setters */
		void setPath( const char* path )
		{
			this->path = path;
		}

		/* Getters */

		blockSet getBlocks()
		{
			return this->blocks;
		}

		/* Printers */
		
		void display()
		{
			
			cout << "rec(isBlockDesign:=true, v:="<< this->v <<", blocks:="<< this->stringifyBlocks(this->blocks);
			cout << ", negatives:=" << this->stringifyBlocks(this->negatives);
			cout << ", k:=["<< this->k[0]<<","<<this->k[1]<<","<<this->k[2]<<"], vType:=["<<this->vType[0]<<","<<this->vType[1]<<","<<this->vType[2]<<"], improper:= " << this->improper << ", blockNumbers:=[" << this->blockNumbers << "]);\n\n";
		}
		
		void writeToFile()
		{
			ofstream writer;
			writer.open(this->path, ios::app); 
			writer << "rec(isBlockDesign:=true, v:="<< this->v <<", blocks:="<< this->stringifyBlocks(this->blocks);
			writer << ", negatives:=" << this->stringifyBlocks(this->negatives);
			writer << ", k:=["<< this->k[0]<<","<<this->k[1]<<","<<this->k[2]<<"], vType:=["<<this->vType[0]<<","<<this->vType[1]<<","<<this->vType[2]<<"], improper:= " << this->improper << ", blockNumbers:=[" << this->blockNumbers << "])";
			writer.close();
		}
		
		string stringifyBlocks( blockSet bs )
		{
			string str = "[";
			for(unsigned int i=0; i < bs.size(); i++)
			{
				
				stringstream out;
				out << "[" << bs[i][0]+1 << ", " << bs[i][1]+1 << ", "<< bs[i][2]+1 << "]";
				str += out.str();

				if( i < bs.size() - 1)
					str += ", ";
			}
			str += "]";
			return str;
		}
		
		bool IsTransversal( blockSet bs )
		{
			if (bs.size() != (unsigned)this->vType[0])
				return false;
			
			block points;
			for(unsigned int i = 0; i < bs.size(); i++)
			{
				points.push_back(bs[i][0]);
				points.push_back(bs[i][1]);
				points.push_back(bs[i][2]);
			}
			
			sort(points.begin(), points.end());
			for (int i = 0; i < vType[0]+vType[1]+vType[2]; i++)
			{
				if (i!=points[i])
					return false;
			}

			return true;
		}
		
		blockSet crossTwoBlocks( block b1, block b2 )
		{
			blockSet newBlocks;
			block a,b;
			a.push_back(b1[0]);
			a.push_back(b2[1]);
			
			b.push_back(b2[0]);
			b.push_back(b1[1]);
			
			// Now need to find what points are located in these new positions.
			for(unsigned int i = 0; i < this->blocks.size(); i++)
			{
				if(this->blocks[i][0] == a[0] && this->blocks[i][1] == a[1])
				{
					a.push_back(this->blocks[i][2]);
					break;
				}
			}
			for(unsigned int i = 0; i < this->blocks.size(); i++)
			{
				if(this->blocks[i][0] == b[0] && this->blocks[i][1] == b[1])
				{
					b.push_back(this->blocks[i][2]);
					break;
				}
			}
			newBlocks.push_back(a);
			newBlocks.push_back(b);
			return newBlocks;
		}
		
		void prettify()
		{
			for(unsigned int i = 0; i < this->blocks.size(); i++)
			{
				if (i % this->vType[0] == 0)
					cout << endl;
				cout << this->blocks[i][2]+1 << " "; 
			}
			cout << endl << endl;
		}
		
		blockSet findTransversal()
		{
			//first, get any diagonal
			blockSet diagonal;
			for(int i = 0; i < this->vType[0]; i ++)
			{
				diagonal.push_back(this->blocks[i*vType[0]+i]);
			}
			diagonal = diagonalMove(diagonal, 100);
			
			//Now find a transversal
			while(!IsTransversal(diagonal))
			{
				diagonal = diagonalMove(diagonal, 1);
			}
			return diagonal;
		}
		
		void sampleDiagonalSpace()
		{
			blockSet diagonal;
			for(int i = 0; i < this->vType[0]; i ++)
			{
				diagonal.push_back(this->blocks[i*vType[0]+i]);
			}
			int total=0, trans=0;
			while(total < 400000)
			{
				total++;
				diagonal = diagonalMove(diagonal, 10);
				if(IsTransversal(diagonal))
					trans++;
				//if(total % 1000 == 0)
				cout << trans<<" / "<<total <<" diagonals have been transversals (average = " << (double) factorial(vType[0])*(float)trans/total << ")\n";	
			}
			//cout << trans<<" / "<<total <<" diagonals have been transversals (average = " << (double) factorial(vType[0])*(float)trans/total << ")\n";
			
		}
		
		blockSet diagonalMove( blockSet diagonal, int mixingTime )
		{
			int j = 0;
			while(j<mixingTime)
			{
				j++;
				// select two blocks in the diagonal at random, and cross them
				// note these blocks are allowed to be the same to ensure the
				// underling graph is non-bipartite
				
				int b1 = (rand() % vType[0]);
				int b2 = (rand() % vType[0]);
				blockSet r = this->crossTwoBlocks(diagonal[b1], diagonal[b2]);
				diagonal[b1] = r[0];
				diagonal[b2] = r[1];
			}
			return diagonal;
		}
		
		int factorial( int n )
		{
			if (n == 1)
				return 1;
			else
				return n*factorial(n-1);
		}
		
		void findAllTransversals()
		{
			vector<blockSet> foundTrans;
			int i=0;
			while(i < 500000)
			{
				i++;
				blockSet newTrans = findTransversal();
				vector<blockSet>::iterator myIt = find (foundTrans.begin(), foundTrans.end(), newTrans);
				if(myIt==foundTrans.end())
				{
					foundTrans.push_back(newTrans);
					cout << "(" << foundTrans.size() << "/" << i <<") \t" << this->stringifyBlocks(newTrans) << endl;
				}
			}	
			cout << "\n\nTOTAL (after "<< i<<" searches)  = " << foundTrans.size() ;
		}

		~Square(){}
};

int main(int argc, char *argv[])
{
	srand ( time(NULL) );
	Square* mySquare = new Square(15);
	//mySquare->manyStepsProper(0);
	//mySquare->prettify();
	//mySquare->display();
	//mySquare->sampleDiagonalSpace();
	//cout << "Transversal: " << mySquare->stringifyBlocks(mySquare->findTransversal());
	//mySquare->findAllTransversals();
	
	
	// Sample
	if(argc<6)
	{
		cout << "You must specify:\n\n<string>filename <int>order <int>sample_size <int>mixing_time <bool>OnlyThoseWithTransversalOnMainDiagonal [<int>iterations]\n\n in that order, e.g.\n./DesignMC results.txt 10 1 200\n" << endl;
		exit(0);
	}
	const char* file = argv[1];
	int order = atoi(argv[2]);
	int search_size = atoi(argv[3]);
	int mixing = atoi(argv[4]);
	int trans = atoi(argv[5]);

	int iterations;
	if(argc==7)
	{
		iterations = atoi(argv[6]);
	} 
	else
	{
		iterations = 1;
	}
	vector<int> results;

	for(int k = 0; k < iterations; k++ )
	{
		int savedSquares = 0;

		srand ( time(NULL) );
		Square* mySquare = new Square(order);
		mySquare->setPath(file);

		ofstream writer;
		writer.open(file); 
		writer << "return [";
		writer.close();

		for(int i=0; i<search_size; i++)
		{
			mySquare->manyStepsProper(mixing);
			if(trans==1 && mySquare->isMainDiagonalTransversal() || trans==0)
			{
				if( savedSquares > 0 )
				{
					writer.open(file, ios::app); 
					writer << ",\n ";
					writer.close();
				}
				mySquare->writeToFile();
				savedSquares++;
			}
			if(i>0)
			{
				for(int j = 0; j < floor(log10(max(1,i)))+1; j++)
				{
					cout << "\b";
				}
			}
			else
			{	
				cout << "Current sample size: ";
			}
			cout << (i+1);
			cout.flush();
		}
		writer.open(file, ios::app); 
		writer << "];";
		writer.close();

		cout << "\n" << k+1 << "/" << iterations << ": Sampling complete\n";
		results.push_back(savedSquares);
	}
	if(iterations > 1)
	{
		ofstream writer;
		writer.open(file); 

		for (int k = 0; k < results.size(); k++)
		{
			writer << results[k];
			if (k < results.size() - 1)
			{
				writer << "\n";
			}
		}

		writer.close();
	}
	
	return 0;
}
