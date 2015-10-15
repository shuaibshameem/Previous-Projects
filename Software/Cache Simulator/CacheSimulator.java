import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;


public class CacheSimulator {

	static int cacheSize = 32, setWidth = 1, lineSize = 1, totalBlocks = 1, totalSets = 1, missPenalty = 0, cycleTime = 1;
	//         in kB   		   no units	     in Bytes      no units		    no units	   in cycles	    in nanoseconds 
	static int loads = 0, stores = 0, loadMiss = 0, storeMiss = 0, instCount = 0, cycleCount = 0, stallCycles = 0;
	//         no units for these variables
	static char writePolicy = ' ';
	static String[] haveStoreStalls;
	static int numStalls;

	static int addresses[][][];
	static int offsetBitWidth = 0;					// never used, added for completeness
	static int indexBitWidth = 0;
	static int tagBitWidth = 0;
	static int setSize = 0;
	static int callsSinceLastUse[][];


	public static void main(String[] args){

		Scanner input = null;
		String fileName = "Short_list.txt";


		try {
			input = new Scanner(new File(fileName));
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			System.exit(0);
		}

		String argType;
		String argVal;

		for(int i = 0; i < args.length-1; i += 2){		// initialize cache information from command arguments
			argType = args[i];							// Store the argument type (a, l, mp, s, wl/wr)
			argVal = args[i+1];							// Store the argument value
			writePolicy = 'l';							// Write Policy fixed to write-allocate (write-around not implemented)
			cycleTime = 1;								// Clock fixed to 1GHz <-> 1ns
			if(argType.equalsIgnoreCase("-a"))
				setWidth = Integer.parseInt(argVal);
			if(argType.equalsIgnoreCase("-s"))
				cacheSize = Integer.parseInt(argVal);
			if(argType.equalsIgnoreCase("-l"))
				lineSize = Integer.parseInt(argVal);
			if(argType.equalsIgnoreCase("-mp"))
				missPenalty = Integer.parseInt(argVal);
			System.out.println(argType + " : " + argVal);
		}

		initCache();											// "create" the cache hardware
		totalBlocks = totalSets * setWidth;						// calculate total number of blocks in cache

		// initialize variables
		haveStoreStalls = new String[totalBlocks];				// keeps track of addresses containing stalls
																// size is that of the total number of blocks
																// this will always be enough
		numStalls = 0;											// keeps track of the number of blocks with stalls
																// used in loops to keep from checking unused array slots
		int cyclesThisLoop;										// will count how cycles have passed for each instruction
		int instSinceLast;										// hold the number of inst since last mem access
		
		System.out.println("Simulating '" + fileName + "' ...");
		while(input.hasNextLine()){

			
			String[] tmp = input.nextLine().split(" ");
			// tmp[1] is the address
			// tmp[2] is instruction count

			if(tmp.length < 3)									// should never occur with a proper input
				break;											// unless there are blank lines at the end
			
			System.out.println(tmp[0] + " " + tmp[1] + " " + tmp[2]);
			
			instSinceLast = Integer.parseInt(tmp[2]);
			instCount += 1 + instSinceLast;						// update instruction count
			cycleCount += 1 + instSinceLast;					// update cycle count
			cyclesThisLoop = 1 + instSinceLast;					// keep track of how many cycles to decrement from stalls


			if(tmp[0].equalsIgnoreCase("s")){					// if store
				stores++;										// inc number of stores
				decStoreStall(cyclesThisLoop);					// update stall time of all blocks with stalls
							// this is here because a store always takes only one cycle
							// placing this later would cause a premature stall decrement if this store misses

				if(isPresent(tmp[1])){							// if address is present in cache
					System.out.println("Store Hit");			// do nothing
				}else{											// if address is not present in cache
					System.out.println("Store Miss");
					storeMiss++;								// inc number of store misses
					haveStoreStalls[numStalls] = tmp[1];		// add address to list of stall carrying addresses
					numStalls++;								// keep track of how many address are in haveStoreStalls[]
					storeTag(tmp[1]);							// store the tag
				}
			}
			else if(tmp[0].equalsIgnoreCase("l")){				// if load
				loads++;										// inc number of loads

				if(isPresent(tmp[1])){							// if address is present in cache
					System.out.print("Load Hit");
					int stall =getStall(tmp[1]) - instSinceLast;// check address for stall and adjust for instructions before
					if(stall > 0){								// if there is a stall
						System.out.print(" With Store Stall");
						cycleCount += stall;					// update cycleCount to account for stall
						cyclesThisLoop += stall;				// keep track of how many cycles to dec stalls
					}
					System.out.println();
				}else{											// if address is not present in cache
					System.out.println("Load Miss");
					loadMiss++;									// inc number of load misses
					loadTag(tmp[1]);							// update cache to contain this address' block
					cycleCount += missPenalty;					// update cycleCount to account for the miss penalty
					cyclesThisLoop += missPenalty;				// keep track of how many cycles to dec stalls
				}

				decStoreStall(cyclesThisLoop);					// update stall time of all blocks with stalls
							// this is placed after all the load logic because neither a hit or miss
							// adds any stalls, but both could increase the cycles used in this instruction
			}
		}

		System.out.println(" done:");

		// prepare results
		String pol = "Write-Allocate";													// generate string for write policy
		int totalMem = loads + stores;													// calc total loads and stores
		double loadMissRate = (double)loadMiss/loads;									// calc load miss rate
		double storeMissRate = (double)storeMiss/stores;								// calc store miss rate
		double totalMissRate = (double)(loadMiss + storeMiss)/totalMem;					// calc total miss rate
		int stallCount = cycleCount - instCount;										// calc stall cycles
		double avgMemTime = (double)((stallCount) * cycleTime) / totalMem;				// calc avg mem access time
		double CPI = (double)cycleCount/instCount;										// calc Cycles Per Instruction
		double execTime = CPI * instCount * cycleTime;									// calc Execution Time

		System.out.println();
		System.out.printf ("\nCache Architecture: \n");
		System.out.printf ("-----------------------------------------------------\n");
		System.out.printf ("Cache size (KB)\t\t\t .... %1d\n", cacheSize);
		System.out.printf ("Associativity\t\t\t .... %1d\n", setWidth);
		System.out.printf ("Line size (Bytes)\t\t .... %1d\n", lineSize);
		System.out.printf ("Number of sets\t\t\t .... %1d\n", totalSets);
		System.out.printf ("Number of blocks\t\t .... %1d\n", totalBlocks);
		System.out.printf ("Write policy\t\t\t .... %1s\n", pol);
		System.out.printf ("Miss penalty (cycles)\t\t .... %1d\n", missPenalty);
		System.out.printf ("Cycle time (ns)\t\t\t .... %1d\n", cycleTime);
		System.out.printf ("\n\n");
		System.out.printf ("Simulation Results for '%s': \n",fileName);
		System.out.printf ("-----------------------------------------------------\n");
		System.out.printf ("Total Loads & Stores\t\t ...  %1d\n", totalMem);
		System.out.printf ("Loads\t\t\t\t ...  %1d\n", loads);
		System.out.printf ("Stores\t\t\t\t ...  %1d\n", stores);
		System.out.printf ("Load Misses\t\t\t ...  %1d\n", loadMiss);
		System.out.printf ("Store Misses\t\t\t ...  %1d\n", storeMiss);
		System.out.printf ("Total Miss Rate\t\t\t ...  %1f\n", totalMissRate);
		System.out.printf ("Load Miss Rate\t\t\t ...  %1f\n", loadMissRate);
		System.out.printf ("Store Miss Rate\t\t\t ...  %1f\n", storeMissRate);
		System.out.printf ("\n");
		System.out.printf ("Instruction Count\t\t ...  %1d\n", instCount);
		System.out.printf ("Cycle Count\t\t\t ...  %1d\n", cycleCount);
		System.out.printf ("Stall Cycles\t\t\t ...  %1d\n", stallCount);
		System.out.printf ("Average Memory Access Time\t ...  %1f\n", avgMemTime);
		System.out.printf ("CPI\t\t\t\t ...  %1f\n", CPI);
		System.out.printf ("Execution Time\t\t\t ...  %1f\n", execTime);

	}


