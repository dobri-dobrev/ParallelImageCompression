import x10.util.concurrent.AtomicLong;

public class CounterWrapper{
	private var count: AtomicLong;
	public def this(){
		count = new AtomicLong(0);
	}
	public def increment(){
		count.incrementAndGet();
	}
	public def get(): Long{
		return count.get();
	}
}