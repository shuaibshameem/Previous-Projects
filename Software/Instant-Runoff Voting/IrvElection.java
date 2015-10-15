/*
 *	Name:	Shuaib Shameem
 *	UIN:	673551999
 *	NetID:	sshame3
 *
 *	Project Description:
 *			Take information from a ballot file and generate output which lists
 *			candidate names, number of ballots (good/bad), and then proceeds to
 *			determine the winner of the election. Can account for tied situations.
 *
*/

import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.FileInputStream;
import java.io.PrintStream;
import java.io.FileNotFoundException;
import java.util.Scanner;

import java.util.ArrayList;

public class IrvElection {

    /**
      * Private static nested class for representing ballots.
      * Note data members are public.  Is this ok?
    */
    private static class Ballot {

        public int [] candId2rank;
        public int topChoice;   // top choice among eligible

        public Ballot(int numCandidates) {
            candId2rank = new int[numCandidates];
            topChoice = -1;
        }

    }

    /**
      * Private static nested class for representing a candidate.
      * Note data members are public.  Is this ok?
    */
    private static class Candidate {

        public String name;
        public boolean eligible;  
        private int votes;   // from most recent round

        Candidate(String name) {
            this.name = name;
            votes = 0;
            eligible = true;
        }
    }

    // Data members for IrvElection class

    private ArrayList<Candidate> candidates;
    private ArrayList<Ballot> ballots;
    private int numCandidates;
    private int numBallots;
    private int badBallots;
    private int numEligible;

    /**
    *  trivial constuctor.  
    *  Client gets IrvElection objects through readElection factory
    *    method
    */
    private IrvElection() {
        candidates = new ArrayList<Candidate>();
        ballots = new ArrayList<Ballot>();
        numCandidates = 0;
        numBallots = 0;
        badBallots = 0;
        numEligible = 0;
    }

    /*************** SETUP ROUTINES *******************/


    private static void eatTokens(Scanner inp) {
        while(inp.hasNext() && !inp.hasNext("<b>")) {
            inp.next();
        }
    }

    // precondition:  assumes Scanner inp is placed at the
    //   beginning of a ballot (i.e., immediately after a <b>
    //   delimiter).
    // returns non-null ballot if and only if legal ballot
    //    successfully read.
    // returns null for bad ballot
    //
    // Postcondition:  leaves Scanner on delimiter for next ballot 
    //   (<b>) or at end of file if there is no remaining delimiter.
    private Ballot readBallot(Scanner inp ) {

        Ballot b = new Ballot(numCandidates);
        int candId = 0;

        // loop so long as you need another int and there is
        //   one to be read.
        while(inp.hasNextInt() && candId < numCandidates) {
            int rank = inp.nextInt();
            if(rank < 1 || rank > numCandidates){
                // invalid rank
                eatTokens(inp);
                // System.out.println("DEBUG:  bad ballot");
                return null;
            }
            else {
                // check if rank already used
                for(int c = 0; c<candId; c++)
                    if(b.candId2rank[c] == rank){
                        eatTokens(inp);
                        // System.out.println("DEBUG:  bad ballot");
                        return null;
                    }
                 b.candId2rank[candId] = rank;
            }
            candId++;
        }
        // extra junk in ballot.  eat tokens til <b> or end
        //   of file, whichever comes first.
        //   ballot is bad.
	if(inp.hasNext() && !inp.hasNext("<b>")) {
		eatTokens(inp);
		return null;
	}
        if(candId == numCandidates) { // all candidates ranked
            // System.out.println("DEBUG:  good ballot");
            return b;
        }
        else {
            // System.out.println("DEBUG:  bad ballot");
            return null;
        }
    }


    /**
    * Precondition:  input Scanner at beginning of data for election.
    * returns true if election successfully read
    * false otherwise
    */
    private boolean initFromScanner(Scanner input) {
        String line="";

        // read candidates 
        while(input.hasNextLine() && !input.hasNext("<begin-ballots>")) {

	    String name = input.nextLine().trim();
	    if(name.length() > 0) {
		    candidates.add( new Candidate(name));
		    numCandidates++;
	    }
        }
        numEligible = numCandidates;

	// we got to the end of the file without ever seeing 
	//   <begin-ballots>; bad input file!
	if(!input.hasNextLine())
		return false;

	line = input.nextLine().trim();

	// kind of picky here:  if anything
	//   besides <begin-ballots> and whitespace
	//   then file is bad.
	if(!line.equals("<begin-ballots>"))
		return false;

	
        // ok, we'll allow zero ballots
        if(!input.hasNext())
            return true;

	// now we expect <b>
	else if(!input.hasNext("<b>"))
		return false;
	
	input.next(); // eat <b>
        do {
            Ballot b = readBallot(input);
            if(b != null) {
                System.out.println("DEBUG:  good ballot");
                ballots.add(b);
                numBallots++;
            }
            else {
                System.out.println("DEBUG:  bad ballot");
                badBallots++;
            }
        }
        while(input.hasNext() && input.next().equals("<b>"));

        // should never happen
        if(input.hasNext()){
            System.out.println("DEBUG:  error:  exited read-ballots loop");
            System.out.println("    before end of file?");
        }
        return true;
    }

