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
	public def this(){
		readCounter = new CounterWrapper();
	}

	public def exec(sourceFilename: String){
		var sourceFile: File = new File(sourceFilename);
        var readQueue: LockFreeQueueString = new LockFreeQueueString();
        var readToHB: LockFreeQueue = new LockFreeQueue();
        for (line in sourceFile.lines()){
            readQueue.enqueue(line);
            Console.OUT.println("pushed "+line);
        }
        this.readInFiles(3, readQueue, readToHB, readQueue.maxSize);
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
    			outqueue.enqueue(m);
    			Console.OUT.println("processed "+fileName);
    			readCounter.increment();
    		}
    	}
    }
}