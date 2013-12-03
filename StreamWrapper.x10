import x10.io.ReaderIterator;
import x10.io.File;
import x10.io.Printer;
import x10.lang.Exception;
import x10.io.FileNotFoundException;
import x10.array.Array;
import x10.util.ArrayList;
import x10.array.Array_2;

public class StreamWrapper{
	public var readCounter: CounterWrapper;
	public var hbCounter: CounterWrapper;
	public var vbCounter: CounterWrapper;
	public var filterCounter: CounterWrapper;
	public var writerCounter: CounterWrapper;
	public def this(){
		readCounter = new CounterWrapper();
		hbCounter = new CounterWrapper();
		vbCounter = new CounterWrapper();
		filterCounter = new CounterWrapper();
		writerCounter = new CounterWrapper();
	}

	public def exec(sourceFilename: String){
		var sourceFile: File = new File(sourceFilename);
        var readQueue: LockFreeQueueString = new LockFreeQueueString();
        var readToHB: LockFreeQueue = new LockFreeQueue();
        var HBtoVB: LockFreeQueue = new LockFreeQueue();
        var VBtoFilter: LockFreeQueue = new LockFreeQueue();
        var FilterToWrite: LockFreeQueue = new LockFreeQueue();
        for (line in sourceFile.lines()){
            readQueue.enqueue(line);
            Console.OUT.println("pushed "+line);
        }
        val nFiles = readQueue.maxSize;
        finish{
        	async this.readInFiles(3, readQueue, readToHB, nFiles);	
        	async this.horizontalBlur(2, readToHB, HBtoVB, nFiles, 9);
        	async this.verticalBlur(2, HBtoVB, VBtoFilter, nFiles, 9);
        	async this.filter(2, VBtoFilter, FilterToWrite, nFiles);
        	async this.write(2, FilterToWrite, nFiles);
        	
        }
        

	}
	public def readInFiles(nthr: Long, inqueue: LockFreeQueueString, outqueue: LockFreeQueue, toRead: Long){
    	finish{
    		
    		for(var i:Long = 0; i<nthr; i++){
    			async this.readInPoll(inqueue, outqueue, toRead);
    		}
    	}
    }
    public def readInPoll(inqueue: LockFreeQueueString, outqueue: LockFreeQueue, toRead: Long){
    	while(readCounter.get()<toRead){
    		
    		val fileName = inqueue.dequeue();
    		
    		if(fileName != null){
    			Console.OUT.println(fileName);
    			val m = ImageProcessing.readInMatrix(fileName);
    			val img = new ImageWrapper(fileName, m);
    			outqueue.enqueue(img);
    			Console.OUT.println("processed "+fileName);
    			readCounter.increment();
    		}
    	}
    }
    public def horizontalBlur(nthr: Long, inqueue: LockFreeQueue, outqueue: LockFreeQueue, toBlur: Long, blurAmmount: Long){
    	finish{
    		
    		for(var i:Long = 0; i<nthr; i++){
    			async this.hbPoll(inqueue, outqueue, toBlur, blurAmmount);
    		}
    	}
    }
    public def hbPoll(inqueue: LockFreeQueue, outqueue: LockFreeQueue, toBlur: Long, blurAmmount: Long){
    	while(hbCounter.get()<toBlur){
    		
    		val mIN = inqueue.dequeue();
    		
    		if(mIN != null){
    			Console.OUT.println("begin horizontal Blur");
    			val m = ImageProcessing.horizontalBlur(mIN.getImage(), blurAmmount);
    			val img = new ImageWrapper(mIN.getFilename(), m);
    			outqueue.enqueue(img);
    			Console.OUT.println("horizontal blurred a matrix");
    			hbCounter.increment();
    		}
    	}

    }

    public def verticalBlur(nthr: Long, inqueue: LockFreeQueue, outqueue: LockFreeQueue, toBlur: Long, blurAmmount: Long){
    	finish{
    		
    		for(var i:Long = 0; i<nthr; i++){
    			async this.vbPoll(inqueue, outqueue, toBlur, blurAmmount);
    		}
    	}
    }
    public def vbPoll(inqueue: LockFreeQueue, outqueue: LockFreeQueue, toBlur: Long, blurAmmount: Long){
    	while(vbCounter.get()<toBlur){
    		
    		val mIN = inqueue.dequeue();
    		
    		if(mIN != null){
    			Console.OUT.println("begin vertical Blur");
    			val m = ImageProcessing.verticalBlur(mIN.getImage(), blurAmmount);
    			val img = new ImageWrapper(mIN.getFilename(), m);
    			outqueue.enqueue(img);
    			Console.OUT.println("vertical blurred a matrix");
    			vbCounter.increment();
    		}
    	}

    }
    public def filter(nthr: Long, inqueue: LockFreeQueue, outqueue: LockFreeQueue, toFilter: Long){
    	finish{
    		
    		for(var i:Long = 0; i<nthr; i++){
    			async this.filterPoll(inqueue, outqueue, toFilter);
    		}
    	}
    }
    public def filterPoll(inqueue: LockFreeQueue, outqueue: LockFreeQueue, toFilter: Long){
    	while(filterCounter.get()<toFilter){
    		
    		val mIN = inqueue.dequeue();
    		
    		if(mIN != null){
    			Console.OUT.println("begin filter");
    			val m = ImageProcessing.redFilter(mIN.getImage());
    			val img = new ImageWrapper(mIN.getFilename(), m);
    			outqueue.enqueue(img);
    			Console.OUT.println("filtered a matrix");
    			filterCounter.increment();
    		}
    	}

    }
    public def write(nthr: Long, inqueue: LockFreeQueue,  toWrite: Long){
    	finish{
    		
    		for(var i:Long = 0; i<nthr; i++){
    			async this.writePoll(inqueue,  toWrite);
    		}
    	}
    }
    public def writePoll(inqueue: LockFreeQueue, toWrite: Long){
    	while(writerCounter.get()<toWrite){
    		
    		val mIN = inqueue.dequeue();
    		
    		if(mIN != null){
    			Console.OUT.println("begin writing");
				ImageProcessing.matrixToFile(mIN.getImage(), mIN.getFilename());
    			Console.OUT.println("wrote a file");
    			writerCounter.increment();
    		}
    	}

    }

}