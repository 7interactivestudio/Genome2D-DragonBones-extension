/**
 * Created by rodrigo on 9/9/13.
 */
package com.rodrigolopezpeker.genome2d.dragonbones {
	import com.genome2d.textures.GTextureAtlas;
	import com.genome2d.textures.GTextureUtils;

	import dragonBones.textures.ITextureAtlas;
	import dragonBones.utils.ConstValues;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class GDBTextureAtlas extends GTextureAtlas implements ITextureAtlas {

		private var _name: String;
		private var _alignSubTexture: int = 0 ;

		/**
		 * Constructor.
		 * @param pId
		 * @param pBitmap
		 * @param pAtlasXML
		 */
		public function GDBTextureAtlas(pId: String, pBitmap: BitmapData, pAtlasXML: XML, pAlign:int=0) {
			if (pAtlasXML) {
				_name = pAtlasXML.attribute(ConstValues.A_NAME);
			} else {
				_name = pId;
			}
			_alignSubTexture = pAlign ;
			super( _name, 3, pBitmap.width, pBitmap.height, pBitmap, GTextureUtils.isBitmapDataTransparent(pBitmap), null);
			parseAtlas(pAtlasXML)
		}

		public function get name(): String {return _name;}

		override public function dispose(): void {
			super.dispose();
		}

		public function getRegion(pName: String): Rectangle {
			return getTexture(pName).region;
		}

		private function parseAtlas(pAtlasXML: XML): void {
			var i: int = 0;
			while (i < pAtlasXML.children().length()) {
				var node: XML = pAtlasXML.children()[i];
				var rect: Rectangle = new Rectangle(node.@x, node.@y, node.@width, node.@height);
				var pivotX: Number = node.@frameX == undefined && node.@frameWidth == undefined ? 0 : node.@frameX + (node.@frameWidth - rect.width) / 2;
				var pivotY: Number = node.@frameY == undefined && node.@frameHeight == undefined ? 0 : node.@frameY + (node.@frameHeight - rect.height) / 2;

				// top left.
				if( _alignSubTexture == 1 ) {
					pivotX = -rect.width/2;
					pivotY = -rect.height/2;
				}
				addSubTexture(node.@name, rect, pivotX, pivotY);
				++i;
			}
			invalidate();
		}



	}
}
