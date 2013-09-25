/**
 * Created by rodrigo on 9/10/13.
 */
package com.rodrigolopezpeker.genome2d.dragonbones {
	import com.genome2d.components.GCamera;
	import com.genome2d.components.renderables.GRenderable;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.context.GContext;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.g2d;
	import com.genome2d.textures.GTexture;

	import dragonBones.Armature;

	import flash.geom.Rectangle;

	use namespace g2d ;

	public class GDBComponent extends GRenderable {

		private var _armature: Armature;
		private var display: GDBNode;
		private var viewRect: Rectangle ;
//		private var refDotTexure:GTexture ;
//		private var refDotBlack:GTexture ;
//		public var renderBounds:Boolean = false ;

		public var hitArea:GSprite ;
		public var bounds:Rectangle ;
		private var _useHitArea: Boolean;

		// remember to match this to the used texture size!
		public var hitAreaTextureSize: uint = 8 ;

		public function GDBComponent(pNode:GNode) {
			super(pNode);
			bounds = new Rectangle();
			viewRect = node.core.config.viewRect;
		}

		public function setArmature(pArmature: Armature): void {
			if( _armature ) {
				_armature.dispose();
				_armature = null ;
			}
			if( pArmature ){
				_armature = pArmature;
				display = _armature.display as GDBNode ;
			}
		}

		override public function render(p_context: GContext, p_camera: GCamera, p_maskRect: Rectangle): void {
			if( _useHitArea ) bounds.setEmpty();
			renderChilds(display, p_context, p_camera, p_maskRect);
			if( _useHitArea ){
				hitArea.node.transform.setPosition( bounds.x, bounds.y );
				hitArea.node.transform.setScale( bounds.width/hitAreaTextureSize, bounds.height/hitAreaTextureSize);
			}
			// render center.
//			p_context.draw(refDotBlack, bounds.x, bounds.y, bounds.width / 16, bounds.height/16, 0, 1, 1, 1, 0.3 ) ;
		}

		private function renderChilds(pDisplay: GDBNode, pContext: GContext, pCamera: GCamera, pMask:Rectangle = null): void {
			var len:uint = pDisplay.numChildren;
			var list: Vector.<GDBNode> = pDisplay.getChilds() ;
			for (var i: int = 0; i < len; i++) {
				var child:GDBNode = list[i] ;//pDisplay.getChildAt(i);
				if( child.visible ){
					if( child.hasChildren ){
						renderChilds( child, pContext, pCamera, pMask);
					} else {
						renderNode(child, pContext, pCamera, pMask);
					}
				}
			}
		}

		private function renderNode( pChild: GDBNode, pContext: GContext, pCamera: GCamera, pMask:Rectangle = null): void {
			pChild.inline_updateWorldMatrix2(cNode.cTransform.nWorldX, cNode.cTransform.nWorldY,cNode.cTransform.nWorldScaleX, cNode.cTransform.nWorldScaleY, cNode.cTransform.nWorldRotation);
			pContext.draw2( pChild.texture, pChild.worldMatrix, cNode.cTransform.nWorldRed, cNode.cTransform.nWorldGreen, cNode.cTransform.nWorldBlue, cNode.cTransform.nWorldAlpha, iBlendMode, pMask );
			if( _useHitArea ){
				var r:Rectangle = pChild.processBounds() ;
				bounds = bounds.union(r);
				/*if( renderBounds ){
					pContext.draw( refDotBlack, r.x, r.y, r.width / 16, r.height / 16, 0, 1, 1, 1, 0.3, 1, pMask );
				}*/
			}
		}

		public function getBoneDisplay(pId: String): GDBNode { return _armature.getBone(pId).display as GDBNode ;}

		public function getBounds(): Rectangle {
			bounds.setEmpty();
			processBounds( display, display ) ;
			return bounds ;
		}

		private function processBounds( pDisplay: GDBNode, pParent:GDBNode = null ): void {
			var len:uint = pDisplay.numChildren;
			if( len > 0 ){
				pDisplay.bounds.setEmpty();
				for (var i: int = 0; i < len; i++) {
					var child:GDBNode = pDisplay.getChildAt(i);
					if( child.visible ){
						processBounds( child, pDisplay );
					}
				}
			} else {
				pDisplay.inline_updateWorldMatrix2(cNode.cTransform.nWorldX, cNode.cTransform.nWorldY,cNode.cTransform.nWorldScaleX, cNode.cTransform.nWorldScaleY, cNode.cTransform.nWorldRotation);
				pDisplay.processBounds() ;
				if( pParent ){
					pParent.bounds = pParent.bounds.union(pDisplay.bounds);
				}
				bounds = bounds.union(pDisplay.bounds);
			}
		}

		override public function dispose(): void {
			bounds = null ;
			display = null ;
			useHitArea = false ;
			if( hitArea ) hitArea.dispose();
			super.dispose();
		}

		public function get useHitArea(): Boolean {return _useHitArea;}
		public function set useHitArea(value: Boolean): void {
			_useHitArea = value;
			if( _useHitArea ){
				if( !hitArea ){
					hitArea = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
					// define a tiny texture for mouse detection.
					hitArea.node.transform.alpha = 0 ;
					hitArea.node.mouseEnabled = true;
					node.addChild(hitArea.node);
				} else {
					hitArea.active = true ;
					hitArea.node.mouseEnabled = true ;
				}
			} else {
				if( hitArea ) {
					hitArea.active = false ;
					hitArea.node.mouseEnabled = false ;
				}
			}
		}

		public function setHitAreaTextureId(pId:String):void {
			hitArea.textureId = pId;
			// squared texture (8x8, 16x16, etc)
			hitAreaTextureSize = hitArea.getTexture().width ;
		}

		public function get armature(): Armature {
			return _armature;
		}
	}
}
