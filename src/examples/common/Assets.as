/**
 * Created by rodrigo on 9/25/13.
 */
package examples.common {
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;

	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class Assets {

		public static var boneAtlasGFX:BitmapData;
		public static var boneAtlasXML:XML;
		public static var skeletonXML:XML;

		public static var onLoadComplete:Signal = new Signal();

		private static var loader: LoaderMax;

		public function Assets() {
		}

		public static function loadAssets(pPath:String):void {
			loader = new LoaderMax({onComplete:onLoaded});
			loader.append(new ImageLoader( pPath +'texture.png', {name:'tex_gfx'}));
			loader.append(new XMLLoader( pPath +'texture.xml', {name:'tex_xml'}));
			loader.append(new XMLLoader( pPath +'skeleton.xml', {name:'skeleton_xml'}));
			loader.load(true);
		}

		private static function onLoaded(e:LoaderEvent): void {
			Assets.boneAtlasGFX = loader.getContent('tex_gfx').rawContent.bitmapData ;
			Assets.boneAtlasXML = loader.getContent('tex_xml') ;
			Assets.skeletonXML = loader.getContent('skeleton_xml') ;
			onLoadComplete.dispatch() ;
		}
	}
}