    /* 
     * only way client can create IrvElection object is through this
     *    factory method.
     *
    */
    public static IrvElection readElection(Scanner inp){
        IrvElection election = new IrvElection();
        if(election.initFromScanner(inp))
            return election;
        return null;
    }


    /**************** ELECTION TALLYING ROUTINES **********/

    /*
     * Traverse across a ballot's votes, skipping those of ineligible
     * candidates, and setting the highest (numerically lowest) ranked
     * candidate as the top vote of the ballot
     * 
    */
    private Ballot setTopVote(Ballot b){
    	
    	int TopRank 	= 100;												//keep track of the highest rank
    	int TopRankId 	= -1;												//hold place of highest rank
    	
    	for(int i = 0; i < b.candId2rank.length; i++){
    		
    		if(b.candId2rank[i] < TopRank && candidates.get(i).eligible){	//if the rank is higher and the candidate is eligible
    																		//then set the placeholders
    			TopRank = b.candId2rank[i];
    			TopRankId = i;
    		
    		}
    	
    	}
    	
    	b.topChoice = TopRankId;											//set the ballot's top choice variable
    	
    	if(TopRankId < 0)													//shouldn't happen
    		return null;
    	else																//return ballot
    		return b;
    }
    
    /*
     * count number of ballots per candidate
     * 
     * 
    */
    private void tally(){
    	
    	Ballot ballot = null;												//placeholders
    	Candidate candidate = null;
    	
    	resetVotes();														//reset vote counters
    	
    	for(int i = 0; i < ballots.size(); i++){
    		
    		ballot = ballots.get(i);
    		ballot = setTopVote(ballot);									//set current ballot
    		
    		if(ballot != null){												//should always return true
	    	
    			ballots.set(i, ballot);										//update ballots arraylist
	    		candidate = candidates.get(ballot.topChoice);				//update current ballot's top candidate
	    		candidate.votes++;
	    		candidates.set(ballot.topChoice, candidate);
    		
    		}
    	}
    }
    
    /*
     * reset the vote count for every candidate
     * useful for recounting votes after a candidate has been eliminated
     * 
    */
    private void resetVotes(){
    	
    	Candidate candidate = null;											//candidate placeholder
    	
    	for(int i = 0; i < candidates.size(); i++){
    	
    		candidate = candidates.get(i);									//get, update, set candidate in ArrayList
    		candidate.votes = 0;
    		candidates.set(i, candidate);
    	
    	}
    }
    
    /*
     * remove the candidates with the lowest amount of votes
     * 
     * 
    */
    private int[] removeLoser(){
    	
    	int lowest = 100;													//keep track of lowest number of votes
    	int lowestId = 0;													//hold location of lowest number
    	int secondLowestId = 0;												//hold location of double elimination
    	int[] oneOut = new int[1];											//return location of eliminated candidate
    	int[] twoOut = new int[2];											//return locations of eliminated candidates
    	boolean doubleRemove = false;										//keep track of single or double elimination
    	Candidate candidate = null;											//candidate placeholder
    	
    	for(int i = 0; i < candidates.size(); i++){
    		
    		candidate = candidates.get(i);
    		
    		if(candidate.votes < lowest && candidate.eligible){				//if lower than lowest and candidate is eligible
    																		//then hold location and number
    			lowest = candidate.votes;
    			lowestId = i;
    		
    		}
    	}
    	
    	for(int i = 0; i < candidates.size(); i++){							//check for candidates with equal amount of votes
    	
    		candidate = candidates.get(i);
    		
    		if(candidate.votes == lowest && i != lowestId){					//if equal and not the same location
    																		//then save the location
    			secondLowestId = i;
    			doubleRemove = true;
    		
    		}
    	}
    	
    	candidate = candidates.get(lowestId);								//get, update, set candidate
    	candidate.eligible = false;
    	candidates.set(lowestId, candidate);
    	numEligible--;														//update number of eligible candidates
    	oneOut[0] = lowestId;												//update return variable
    	
    	if(doubleRemove){													//if double elimination
    	
    		candidate = candidates.get(secondLowestId);						//repeat above steps
    		candidate.eligible = false;
    		candidates.set(secondLowestId, candidate);
    		twoOut[0] = lowestId;											//update return variable
    		twoOut[1] = secondLowestId;
    		numEligible--;
    		return twoOut;													//return (double elimination)
    	
    	}
    	
    	return oneOut;														//return (single elimination)
    	
    }
    

