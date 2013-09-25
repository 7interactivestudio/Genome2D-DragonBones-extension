/**
 * Created by rodrigo on 9/9/13.
 */
package com.rodrigolopezpeker.genome2d.dragonbones {
	import com.genome2d.textures.GTexture;

	import dragonBones.Armature;

	import dragonBones.Slot;

	import dragonBones.objects.DBTransform;

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	public class GDBNode {

		public var localMatrix: Matrix ;
		public var worldMatrix: Matrix ;
		public var transform: DBTransform;

		// origins.
		public var pivotX: Number = 0 ;
		public var pivotY: Number = 0 ;
		// aboslute pivot.
		public var pivotX2: Number = 0 ;
		public var pivotY2: Number = 0 ;

		public var bounds: Rectangle ;
		public var textureRect: Rectangle ;
		public var texture: GTexture ;
		public var parent: GDBNode ;

		private var _childs: Vector.<GDBNode> ;
		public var nodeLevel: int;

		public var alpha: Number;
		public var color: uint;
		public var visible: Boolean = true ;

		public var slot: Slot;
		public var armature: Armature;
		public var userData: Object ;
		public var hasChildren: Boolean ;

		public function GDBNode() {
			hasChildren = false ;
			userData = {};
			_childs = new Vector.<GDBNode>() ;
			worldMatrix = new Matrix();
			textureRect = new Rectangle();
			bounds = new Rectangle();
		}

		public function processBounds( pMatrix:Matrix = null ):Rectangle {
			if(!pMatrix) {
				pMatrix = worldMatrix ;
			}
			var topLeft:Point = pMatrix.transformPoint(textureRect.topLeft);
			var topRight:Point = pMatrix.transformPoint(new Point(textureRect.right, textureRect.top));
			var bottomRight:Point = pMatrix.transformPoint(textureRect.bottomRight);
			var bottomLeft:Point = pMatrix.transformPoint(new Point(textureRect.left, textureRect.bottom));
			var left:Number = Math.min(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
			var top:Number = Math.min(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
			var right:Number = Math.max(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
			var bottom:Number = Math.max(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
			bounds.setTo(left, top, right-left, bottom-top);
			return bounds ;
		}

		public function setTexture(pTexture: GTexture): void {
			texture = pTexture ;
			// update pivot.
			pivotX2 = -texture.width/2 + pivotX ;
			pivotY2 = -texture.height/2 + pivotY ;
			texture.pivotX = pivotX2 ;
			texture.pivotY = pivotY2 ;
			textureRect.x = -texture.width/2 ;
			textureRect.y = -texture.height/2 ;
			textureRect.width = texture.width ;
			textureRect.height = texture.height ;
		}

		public function addChild(pChild:GDBNode): GDBNode {
			// check if exists.
			if( pChild.parent == this ) {
				removeChild(pChild);
			}
			var index:int = _childs.length ;
//			trace('add child:', pChild.slot.name, index );
			pChild.parent = this ;
			_childs[index] = pChild ;
			hasChildren = true ;
			return pChild ;
		}

		public function addChildAt(pChild:GDBNode, pIndex:int):GDBNode {
//			trace('add child at:', pIndex);
			if( pIndex > numChildren || pIndex < 0){
				trace('ERROR: addChildAt() -', pIndex, 'is out of range.');
				return null ;
			}
			if( pChild.parent == this ) {
				removeChild(pChild);
			}
			pChild.parent = this ;
			_childs.splice(pIndex, 0, pChild);
			hasChildren = true ;
			return pChild ;
		}

		public function removeChild(pChild:GDBNode): GDBNode {
			if( pChild.parent != this ) return null ;
			var index:int = _childs.indexOf(pChild) ;
			if( index == -1 ) {
				trace('ERROR: removeChild() -', pChild, 'is not a child.');
				return null ;
			}
			_childs.splice(index, 1);
			hasChildren = _childs.length > 0 ;
			return pChild ;
		}

		public function removeChildAt(pIndex:int):GDBNode {
			if( pIndex >= numChildren || pIndex < 0) {
				trace('ERROR: removeChildAt() -', pIndex, 'is out of range.');
				return null ;
			}
			var child:GDBNode = _childs[pIndex];
			child.parent = null ;
			_childs.splice(pIndex, 1);
			hasChildren = _childs.length > 0 ;
			return child ;
		}

		public function get numChildren():int {
			return _childs.length ;
		}

		public function getIndex(): int {
			if( !parent ) return -1 ;
			return parent.getChildIndex(this);
		}

		public function getChildIndex(pNode: GDBNode): int {
			return _childs.indexOf(pNode);
		}

		public function getChilds(): Vector.<GDBNode> {
			return _childs ;
		}

		public function getChildAt(pIndex: int): GDBNode {
			return _childs[pIndex];
		}

		public function dispose(): void {
			_childs.length = 0 ;
			_childs = null ;
		}

		public function updateTransform( pMatrix: Matrix, pTransform: DBTransform): void {
			localMatrix = pMatrix ;
			transform = pTransform ;
			localMatrix.tx -= localMatrix.a * pivotX2 + localMatrix.c * pivotY2;
			localMatrix.ty -= localMatrix.b * pivotX2 + localMatrix.d * pivotY2;
			if( parent && parent.localMatrix ){
//				concat( localMatrix, parent.localMatrix);
				localMatrix.concat( parent.localMatrix ) ;
			}
		}

		private function concat(ma: Matrix, mb: Matrix): void {
			ma.a *= mb.a;
			ma.c *= mb.a;
			ma.tx *= mb.a;
			ma.b *= mb.d;
			ma.d *= mb.d;
			ma.ty *= mb.d;

			ma.tx += mb.tx ;
			ma.ty += mb.ty ;
		}

		[Inline]
		public final function inline_updateWorldMatrix(nWorldX: Number, nWorldY: Number, nWorldScaleX: Number, nWorldScaleY: Number, nWorldRotation: Number): void {
			worldMatrix.copyFrom(localMatrix);
			if( nWorldRotation != 0 )
				worldMatrix.rotate( nWorldRotation );

			if( nWorldScaleX != 1 || nWorldScaleY != 1 )
				worldMatrix.scale( nWorldScaleX, nWorldScaleY );
			worldMatrix.translate( nWorldX, nWorldY );
		}

		[Inline]
		public final function inline_updateWorldMatrix2(nWorldX: Number, nWorldY: Number, nWorldScaleX: Number, nWorldScaleY: Number, nWorldRotation: Number): void {
			var wm: Matrix = worldMatrix;
			var lm: Matrix = localMatrix;
			var a1: Number, b1: Number, c1: Number, d1: Number, tx1: Number, ty1: Number;
			var a: Number = a1 = lm.a;
			var b: Number = b1 = lm.b;
			var c: Number = c1 = lm.c;
			var d: Number = d1 = lm.d;
			var tx: Number = tx1 = lm.tx;
			var ty: Number = ty1 = lm.ty;
			if (nWorldRotation != 0) {
				var sin: Number = Math.sin(nWorldRotation);
				var cos: Number = Math.cos(nWorldRotation);
				a = a1 * cos - b1 * sin;
				b = a1 * sin + b1 * cos;
				c = c1 * cos - d1 * sin;
				d = c1 * sin + d1 * cos;
				tx = tx1 * cos - ty1 * sin;
				ty = tx1 * sin + ty1 * cos;
//				a = wm.a * cos - wm.b * sin;
//				b = wm.a * sin + wm.b * cos;
//				c = wm.c * cos - wm.d * sin;
//				d = wm.c * sin + wm.d * cos;
//				tx = wm.tx * cos - wm.ty * sin;
//				ty = wm.tx * sin + wm.ty * cos;
			}
//			if (nWorldScaleX != 1) {
			a *= nWorldScaleX;
			c *= nWorldScaleX;
			tx *= nWorldScaleX;
//			}
//			if (nWorldScaleY != 1) {
			b *= nWorldScaleY;
			d *= nWorldScaleY;
			ty *= nWorldScaleY;
//			}
			tx += nWorldX;
			ty += nWorldY;
			wm.a = a;
			wm.b = b;
			wm.c = c;
			wm.d = d;
			wm.tx = tx;
			wm.ty = ty;
		}
	}
}

/*

wm.a = lm.a ;
wm.b = lm.b ;
wm.c = lm.c;
wm.d = lm.d;
wm.tx = lm.tx;
wm.ty = lm.ty;
if(nWorldRotation != 0 ){
	var sin: Number = Math.sin(nWorldRotation);
	var cos: Number = Math.cos(nWorldRotation);
	wm.a = lm.a*cos - lm.b*sin;
	wm.b = lm.a*sin + lm.b*cos;
	wm.c = lm.c*cos - lm.d*sin;
	wm.d = lm.c*sin + lm.d*cos;
	wm.tx = lm.tx*cos - lm.ty*sin;
	wm.ty = lm.tx*sin + lm.ty*cos;
}
if( nWorldScaleX != 1 ){
	wm.a *= nWorldScaleX ;
	wm.c *= nWorldScaleX ;
	wm.tx *= nWorldScaleX ;
}
if( nWorldScaleY != 1 ){
	wm.b *= nWorldScaleY ;
	wm.d *= nWorldScaleY ;
	wm.ty *= nWorldScaleY ;
}
wm.tx += nWorldX ;
wm.ty += nWorldY ;