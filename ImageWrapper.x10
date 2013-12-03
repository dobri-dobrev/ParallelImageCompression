public class ImageWrapper{
	public var fileName:String;
	public var img: Rail[Rail[Pixel]];

	public def this(fn: String, i: Rail[Rail[Pixel]]){
		fileName = fn;
		img = i;
	}
	public def getFilename():String{
		return fileName;
	}
	public def getImage():Rail[Rail[Pixel]]{
		return img;
	}
}