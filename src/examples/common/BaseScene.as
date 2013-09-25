/**
 * Created by rodrigo on 9/25/13.
 */
package examples.common {
	import com.genome2d.components.GComponent;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTextureAlignType;
	import com.genome2d.textures.factories.GTextureFactory;
	import com.rodrigolopezpeker.genome2d.dragonbones.GDBFactory;
	import com.rodrigolopezpeker.genome2d.dragonbones.GDBTextureAtlas;

	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.XMLDataParser;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	public class BaseScene extends GComponent {

		public var factory: GDBFactory;
		public var armature: Armature;
		protected var _assetPath:String ;
		protected var _armatureId:String ;

		// viewport half width / height, is useful to calculate stuffs (camera is centered).
		protected var _vhw: int;
		protected var _vhh: int;

		public function BaseScene(pNode:GNode) {
			super(pNode);
		}

		protected function init(): void {

			_vhw = node.core.config.viewRect.width / 2 ;
			_vhh = node.core.config.viewRect.height / 2 ;

			// center scene.
			node.transform.setPosition(node.core.config.viewRect.width>>1,node.core.config.viewRect.height>>1);

			// we need a texture to create the sprites for mouse detection.
			GTextureFactory.createFromColor('hitarea_tx', 0xFFFFFF, 8, 8 ).alignTexture(GTextureAlignType.TOP_LEFT);

			Assets.onLoadComplete.addOnce(onAssetsLoaded);
			Assets.loadAssets(_assetPath);
		}

		private function onAssetsLoaded(): void {
			var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(Assets.skeletonXML);
			var textureAtlas:GDBTextureAtlas = new GDBTextureAtlas('char', Assets.boneAtlasGFX, Assets.boneAtlasXML);
			factory = new GDBFactory();
			factory.addSkeletonData(skeletonData);
			factory.addTextureAtlas(textureAtlas);
			armature = factory.buildArmature( _armatureId );
			WorldClock.clock.add(armature);

			node.core.stage.addEventListener( KeyboardEvent.KEY_UP, handleKeyboard );
			node.core.stage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyboard );
			node.core.stage.addEventListener( MouseEvent.MOUSE_DOWN, handleStageMouse );
			node.core.stage.addEventListener( MouseEvent.MOUSE_UP, handleStageMouse );
			handleArmatureReady() ;
		}

		private function handleStageMouse(event: MouseEvent): void {
			mouseHandler( event.buttonDown ) ;
		}


		protected function handleKeyboard(event: KeyboardEvent): void {
			keyHandler( event.type == KeyboardEvent.KEY_DOWN, event.keyCode );
		}

		// override
		protected function keyHandler(pIsDown: Boolean, pCode: uint): void {}
		protected function mouseHandler(pIsDown: Boolean): void {}


		override public function update(p_deltaTime: Number, p_parentTransformUpdate: Boolean, p_parentColorUpdate: Boolean): void {
			WorldClock.clock.advanceTime(-1);
		}

		protected function handleArmatureReady(): void {
		}
	}
}
