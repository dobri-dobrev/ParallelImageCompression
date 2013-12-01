import x10.io.ReaderIterator;
import x10.io.File;
import x10.io.Printer;
import x10.lang.Exception;
import x10.io.FileNotFoundException;
import x10.array.Array;
import x10.util.ArrayList;
import x10.array.Array_2;

public class Main{
	public static def main(args:Rail[String]) {
        var F:File;
        if(args.size!=1) {
        	Console.ERR.println(args(0) + " is not a valid file");
        	throw new IllegalArgumentException(args(0) + " is not a valid file");
        }
        val filename = args(0);
        F  = new File(filename);
        var m:Rail[Rail[Pixel]] = readInMatrix(F);
        //printMatrix(m);
        matrixToFile(m, "sampleOut.ppt");
        Console.OUT.println(areAllZero(m));

    }

    public static def readInMatrix(f:File):Rail[Rail[Pixel]]{
    	var matrix: Rail[Rail[Pixel]];
    	var itr:ReaderIterator[String] = f.lines();
    	var t:String = itr.next();
    	t = itr.next();
    	val v = t.split(" ");
    	val width = Long.parse(v(0).trim());
    	val height = Long.parse(v(1).trim());
        var curWidth: Long = 0;
        var curHeight: Long = 0;
        var counter: Long = 0;
        Console.OUT.println("width "+width+" height "+height);
        t = itr.next();
        matrix = new Rail[Rail[Pixel]](height);
        matrix(0) = new Rail[Pixel](width);
        var red:Long =0;
        var green: Long = 0;
        var blue: Long = 0;
        
        while(itr.hasNext()){
            t = itr.next();
            
            //Console.OUT.println("row number "+tempRowCount);
            
            //Console.OUT.println("Row is "+ t);
            val row = t.split(" ");
            
            for(var i:Long = 0; i< row.size; i++){
                if(row(i).length()==0n){

                }
                else{
                    //Console.OUT.println(row(i).length());
                    if(curWidth == width){
                        curWidth = 0;
                        curHeight+=1;
                        //Console.OUT.println(row(i)+ " new row, left " +(row.size-i) );
                        matrix(curHeight) = new Rail[Pixel](width);
    
                    }
                    if(counter ==2){
                        
                        
                        counter = -1;
                        blue = Long.parse(row(i).trim());
                        //Console.OUT.println(curHeight+ " "+ curWidth + " "+tempPixel.toString());
                        matrix(curHeight)(curWidth) = new Pixel(red, green, blue);

                        curWidth+=1;
                    }
                    if( counter ==1){
                        green = Long.parse(row(i).trim());
                    }
                    if(counter == 0){
                        
                        red = Long.parse(row(i).trim());
                    }
                    counter+=1;
                }

            }

        }
        return matrix;

    }
    public static def matrixToFile(m: Rail[Rail[Pixel]], fileName: String){
        val F = new File(fileName);
        val printer = F.printer();
        printer.println("P3");
        printer.println(m(0).size+ " "+ m.size);
        printer.println("255");
        var curHeight: Long = 0;
        var curWidth: Long = 0;
        var curLineCounter: Long = 0;
        var tempLineString: String = "";
        while(curHeight< m.size){
            if(curLineCounter== 5){
                printer.println(tempLineString);
                tempLineString="";
                curLineCounter=0;
            }
            if(curWidth== m(curHeight).size){
                curHeight++;
                curWidth = 0;
            }
            if(curHeight< m.size){
                tempLineString+= m(curHeight)(curWidth).print();
                curWidth++;
                curLineCounter++;
            }

        }
        printer.flush();

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