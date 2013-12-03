import x10.util.concurrent.AtomicReference;

public class LockFreeQueueString{
	private static type Data = String;
	public var maxSize: Long = 0;
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
		maxSize++;
	}
	public def dequeue():Data{
		var d:Data = null;
		var h:Node = null;
		var t:Node = null;
		var n:Node = null;
		do {
			h = head.get();
			t = tail.get();
			n = h.next.get() ;
			if ( head.get() != h) continue ;
			if ( n == null )
				return null;
			if( t == h )
				tail.compareAndSet(t,n);
			else
				if( head.compareAndSet(h ,n )) break;
		} while (true);

		d = n.data;
		n.data = null;
		h.next = null;
		return d;
	}
}