    /**************** END ELECTION TALLYING ROUTINES *****/


    /** 
    * Just simulates IRV on initialized IrvElection object and
    * prints results to out
    *
    * for partA, tabulate just prints basic stats -- doesn't
    *    actually tabulate retults
    */
    public Candidate tabulate(PrintStream out) {

        out.println("  " + numCandidates + " candidates");
        out.println("  " + numBallots + " legal ballots");
        out.println("  " + badBallots + " discarded ballots");
        
        Candidate winner = null;
        
        out.println();
        
        int index = 0;														//keep track of iterations of while loop
        																	//in any election, max number of iterations
        																	//will be n candidates - 1
        																	//also keep track of which round we are in
        ArrayList<Double> percents;											//keep track of vote percentages per eligible candidate
        int[] holdOuts = null;												//accepts removeLoser return variable for output
        boolean isTie = true;												//keeps track of tie situations
        int[] short2Full = null;											//converts an arraylist indexing pertaining only to eligible
        																	//candidates into an index for arraylists of all candidates
        double tiePercent;													//keep track of what percentage each candidate must have
        																	//in order to declare a tie
        
        while(winner == null){												//repeat until a winner is declared
        	
        	isTie = true;													//reset to true; will change to false when there is no tie
        	percents = new ArrayList<Double>();
        	index++;
        	int index2 = 0;
        	short2Full = new int[numEligible];
        	
        	out.println();
        	out.println("Round " + index + " Results:");
        	
        	tally();														//tally up votes for eligible candidates
        	
        	for(int i = 0; i < candidates.size(); i++){
        	
        		if(candidates.get(i).eligible){

        			percents.add( (double)candidates.get(i).votes/(double)numBallots);
        																	//get current candidate's vote percentage
        			out.println("    " + candidates.get(i).name + ":\t" + candidates.get(i).votes + "  (" + Math.round(percents.get(index2)*100) + "%)");
        																	//output candidate information
        			short2Full[index2] = i;
        																	//keep track of candidate placement in two styles of indexing
        			index2++;												//keep track of percents' indexing (which is different from the for loop)
        		
        		}
        	}
        	
        	for(int i = 0; i < numEligible; i++){							//search for winner from the eligible candidates
        	
        		if(percents.get(i) > 0.5){									//if majority
        			winner = candidates.get(short2Full[i]);					//then declare and break loop
        			break;
        		}else if(i == 0 && percents.size() == numEligible){			//otherwise, check for tie
        			
        			tiePercent = ((double)1/numEligible);					//percentage required of all candidates to declare a tie
    				
        			for(int j = 0; j < numEligible; j++){					//check to see if any percentages fail this test
        				if(!percents.get(j).equals(tiePercent)){
        					isTie = false;									//if so, then there is no tie
        				}
        			}
        			
        			if(isTie){												//if there is a tie
        				winner = new Candidate(String.valueOf(numEligible));//pass number of candidates remaining to code below and break
        				break;
        			}else if(percents.get(i) == 0.5){						//otherwise, make any candidate with 50% of the votes the winner and break
        				winner = candidates.get(short2Full[i]);
        				break;
        			}
        		
        		}
        	}
        	
        	if(winner == null){												//if no winner was found
        		
        		out.println();												//generate output
        		out.println("   No Winner.");
        		holdOuts = removeLoser();									//remove candidates with lowest number of votes
        		out.println("     Eliminated: ");
        		
        		for(int i = 0; i < holdOuts.length; i++){					//list eliminated candidates
        			out.println("       " + candidates.get(holdOuts[i]).name);
        		}
        	}
        	
        	if(index == numCandidates - 1){									//break loop if max iterations reached and no winner found
        		break;
        	}
        }
        
        out.println();
        
        
        
        boolean canParse = false;											//in case of tie, check for number in candidate name
        int tie = 0;
        
        try{
        	tie = Integer.parseInt(winner.name);
        	canParse = true;
        }catch(NumberFormatException e){
        	canParse = false;
        }

        if(canParse){														//if candidate name was a number, then there was a tie
        	out.println("There is a " + tie + "-way tie between:");			//generate output pertaining to a tie
        	for(int i = 0; i < numEligible; i++){
        		out.println("   " + candidates.get(i).name);
        	}
        	return null;													//return to calling procedure before following code is executed
        }
        
        if(winner != null)													//generate output declaring the winner
        	out.println(winner.name + " declared winner");
        else																//this should never happen
        	out.println("No winner. Possible error in input file");
        
        
        return null;
    }





}
