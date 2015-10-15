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

public class Irv {

    /***************** SIMPLE FILE UTILITIES *************/

    // opens a file an creates a Scanner on it
    public static Scanner fileScanner(String fName) 
        throws FileNotFoundException {
            return new Scanner(new FileInputStream(fName));
        }
    public static PrintStream printStream(String fName) 
        throws FileNotFoundException {
            return new PrintStream(new FileOutputStream(fName));
        }

    /**************** END FILE UTILITIES *****************/

    // main driver program for IrvElection class -- creates IrvElection 
    //   object from file and invokes tabulate method on it if successful.
    public static void main(String[] args) {
        // this version just writes to standard out...
        /* 
           if(args.length != 2){
           System.out.prinln("Must specify input and output file on cmd-line");
           System.out.prinln("Goodbye...");
           System.exit(0);
           }
         */

        Scanner input=null;
        PrintStream out = System.out;

        try {
            input = fileScanner(args[0]);
            out = printStream(args[1]);
        } catch(FileNotFoundException e) {
            System.out.println("Error with input or output file");
            System.exit(0);
        }

        IrvElection election = IrvElection.readElection(input);
        input.close();
        out.println("Input file: " + args[0]);
        if(election == null)
            out.println("  Input file does not encode valid election: ");
        else
            election.tabulate(out);
        out.close();
    }
}
