import x10.io.ReaderIterator;
import x10.io.File;
import x10.io.Printer;
import x10.lang.Exception;
import x10.io.FileNotFoundException;
import x10.array.Array;
import x10.util.ArrayList;
import x10.array.Array_2;
import x10.util.concurrent.AtomicLong;
import x10.util.Timer;
import x10.lang.System;

public class StreamWrapper{
	public var readCounter: CounterWrapper;
	public var hbCounter: CounterWrapper;
	public var vbCounter: CounterWrapper;
	public var filterCounter: CounterWrapper;
	public var writerCounter: CounterWrapper;
    public var readTime:  AtomicLong = new AtomicLong(0);
    public var hbTime: AtomicLong = new AtomicLong(0);
    public var vbTime: AtomicLong = new AtomicLong(0);
    public var filterTime: AtomicLong = new AtomicLong(0);
    public var writeTime: AtomicLong = new AtomicLong(0);
    public var SLEEP_TIME: Long;
	public def this(){
		readCounter = new CounterWrapper();
		hbCounter = new CounterWrapper();
		vbCounter = new CounterWrapper();
		filterCounter = new CounterWrapper();
		writerCounter = new CounterWrapper();
	}

	public def exec(sourceFilename: String, readThreads: Long, hbThreads: Long, vbThreads: Long, filterThreads: Long, writeThreads: Long, sleepTime: Long){
		var sourceFile: File = new File(sourceFilename);
        var readQueue: LockFreeQueueString = new LockFreeQueueString();
        var readToHB: LockFreeQueue = new LockFreeQueue();
        var HBtoVB: LockFreeQueue = new LockFreeQueue();
        var VBtoFilter: LockFreeQueue = new LockFreeQueue();
        var FilterToWrite: LockFreeQueue = new LockFreeQueue();
        SLEEP_TIME = sleepTime;
        for (line in sourceFile.lines()){
            readQueue.enqueue(line);
            //Console.OUT.println("pushed "+line);
        }
        val nFiles = readQueue.maxSize;
        finish{
        	async this.readInFiles(readThreads, readQueue, readToHB, nFiles);	
        	async this.horizontalBlur(hbThreads, readToHB, HBtoVB, nFiles, 9);
        	async this.verticalBlur(vbThreads, HBtoVB, VBtoFilter, nFiles, 9);
        	async this.filter(filterThreads, VBtoFilter, FilterToWrite, nFiles);
        	async this.write(writeThreads, FilterToWrite, nFiles);
        	
        }
        // Console.OUT.println("Read time was "+ readTime);
        // Console.OUT.println("horizontal blut time was "+ hbTime);
        // Console.OUT.println("vertical blur time was "+ vbTime);
        // Console.OUT.println("filter time was "+ filterTime);
        // Console.OUT.println("write time was "+ writeTime);
        

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
    			//Console.OUT.println(fileName);
                // val start = Timer.milliTime();
    			val m = ImageProcessing.readInMatrix(fileName);
    			val img = new ImageWrapper(fileName, m);
    			outqueue.enqueue(img);
    			// Console.OUT.println("read in "+fileName);
    			readCounter.increment();
                // val end = Timer.milliTime();
                // readTime.set(readTime.get()+end-start);
    		}
            else{
                System.threadSleep(SLEEP_TIME);
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
    			//Console.OUT.println("begin horizontal Blur");
                // val start = Timer.milliTime();
    			val m = ImageProcessing.horizontalBlur(mIN.getImage(), blurAmmount);
    			val img = new ImageWrapper(mIN.getFilename(), m);
    			outqueue.enqueue(img);
    			// Console.OUT.println("horizontal blurred a matrix");
    			hbCounter.increment();
                // val end = Timer.milliTime();
                // hbTime.set(hbTime.get()+end-start);
    		}
            else{
                System.threadSleep(SLEEP_TIME);
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
                // val start = Timer.milliTime();
    			//Console.OUT.println("begin vertical Blur");
    			val m = ImageProcessing.verticalBlur(mIN.getImage(), blurAmmount);
    			val img = new ImageWrapper(mIN.getFilename(), m);
    			outqueue.enqueue(img);
    			// Console.OUT.println("vertical blurred a matrix");
    			vbCounter.increment();
                // val end = Timer.milliTime();
                // vbTime.set(vbTime.get()+end-start);
    		}
            else{
                System.threadSleep(SLEEP_TIME);
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
                // val start = Timer.milliTime();
    			//Console.OUT.println("begin filter");
    			val m = ImageProcessing.redFilter(mIN.getImage());
    			val img = new ImageWrapper(mIN.getFilename(), m);
    			outqueue.enqueue(img);
    			// Console.OUT.println("filtered a matrix");
    			filterCounter.increment();
                // val end = Timer.milliTime();
                // filterTime.set(filterTime.get()+end-start);
    		}
            else{
                System.threadSleep(SLEEP_TIME);
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
                // val start = Timer.milliTime();
    			// Console.OUT.println("begin writing");
				ImageProcessing.matrixToFile(mIN.getImage(), mIN.getFilename());
    			// Console.OUT.println("wrote "+mIN.getFilename());
    			writerCounter.increment();
                // val end = Timer.milliTime();
                // writeTime.set(writeTime.get()+end-start);
    			// Console.OUT.println("readCounter is "+ readCounter.get());
    			// Console.OUT.println("hbCounter is "+ hbCounter.get());
    			// Console.OUT.println("vbCounter is "+ vbCounter.get());
    			// Console.OUT.println("filterCounter is "+ filterCounter.get());
    			// Console.OUT.println("writerCounter is "+ writerCounter.get());
    		}
            else{
                System.threadSleep(SLEEP_TIME);
            }
    	}

    }

}