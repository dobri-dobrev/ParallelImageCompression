import x10.io.ReaderIterator;
import x10.io.File;
import x10.io.Printer;

//inspired by http://www.blackpawn.com/texts/blur/
public class ImageProcessing{
	public static def readInMatrix(filename: String):Rail[Rail[Pixel]]{
	    var F: File  = new File(filename);
		var matrix: Rail[Rail[Pixel]];
		var itr:ReaderIterator[String] = F.lines();
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

	public static def horizontalBlur(m: Rail[Rail[Pixel]], blur: Long): Rail[Rail[Pixel]]{
		val dist = blur;
		var outM: Rail[Rail[Pixel]] = new Rail[Rail[Pixel]](m.size);

		for(var y:Long = 0; y<m.size; y++){
			outM(y)= new Rail[Pixel](m(0).size);
			for(var x: Long = 0; x<m(0).size; x++){
				var t: Pixel = new Pixel(0,0,0);
				for(var kx: Long = -1*dist; kx<= dist; kx++){
					if(kx+x<0 || kx+x>= m(0).size){
						t = t.add(m(y)(x));	
					}
					else{
						t = t.add(m(y)(kx+x));	
					}
					
				}
				outM(y)(x) = t.divide(dist*2+1);

			}
		}
		return outM;
	}

	public static def verticalBlur(m: Rail[Rail[Pixel]], blur: Long):Rail[Rail[Pixel]]{
		var outM: Rail[Rail[Pixel]] = new Rail[Rail[Pixel]](m.size);
		//initialize outM
		for(var i:Long = 0; i<outM.size; i++){
			outM(i) = new Rail[Pixel](m(0).size );
		}
		for(var x:Long = 0; x<m(0).size; x++){
			for(var y:Long = 0; y<m.size; y++){
				var t: Pixel = new Pixel(0,0,0);
				for(var ky:Long = -1*blur; ky<=blur; ky++){
					if(ky+y<0 || ky+y>= m.size){
						t = t.add(m(y)(x));	
					}
					else{
						t = t.add(m(ky+y)(x));	
					}

				}
				outM(y)(x) = t.divide(blur*2+1);
			}
		}

		return outM;
	}
	public static def redFilter(m: Rail[Rail[Pixel]]):Rail[Rail[Pixel]]{
		var outM: Rail[Rail[Pixel]] = new Rail[Rail[Pixel]](m.size);
		//initialize outM
		
		for(var y:Long = 0; y<m.size; y++){
			outM(y)= new Rail[Pixel](m(0).size);
			for(var x:Long = 0; x<m(y).size; x++){
				val tPixel = m(y)(x);
				var g:Long  =0;
				if(tPixel.g-100>0){
					g = tPixel.g-100;
				}
				var b:Long  =0;
				if(tPixel.b-100>0){
					b = tPixel.b-100;
				}
				outM(y)(x) = new Pixel(tPixel.r, g,b);
			}
		}

		return outM;
	}
	public static def matrixToFile(m: Rail[Rail[Pixel]], fileName: String){
        val F = new File("OUT"+fileName);
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
}