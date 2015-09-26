import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Scanner;


public class Assembler {

	public static Scanner fileScanner(String fName) throws FileNotFoundException {
		return new Scanner(new FileInputStream(fName));
	}
	public static PrintStream printStream(String fName) throws FileNotFoundException {
		return new PrintStream(new FileOutputStream(fName));
	}
	
	public static void main(String[] args){
		Scanner input=null;
        PrintStream out = System.out;

        try {
            input = fileScanner("p2_asm.txt");
            out = printStream("p2_code.txt");
        } catch(FileNotFoundException e) {
            System.out.println("Error with input or output file");
            System.exit(0);
        }
	
        ArrayList<String> lines = new ArrayList<String>();
	
        while(input.hasNextLine()){
        	lines.add(input.nextLine());
        }
          
        int size = lines.size();
        String line = null;
        for(int i = 0; i < size; i++){
        	line = lines.get(i);
        	if(line.equalsIgnoreCase("halt")){
        		out.println("00000000");
        	}else if(line.equalsIgnoreCase("bra")){
        		out.println("01000001");
        	}else if(line.equalsIgnoreCase("beq")){
        		out.println("01000010");
        	}else if(line.equalsIgnoreCase("bgt")){
        		out.println("01000100");
        	}else if(line.equalsIgnoreCase("br1")){
        		out.println("01001000");
        	}else if(line.equalsIgnoreCase("add")){
        		out.println("10000000");
        	}else if(line.equalsIgnoreCase("adds")){
        		out.println("10000001");
        	}else if(line.equalsIgnoreCase("inc")){
        		out.println("10001000");
        	}else if(line.equalsIgnoreCase("dec")){
        		out.println("10001001");
        	}else if(line.equalsIgnoreCase("wdt")){
        		out.println("10010000");
        	}else if(line.equalsIgnoreCase("initr1")){
        		out.println("10100000");
        	}else if(line.equalsIgnoreCase("initr2")){
        		out.println("10100001");
        	}else if(line.equalsIgnoreCase("initr3")){
        		out.println("10100010");
        	}else if(line.equalsIgnoreCase("initr4")){
        		out.println("10100011");
        	}else if(line.equalsIgnoreCase("ld1")){
        		out.println("11000001");
        	}else if(line.equalsIgnoreCase("ld2")){
        		out.println("11000010");
        	}else if(line.equalsIgnoreCase("ld3")){
        		out.println("11000011");
        	}else if(line.equalsIgnoreCase("ld4")){
        		out.println("11000100");
        	}else if(line.equalsIgnoreCase("ld5")){
        		out.println("11000101");
        	}else if(line.equalsIgnoreCase("ld6")){
        		out.println("11000110");
        	}else if(line.equalsIgnoreCase("st1")){
        		out.println("11100001");
        	}else if(line.equalsIgnoreCase("st2")){
        		out.println("11100010");
        	}else if(line.equalsIgnoreCase("st3")){
        		out.println("11100011");
        	}else if(line.equalsIgnoreCase("st4")){
        		out.println("11100100");
        	}else if(line.equalsIgnoreCase("st5")){
        		out.println("11100101");
        	}else{
        		System.out.println("BAD LINE: " + i);
        	}
        }
        
        out.close();
	
	
	}
	
}
