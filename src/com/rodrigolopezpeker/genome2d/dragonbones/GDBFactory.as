/**
 * Created by rodrigo on 9/9/13.
 */
package com.rodrigolopezpeker.genome2d.dragonbones {
	import com.genome2d.textures.GTexture;

	import dragonBones.Armature;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.factorys.BaseFactory;
	import dragonBones.textures.ITextureAtlas;

	import flash.display.BitmapData;

	use namespace dragonBones_internal;

	public class GDBFactory  extends BaseFactory {

		public var scaleForTexture:Number ;

		public function GDBFactory() {
			super(this);
			scaleForTexture = 1;
		}

		override protected function generateTextureAtlas( content: Object, textureAtlasRawData: Object): ITextureAtlas {
			var textureAtlas:GDBTextureAtlas = new GDBTextureAtlas('', content as BitmapData, textureAtlasRawData as XML, 0 );
			content.dispose();
			return textureAtlas ;
		}

		override public function getTextureDisplay(textureName: String, textureAtlasName: String = null, pivotX: Number = NaN, pivotY: Number = NaN): Object {
			return super.getTextureDisplay(textureName, textureAtlasName, pivotX, pivotY);
		}

		override protected function generateArmature(): Armature {
			var displayNode:GDBNode = new GDBNode() ;
			var armature:Armature = new Armature(displayNode);
			displayNode.armature = armature ;
			return armature;
		}

		override protected function generateSlot(): Slot {
			var displayBridge:GDBDisplayBridge = new GDBDisplayBridge() ;
			var slot: Slot = new Slot(displayBridge) ;
			displayBridge.slot = slot ;
			return slot ;
		}

		override protected function generateDisplay(textureAtlas: Object, fullName: String, pivotX: Number, pivotY: Number): Object {
			var texture:GTexture = (textureAtlas as GDBTextureAtlas).getTexture(fullName) as GTexture ;
			if( !texture ) return null ;
			var display:GDBNode = new GDBNode();
			display.pivotX = pivotX ;
			display.pivotY = pivotY ;
			display.setTexture( texture ) ;
			return display ;
		}
	}
}
