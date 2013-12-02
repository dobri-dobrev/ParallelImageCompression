public class Pixel{
	public var r:Long;
	public var g:Long;
	public var b: Long;
	def this(red:Long, green: Long, blue:Long){
		r = red;
		g = green;
		b = blue;
	}
	def this(){
		// r =0;
		// g =0;
		// b = 0;

	}
	def add(p:Pixel):Pixel{
		return new Pixel(this.r+p.r, this.g+p.g, this.b+p.b);
	}
	def divide(divider: Long):Pixel{
		return new Pixel(this.r/divider, this.g/divider, this.b/divider);
	}

	public def print():String{
		var out:String = "";
		if(r<10){
			out+="00"+r;
		}
		if(r<100 && r>=10){
			out+= "0"+r;
		}
		if(r>=100){
			out += r;
		}
		out+= " ";
		if(g<10){
			out+="00"+g;
		}
		if(g<100 && g>=10){
			out+= "0"+g;
		}
		if(g>=100){
			out += g;
		}
		out+= " ";
		if(b<10){
			out+="00"+b;
		}
		if(b<100 && b>=10){
			out+= "0"+b;
		}
		if(b>=100){
			out += b;
		}
		out+= " ";
		out+= " ";
		return out;
			
	}
	public def toString():String{
		return r+","+b+","+g;
	}
}