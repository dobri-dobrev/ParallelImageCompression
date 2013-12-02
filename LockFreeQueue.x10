public class LockFreeQueue{
	private static type Data = Rail[Rail[Pixel]];

	private static class Node{
		var data:Data = null;
		var next: AtomicReference[Node] = AtomicReference.newAtomicReference[Node](null);
		public def this(data: Data, next: Node){
			this.data = data;
			this.next = next;
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
	}
	public def dequeue():Data{
		
	}
}