# College Projects

Here I have pushed various projects I have completed in the past. 
Most, if not all, are from different classes I took while pursuing my Computer Engineering degree at The University of Illinois at Chicago.

Under **Hardware**, you will find projects ranging
* IC-based circuit design 
* Microprocessor design and architecture 
* Microprocessor-based circuit design and coding

Under **Software**, you will find projects that are solely programming, in the following languages
* JAVA
* MASM x86 Assembly

The descriptions below are a currently incomplete list of the projects available in this repository. This Readme will be updated for completeness in the near future.

## Projects

#### Cache Simulator

This project was completed for ECE 466, Advanced Computer Architecture.
We were given a cache design, with various upgrade options.
Our task was to find the quickest cache configuration and explain why.
Our benchmarks were the use of 5 commonly used utilities, namely: gcc, gzip, mcc, swim, twolf.
I created the cache simulator in java, and used command line to run the program in various configurations and with different cache traces.
The cache traces, raw results, tables, and report are included with the Java class in the folder.

#### Instant Run-Off Voting

This project was completed for CS201, Data Structures & Discrete Mathematics.
Our task was to take an input file of ballots, and determine the election winner, using the Instant Run-Off Voting method.
The program was to create a file that had the round statistics, and declare the election winner.

The input file, resulting output file, tester and election classes are included in the folder.

#### Application-Specific Instruction Set Assembler & Simulator

This project was completed for ECE 366, Computer Architecture II.
This class had a semester-long project in which we were to create a processor to complete two different tasks.
The processor had to be fast and also minimize the amount of resources needed.

After creating the Instruction Set (IS) for the processor, we were required to create a simulator for our processor. The assembler, which would take the task and compile it into binary, could also be created for extra credit.
We would later design the processor in LogicWorks 5.

We were supplied with 6 data inputs (representing the processor memory), 3 inputs for each task.
The simulator would run whichever program was entered, with whichever data set was entered.
It would  output the final state of the memory, along with key information, such as number of instructions and clock cycles.

The I/O files, reports, and code are included in the folder.
