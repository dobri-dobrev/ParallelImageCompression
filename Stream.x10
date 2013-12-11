import x10.io.ReaderIterator;
import x10.io.File;
import x10.io.Printer;
import x10.lang.Exception;
import x10.io.FileNotFoundException;
import x10.array.Array;
import x10.util.ArrayList;
import x10.array.Array_2;
import x10.util.Timer;

public class Stream{
	
	public static def main(args:Rail[String]) {
        
        if(args.size!=7) {
        	Console.ERR.println(args(0) + " is not a valid file");
        	throw new IllegalArgumentException(args(0) + " is not a valid file");
        }
        val start = Timer.milliTime();
        val sourceFilename = args(0);
        val readThreads = Long.parse(args(1));
        val hbThreads = Long.parse(args(2));
        val vbThreads = Long.parse(args(3));
        val filterThreads = Long.parse(args(4));
        val writeThreads = Long.parse(args(5));
        val sTime = Long.parse(args(6));
    	var sw: StreamWrapper = new StreamWrapper();
    	sw.exec(sourceFilename, readThreads, hbThreads, vbThreads, filterThreads, writeThreads, sTime);
        val end = Timer.milliTime();
        val time = end-start;
        Console.OUT.println("Execution time was "+time);
        //printMatrix(m);
       
        

    }
    
}