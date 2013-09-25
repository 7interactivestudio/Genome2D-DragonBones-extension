/**
 * Created by rodrigo on 9/9/13.
 */
package com.rodrigolopezpeker.genome2d.dragonbones {
	import dragonBones.Slot;
	import dragonBones.display.IDisplayBridge;
	import dragonBones.objects.DBTransform;

	import flash.geom.Matrix;

	public class GDBDisplayBridge implements IDisplayBridge {

		private var _display: GDBNode ;
		public var slot: Slot;

		public static var id:int = 0 ;

		public function GDBDisplayBridge() {
			id++ ;
		}

		public function get visible(): Boolean { return _display ? _display.visible : false ;}
		public function set visible(value: Boolean): void { if( _display ) _display.visible = value ;}

		public function get display(): Object {return _display;}
		public function set display(value: Object): void {
			if( _display == value ) return ;
			var index:int = 0 ;
			var parent:GDBNode ;
			if( _display ){
				parent = _display.parent ;
				if( parent ) index = _display.getIndex() ;
				removeDisplay();
			}
			_display = value as GDBNode ;
			_display.slot = slot ;
			addDisplay( parent, index );
		}

		public function dispose(): void {
			_display.dispose() ;
			_display = null ;
		}

		public function updateTransform(matrix: Matrix, transform: DBTransform): void {
			_display.updateTransform(matrix, transform);
		}

		public function updateColor(aOffset: Number, rOffset: Number, gOffset: Number, bOffset: Number, aMultiplier: Number, rMultiplier: Number, gMultiplier: Number, bMultiplier: Number): void {
			_display.alpha = aMultiplier ;
			_display.color = (uint(rMultiplier * 0xff) << 16) + (uint(gMultiplier * 0xff) << 8) + uint(bMultiplier * 0xff);
		}

		public function addDisplay(pContainer: Object, index: int = -1): void {
			var container:GDBNode = pContainer as GDBNode ;
			if( container && _display ){
				_display.nodeLevel = container.nodeLevel + 1 ;
				if(index<0){
					container.addChild(_display);
				} else {
					container.addChildAt(_display, Math.min(index, container.numChildren));
				}
			}
		}

		public function removeDisplay(): void {
			if( _display && _display.parent ){
				_display.parent.removeChild(_display);
				_display.nodeLevel = -1 ;
				_display.parent = null ;
				// always keep a reference to the display!
//				_display = null ;
			}
		}
	}
}