	// "create" the cache hardware
	// calculate number of sets, bits needed to address cache
	// initialize tag/stalls 3D array (addresses[set][block in set][0 - tag/1 - stall remaining])
	// initialize calls 2D array (callsSinceLastUse[set][block in set])
	static void initCache(){
		setSize = setWidth * lineSize; 								// full size of set in bytes
		totalSets = cacheSize * 1024;								// change cache size to bytes
		totalSets = totalSets / setSize;							// number of sets
		addresses = new int[totalSets][setWidth][3];				// holds tag for the block
		// This array will be as long as the number of sets present 	[x][][]
		//					  as wide as the number of blocks per set 	[][y][]
		//					  3 deep 									[][][z]
		//							[0] being the address
		//							[1] being the cycles left on a store miss
		//							[2] being the determinate of whether it has been used
		//								if 0, cause miss, if 1, allow hit (determine hit/miss when tag=index=0)
		callsSinceLastUse = new int[totalSets][setWidth];			// holds number of method calls since last use
		offsetBitWidth = (int)(Math.log(lineSize)/Math.log(2));		// # of bits needed to represent offset
		indexBitWidth = (int)(Math.log(totalSets)/Math.log(2));		// # of bits needed to represent index
		tagBitWidth = 32-indexBitWidth-offsetBitWidth;				// # of bits needed to represent tag

		System.out.println("Set Size: " + setSize + " total sets: " + totalSets);
		System.out.println("tag: " + tagBitWidth + " index: " + indexBitWidth + " offset: " + offsetBitWidth);
	}

