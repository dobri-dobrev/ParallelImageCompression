import x10.util.concurrent.AtomicReference;

public class LockFreeQueue{
	private static type Data = ImageWrapper;

	private static class Node{
		var data:Data = null;
		var next: AtomicReference[Node] = AtomicReference.newAtomicReference[Node](null);
		public def this(data: Data, next: Node){
			this.data = data;
			this.next = AtomicReference.newAtomicReference[Node](next);
		}
	}

	private var head: AtomicReference[Node];
	private var tail: AtomicReference[Node];

	public def this(){
		val sentinel = new Node(null, null);
		head = AtomicReference.newAtomicReference[Node](sentinel);
		tail = AtomicReference.newAtomicReference[Node](sentinel);

	}
	public def enqueue(data: Data){
		//Console.OUT.println("start enqueue");
		var d: Node = new Node(data, null);
		var t: Node = null;
		var n: Node = null;
		do{
			t = tail.get();
			n = t.next.get();
			if(tail.get()!= t) continue;
			if(n!= null){
				tail.compareAndSet(t,n);
				continue;
			}
			if(t.next.compareAndSet(null, d)) break;

		}while (true);
		tail.compareAndSet(t,d);
		//Console.OUT.println("end enqueue");
	}
	public def dequeue():Data{
		//Console.OUT.println("start dequeue");
		var d:Data = null;
		var h:Node = null;
		var t:Node = null;
		var n:Node = null;
		do {
			h = head.get();
			t = tail.get();
			n = h.next.get() ;
			if ( head.get() != h) continue ;
			if ( n == null ){
				//Console.OUT.println("end enqueue");
				return null;
			}
				
			if( t == h )
				tail.compareAndSet(t,n);
			else
				if( head.compareAndSet(h ,n )) break;
		} while (true);

		d = n.data;
		n.data = null;
		h.next = null;
		//Console.OUT.println("end enqueue");
		return d;
	}
}