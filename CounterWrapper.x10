public class CounterWrapper{
	private var count: Long;
	public def this(){
		count = 0;
	}
	public def increment(){
		count++;
	}
	public def get(): Long{
		return count;
	}
}