	// takes a hex string input and checks cache for a hit
	// returns true if the address is in cache
	// returns false if the address is not in cache
	static boolean isPresent(String adr){
		String adrB = hex2bin(adr);									// convert hex to bin
		int tag = getTag(adrB);										// pull tag from address
		int index = getIndex(adrB);									// pull index from address

		boolean temp = false;										// keep track of whether there is a hit
		for(int i = 0; i < setWidth; i++){							// loop the blocks of set [index]
			callsSinceLastUse[index][i]++;							// increase the # of instructions since last use
			if(addresses[index][i][0] == tag && temp != true
					&& addresses[index][i][2] > 0){					// if address is found and there hasn't been a hit
				temp = true;										// save that there has been a hit
				callsSinceLastUse[index][i] = 0;					// update the calls # of the hit to 0 (used this instruction)
			}
		}
		return temp;												// return whether or not there was a hit
	}

	// takes an integer for the number of cycles passed since the since the last instruction
	// updates the remaining stall time of every address in haveStoreStalls[]
	// if stall time is 0 or less, address is removed from the array and numStalls is decremented
	static void decStoreStall(int cycles){
		if(numStalls == 0)											// if there are no stalls, do nothing
			return;
		for(int i = 0; i < numStalls; i++){							// loop to check all the addresses with stalls
			String adr = hex2bin(haveStoreStalls[i]);				// convert the address to binary
			int tag = getTag(adr);									// pull tag from the address
			int index = getIndex(adr);								// pull index from the address
			for(int j = 0; j < setWidth; j++){						// loop to check every block of set [index]
				if(addresses[index][j][0] == tag){					// if address is in this block
					addresses[index][j][1] -= cycles;				// decrement the stalls by the input
					if(addresses[index][j][1] < 0){					// if stalls falls below 1
						addresses[index][j][1] = 0;					// set it to 0
						haveStoreStalls[i] = haveStoreStalls[numStalls-1];
															// here I replace the address that no longer has a stall
															// with one that has a stall and has not been updated yet
						numStalls--;								// update the number of stall addresses
						i--;							
						// stay at this number in the loop
								// due to the rearrangement of haveStoreStalls
					}
					break;											// since the address was found, stop checking blocks
				}
			}
		}
	}


	// takes the address of a store that was not in cache
	// adds the tag to the least recently used block
	// updates the calls array
	// sets this block's stall to missPenalty
	static void storeTag(String adr){
		String adrB = hex2bin(adr);									// convert address to binary
		int tag = getTag(adrB);										// pull tag from address
		int index = getIndex(adrB);									// pull index from address
		int locLeast = 0;							// initialize variable for the location of the LRU block
		int numLeast = callsSinceLastUse[index][0]; // initialize variable for the number of set calls since last use
		for(int i = 1; i < setWidth; i++){							// loop through all the blocks of set [index]
			if(callsSinceLastUse[index][i] > numLeast){				// if this block has more calls than the earlier blocks
				numLeast = callsSinceLastUse[index][i];				// update the number of calls
				locLeast = i;										// save the location
			}
		}
		addresses[index][locLeast][0] = tag;						// change tag of the LRU block
		addresses[index][locLeast][1] = missPenalty;				// add stall for Store Miss
		addresses[index][locLeast][2] = 1;							// update hasBeenUsed
		callsSinceLastUse[index][locLeast] = 0;						// update calls since to 0 for this block
	}

