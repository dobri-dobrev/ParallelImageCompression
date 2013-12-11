import x10.io.ReaderIterator;
import x10.io.File;
import x10.io.Printer;
import x10.lang.Exception;
import x10.io.FileNotFoundException;
import x10.array.Array;
import x10.util.ArrayList;
import x10.array.Array_2;
import x10.util.Timer;

public class Main{
	public static def main(args:Rail[String]) {
        
        if(args.size!=1) {
        	Console.ERR.println(args(0) + " is not a valid file");
        	throw new IllegalArgumentException(args(0) + " is not a valid file");
        }
        val start = Timer.milliTime();
        val sourceFilename = args(0);
        var sourceFile: File = new File(sourceFilename);
        for (line in sourceFile.lines()){
            executeOne(line.trim());
            Console.OUT.println("Done with "+line);
        }
        val end = Timer.milliTime();
        val time = end - start;
        Console.OUT.println("Execution time was "+ time);
        //printMatrix(m);
       
        

    }
    public static def executeOne(filename: String){
        var m:Rail[Rail[Pixel]] = ImageProcessing.readInMatrix(filename);
        m = ImageProcessing.horizontalBlur(m, 10);
        m = ImageProcessing.verticalBlur(m, 10);
        m = ImageProcessing.redFilter(m);
        ImageProcessing.matrixToFile(m, filename);
    }

    
    


    public static def printMatrix( m: Rail[Rail[Pixel]]){
        for(var i:Long =0; i<m.size; i++){
            var s:String = "";
            for(var j: Long = 0; j< m(0).size; j++){
                s+=m(i)(j).toString() + " ";
            }
            Console.OUT.println(s);
        }
    }
    public static def areAllZero(m: Rail[Rail[Pixel]]):boolean{
        for(var i:Long =0; i<m.size; i++){
            
            for(var j: Long = 0; j< m(i).size; j++){
                if(m(i)(j).r !=0)
                    return false;
            }

        }
        return true;
    }
}