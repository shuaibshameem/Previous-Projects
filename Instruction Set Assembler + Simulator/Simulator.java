import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Scanner;


public class Simulator {

	public static void main(String[] Args){
		
		Scanner codeInput = null;
		Scanner dataInput = null;
		PrintStream output = System.out;
		PrintStream dataOutput = System.out;
		
		try{
			codeInput = fileScanner("p2_code.txt");
			dataInput = fileScanner("data.txt");
			output = printStream("p2_data1_log.txt");
		}catch(FileNotFoundException e) {
            System.out.println("Error with input or output file");
            System.exit(0);
        }
		
		ArrayList<String> Instr = new ArrayList<String>();
		ArrayList<String> Data = new ArrayList<String>();
		
		while(codeInput.hasNextLine()){
			Instr.add(codeInput.nextLine());
		}
		while(dataInput.hasNextLine()){
			Data.add(dataInput.nextLine());
		}
		
		int PC = 0;
		int clkExec = 0;
		int R1 = 0, R2 = 0, R3 = 0, R4 = 0;
		int leftOne = 0, rightOne = 0;
		boolean is_halt = false;
		boolean gotLeft = false;
		String IR = null;
		String OpCode = null;
		String DescCode = null;
		String ExactCode = null;
		String tempR2 = null;
		boolean carryBit = false;
		String genTemp = null;
		
		while(is_halt != true){
			
			IR = Instr.get(PC);
			
			OpCode = IR.substring(0,2);
			DescCode = IR.substring(2,5);
			ExactCode = IR.substring(5);
			
			if(OpCode.equals("00")){
				is_halt = true;
				output.println("Clk" + clkExec);
				output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
				output.println("Instruction 00XXXXXX means halt");
				output.println("End of execution; Total # of dynamic instructions: " + clkExec);
			}
			
			if(OpCode.equals("01")){
				if(DescCode.equals("000")){
					if(ExactCode.equals("001")){
						//BRA
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						PC -= 10;
						PC++;
						output.println("Instruction 01000001 means bra; PC=PC-9");
						genTemp = "000000" + Integer.toString(PC, 2);
						genTemp = genTemp.substring(genTemp.length() - 6);
						output.println("After Execution: PC=" + genTemp);
					}
					if(ExactCode.equals("010")){
						//BEQ
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 01000010 means beq; if R1 = 63 or if R4 = 8, PC=PC+1");
						if(R1 == 63 || R4 == 8){
							PC++;
						}
						PC++;
						genTemp = "000000" + Integer.toString(PC, 2);
						genTemp = genTemp.substring(genTemp.length() - 6);
						output.println("After Execution: PC=" + genTemp);
					}
					if(ExactCode.equals("100")){
						//BGT
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 01000100 means bgt; if R4 >= R3, PC=PC+4");

						if( R4 >= R3 ){
							PC += 4;
						}
						PC++;
						genTemp = "000000" + Integer.toString(PC, 2);
						genTemp = genTemp.substring(genTemp.length() - 6);
						output.println("After Execution: PC=" + genTemp);
					}
				}
				if(DescCode.equals("001") && ExactCode.equals("000")){
					//BNZ
					output.println("Clk" + clkExec);
					output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
					output.println("Instruction 01001000 means br1; if R1!=1, PC=PC-4");
					if( R1 != 1){
						PC -= 4;
					}
					PC++;
					genTemp = "000000" + Integer.toString(PC, 2);
					genTemp = genTemp.substring(genTemp.length() - 6);
					output.println("After Execution: PC=" + genTemp);
				}
			}
			
			if(OpCode.equals("10")){
				if(DescCode.equals("000")){
					if(ExactCode.equals("000")){
						//ADD
						carryBit = false;
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 10000000 means add; R3 = R2 + R3");
						R3 = R2 + R3;
						if(R3 > 255 ){
							carryBit = true;
							R3 = R3 - 256;
						}
						PC++;
						genTemp = "00000000" + Integer.toString(R3, 2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R3=" + genTemp);

					}
					if(ExactCode.equals("001")){
						//ADDS
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 10000001 means adds; if carry, R4=R4+1");
						if(carryBit){
							R4++;
						}
						PC++;
						genTemp = "00000000" + Integer.toString(R4, 2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R4=" + genTemp);
						
					}
				}
				if(DescCode.equals("001")){
					if(ExactCode.equals("000")){
						//INC
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 10001000 means inc; R1=R1+1");
						R1++;
						PC++;
						genTemp = "00000000" + Integer.toString(R1, 2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R1=" + genTemp);
					}
					if(ExactCode.equals("001")){
						//DEC
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 10001001 means dec; R1=R1-1");
						R1--;
						PC++;
						genTemp = "00000000" + Integer.toString(R1, 2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R1=" + genTemp);
					}
				}
				if(DescCode.equals("010")){
					//WDT
					output.println("Clk" + clkExec);
					output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
					output.println("Instruction 10010000 means wdt; R3 = width of R2");
					tempR2 = Integer.toString(R2, 2);
					leftOne = 0;
					rightOne = 0;
					gotLeft = false;
					for(int i = 0; i < tempR2.length(); i++){
						if(tempR2.charAt(i) == '1'){
							if(gotLeft){
								rightOne = i;
							}else{
								leftOne = rightOne = i;
								gotLeft = true;
							}
						}
					}
					if(gotLeft)
						R3 = (rightOne - leftOne + 1);
					else
						R3 = 0;
					PC++;
					genTemp = "00000000" + Integer.toString(R3,2);
					genTemp = genTemp.substring(genTemp.length() - 8);
					output.println("After Execution: R3=" + genTemp);
				}
				if(DescCode.equals("100")){
					if(ExactCode.equals("000")){
						//INITR1
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 10100000 means initR1; R1=0");
						R1 = 0;
						PC++;
						genTemp = "00000000" + Integer.toString(R1,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R1=" + genTemp);
					}
					if(ExactCode.equals("001")){
						//INITR2
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 10100001 means initR2; R2=0");
						R2 = 0;
						PC++;
						genTemp = "00000000" + Integer.toString(R2,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R2=" + genTemp);
					}
					if(ExactCode.equals("010")){
						//INITR3
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 10100010 means initR3; R3=0");
						R3 = 0;
						PC++;
						genTemp = "00000000" + Integer.toString(R3,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R3=" + genTemp);
					}
					if(ExactCode.equals("011")){
						//INITR4
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 10100011 means initR4; R4=0");
						R4 = 0;
						PC++;
						genTemp = "00000000" + Integer.toString(R4,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R4=" + genTemp);
					}
				}
			}
			
			if(OpCode.equals("11")){
				if(DescCode.equals("000")){
					if(ExactCode.equals("001")){
						//LD1
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11000001 means ld1; R1 = [0]");
						R1 = Integer.parseInt(Data.get(0), 2);
						PC++;
						genTemp = "00000000" + Integer.toString(R1,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R1=" + genTemp);
					}
					if(ExactCode.equals("010")){
						//LD2
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11000010 means ld2; R2 = [0]");
						R2 = Integer.parseInt(Data.get(0), 2);
						PC++;
						genTemp = "00000000" + Integer.toString(R2,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R2=" + genTemp);
					}
					if(ExactCode.equals("011")){
						//LD3
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11000011 means ld3; R3 = [0]");
						R3 = Integer.parseInt(Data.get(0), 2);
						PC++;
						genTemp = "00000000" + Integer.toString(R3,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R3=" + genTemp);
					}
					if(ExactCode.equals("100")){
						//LD4
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11000100 means ld4; R1 = 00011111");
						R1 = 31;
						PC++;
						genTemp = "00000000" + Integer.toString(R1,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R1=" + genTemp);
					}
					if(ExactCode.equals("101")){
						//LD5
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11000101 means ld5; R2 = [R1]");
						R2 = Integer.parseInt(Data.get(R1), 2);
						PC++;
						genTemp = "00000000" + Integer.toString(R2,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R2=" + genTemp);
					}
					if(ExactCode.equals("110")){
						//LD6
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11000110 means ld6; R4 = R3");
						R4 = R3;
						PC++;
						genTemp = "00000000" + Integer.toString(R4,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						output.println("After Execution: R4=" + genTemp);
					}
				}
				if(DescCode.equals("100")){
					if(ExactCode.equals("001")){
						//ST1
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11100001 means st1; [1] = R4");
						genTemp = "00000000" + Integer.toString(R4,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						Data.set(1, genTemp);
						PC++;
						output.println("After Execution: [1]=" + genTemp);
					}
					if(ExactCode.equals("010")){
						//ST2
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11100001 means st2; [2] = R3");
						genTemp = "00000000" + Integer.toString(R3,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						Data.set(2, genTemp);
						PC++;
						output.println("After Execution: [2]=" + genTemp);
					}
					if(ExactCode.equals("011")){
						//ST3
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11100001 means st3; [3] = R3");
						genTemp = "00000000" + Integer.toString(R3,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						Data.set(3, genTemp);
						PC++;
						output.println("After Execution: [3]=" + genTemp);
					}
					if(ExactCode.equals("100")){
						//ST4
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11100001 means st4; [4] = R2");
						genTemp = "00000000" + Integer.toString(R2,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						Data.set(4, genTemp);
						PC++;
						output.println("After Execution: [4]=" + genTemp);
					}
					if(ExactCode.equals("101")){
						//ST5
						output.println("Clk" + clkExec);
						output.println(log(PC, IR, R1, R2, R3, R4, carryBit));
						output.println("Instruction 11100001 means st5; [5] = R1");
						genTemp = "00000000" + Integer.toString(R1,2);
						genTemp = genTemp.substring(genTemp.length() - 8);
						Data.set(5, genTemp);
						PC++;
						output.println("After Execution: [5]=" + genTemp);
					}
				}
			}
			
			clkExec++;
			output.println();
			
			
			
		}
		
		try{
			dataOutput = printStream("data.txt");
		}catch(FileNotFoundException e) {
            System.out.println("Error with input or output file");
            System.exit(0);
        }
		
		for(int i = 0; i < Data.size(); i++){
			dataOutput.println(Data.get(i));
		}
		output.close();
		dataOutput.close();
		
		
	}
	
	public static String log(int PC, String IR, int R1, int R2, int R3, int R4, boolean CF){
		String PCtemp = "000000" + Integer.toString(PC, 2);
		String R1temp = "00000000" + Integer.toString(R1, 2);
		String R2temp = "00000000" + Integer.toString(R2, 2);
		String R3temp = "00000000" + Integer.toString(R3, 2);
		String R4temp = "00000000" + Integer.toString(R4, 2);
		PCtemp = PCtemp.substring(PCtemp.length() - 6);
		R1temp = R1temp.substring(R1temp.length() - 8);
		R2temp = R2temp.substring(R2temp.length() - 8);
		R3temp = R3temp.substring(R3temp.length() - 8);
		R4temp = R4temp.substring(R4temp.length() - 8);
		int carry = 0;
		if(CF){
			carry = 1;
		}
		return "PC=" + PCtemp + " IR=" + IR + " R1=" + R1temp + " R2=" + R2temp + " R3=" + R3temp + " R4=" + R4temp + " CF=" + carry;
	}

	public static Scanner fileScanner(String fName) throws FileNotFoundException {
		return new Scanner(new FileInputStream(fName));
	}
	
	public static PrintStream printStream(String fName) throws FileNotFoundException {
	            return new PrintStream(new FileOutputStream(fName));
	}
	
}