	// takes the address of a load that was not in cache
	// adds the tag to the least recently used block
	// updates the calls array
	// sets this block's stall to 0
	static void loadTag(String adr){
		String adrB = hex2bin(adr);									// convert address to binary
		int tag = getTag(adrB);										// pull tag from address
		int index = getIndex(adrB);									// pull index from address
		int locLeast = 0;							// initialize variable for the location of the LRU block
		int numLeast = callsSinceLastUse[index][0];	// initialize variable for the number of set calls since last use
		for(int i = 1; i < setWidth; i++){							// loop through all the blocks of set [index]
			if(callsSinceLastUse[index][i] > numLeast){				// if this block has more calls than the earlier blocks
				numLeast = callsSinceLastUse[index][i];				// update the number of calls
				locLeast = i;										// save the location
			}
		}
		addresses[index][locLeast][0] = tag;						// change tag of the LRU block
		addresses[index][locLeast][1] = 0;							// change stall to 0
		addresses[index][locLeast][2] = 1;							// update hasBeenUsed
		callsSinceLastUse[index][locLeast] = 0;						// update calls since to 0 for this block
	}

	// takes the address of a load hit and returns the remaining stall time
	static int getStall(String adr){
		String adrB = hex2bin(adr);									// convert address to binary
		int tag = getTag(adrB);										// pull tag from address
		int index = getIndex(adrB);									// pull index from address
		for(int i = 0; i < setWidth; i++){							// loop through all the blocks of set [index]
			if(addresses[index][i][0] == tag){						// if address is in this block
				return addresses[index][i][1];						// return the remain stall
			}
		}
		return -1;													// unreachable, we know that the address is present
	}

	// takes the binary string of an address and returns the tag
	static int getTag(String adr){
		return bin2dec(adr.substring(0,tagBitWidth));
	}

	// takes the binary string of an address and returns the index
	static int getIndex(String adr){
		return bin2dec(adr.substring(tagBitWidth,tagBitWidth + indexBitWidth));
	}

	// takes the binary string of an address and returns the offset
	// this is never used, but added completeness
	static int getOffset(String adr){
		return bin2dec(adr.substring(tagBitWidth+indexBitWidth));
	}

	// This method takes a string, containing only bin characters, and converts it to a decimal integer
	static int bin2dec(String bin){
		char[] temp = new char[bin.length()];
		bin.getChars(0, bin.length(), temp, 0);		// get each individual character from the string
		int sum = 0;
		int hold = 0;
		for(int i = 0; i < temp.length; i++){
			hold = (int)(Character.getNumericValue(temp[temp.length - i - 1]) * Math.pow(2, i));
			sum += hold;
		}
		return sum;
	}


	// This method takes a string, containing only hex characters, and converts it to a string containing the equivalent binary code
	static String hex2bin(String hex){
		char[] temp = new char[hex.length()];
		hex.getChars(0, hex.length(), temp, 0);		//get each individual character from the string
		if(temp[1] == 'x'){
			temp = new char[hex.length()-2];
			hex.getChars(2, hex.length(), temp, 0);
		}
		String word = "";
		for(int i = 0; i < temp.length; i++){
			word += getBin(temp[i]);				//convert each character into the equivalent binary code
		}
		return word;
	}


	// This method takes a character input (0-9,a-f,A-F) and returns the matching binary code
	static String getBin(char c){
		if(c == '0')
			return "0000";
		else if(c == '1')
			return "0001";
		else if(c == '2')
			return "0010";
		else if(c == '3')
			return "0011";
		else if(c == '4')
			return "0100";
		else if(c == '5')
			return "0101";
		else if(c == '6')
			return "0110";
		else if(c == '7')
			return "0111";
		else if(c == '8')
			return "1000";
		else if(c == '9')
			return "1001";
		else if(c == 'a' || c == 'A')
			return "1010";
		else if(c == 'b' || c == 'B')
			return "1011";
		else if(c == 'c' || c == 'C')
			return "1100";
		else if(c == 'd' || c == 'D')
			return "1101";
		else if(c == 'e' || c == 'E')
			return "1110";
		else if(c == 'f' || c == 'F')
			return "1111";
		else
			return "FAIL";
	}




}
