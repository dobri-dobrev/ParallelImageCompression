import x10.io.ReaderIterator;
import x10.io.File;
import x10.io.Printer;
import x10.lang.Exception;
import x10.io.FileNotFoundException;
import x10.array.Array;
import x10.util.ArrayList;
import x10.array.Array_2;


public class Stream{
	
	public static def main(args:Rail[String]) {
        
        if(args.size!=1) {
        	Console.ERR.println(args(0) + " is not a valid file");
        	throw new IllegalArgumentException(args(0) + " is not a valid file");
        }
        val sourceFilename = args(0);
    	var sw: StreamWrapper = new StreamWrapper();
    	sw.exec(sourceFilename);
        
        //printMatrix(m);
       
        

    }
    
}