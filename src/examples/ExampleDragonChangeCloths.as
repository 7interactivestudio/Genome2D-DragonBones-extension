/**
 * Created by rodrigo on 9/25/13.
 */
package examples {
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.rodrigolopezpeker.genome2d.dragonbones.GDBComponent;

	import examples.common.BaseScene;

	import flash.ui.Keyboard;

	public class ExampleDragonChangeCloths extends BaseScene {

		private var dragon: GDBComponent;
		// to lazy to create properties :)
		private var udata: Object ;

		public function ExampleDragonChangeCloths(pNode:GNode) {
			super(pNode);
			udata = node.userData ;
			_assetPath = 'assets/dragon/' ;
			_armatureId = 'dragon' ;
			init() ;
		}

		override protected function handleArmatureReady(): void {

			udata.clothList = ['clothes1','clothes2','clothes3','clothes4'] ;
			udata.clothIndex = 0 ;
			udata.moveDir = udata.speedX = udata.speedY = 0 ;
			udata.isJumping = false ;
			udata.mouseDown = false ;
			udata.floorY = 270 ;

			dragon = GNodeFactory.createNodeWithComponent(GDBComponent) as GDBComponent ;
			dragon.setArmature(armature);

			// mouse detection.
			dragon.useHitArea = true ;
			dragon.setHitAreaTextureId( 'hitarea_tx' );
			dragon.node.mouseEnabled = true ;
			dragon.node.onMouseOver.add( onDragonMouse );
			dragon.node.onMouseOut.add( onDragonMouse );
			dragon.node.transform.y = udata.floorY ;
			node.addChild(dragon.node);

			armature.animation.gotoAndPlay('stand');

			// reference the bones.
			udata.boneHead = armature.getBone('head') ;
			udata.boneEyeL = armature.getBone('eyeL') ;
			udata.boneEyeR = armature.getBone('eyeR') ;
		}

		private function onDragonMouse(signal:GMouseSignal): void {
			signal.target.transform.red = signal.type == 'mouseOver' ? 3 : 1 ;
		}

		override protected function mouseHandler(pIsDown: Boolean): void {
			udata.mouseDown = pIsDown ;
		}

		override protected function keyHandler(pIsDown: Boolean, pCode: uint): void {
			switch( pCode ){
				case Keyboard.A:
				case Keyboard.LEFT:
					udata.isLeft = pIsDown ;
					break ;
				case Keyboard.D:
				case Keyboard.RIGHT:
					udata.isRight = pIsDown ;
					break ;
				case Keyboard.W:
				case Keyboard.UP:
					jump() ;
					break ;
				case Keyboard.C:
					if(!pIsDown) changeCloth();
					return ;
					break ;
			}

			var dir:int = ( udata.isLeft && udata.isRight ) ? udata.moveDir : ( udata.isLeft ? -1 : ( udata.isRight ? 1 : 0 )) ;
			if( dir == udata.moveDir ){
				return ;
			} else {
				udata.moveDir = dir ;
			}
			updateBehaviour() ;
		}

		private function updateBehaviour(): void {
			if( udata.isJumping ) return ;
			if( udata.moveDir == 0 ){
				udata.speedX = 0 ;
				armature.animation.gotoAndPlay( 'stand', 0.2 ) ;
			} else {
				udata.speedX = 6 * udata.moveDir ;
				armature.animation.gotoAndPlay( 'walk', 0.2 ) ;
				dragon.node.transform.scaleX = -udata.moveDir ;
			}
		}

		private function changeCloth(): void {
			udata.clothIndex++ ;
			if( udata.clothIndex >= udata.clothList.length ) udata.clothIndex = 0 ;
			var clothName:String = udata.clothList[udata.clothIndex] ;
			trace(clothName);
			armature.getBone('clothes').display = factory.getTextureDisplay(clothName) ;
		}

		private function jump(): void {
			if( udata.isJumping ) return ;
			udata.speedY = -16 ;
			udata.isJumping = true ;
			armature.animation.gotoAndPlay('jump');
		}

		override public function update(p_deltaTime: Number, p_parentTransformUpdate: Boolean, p_parentColorUpdate: Boolean): void {
			// dont comment the super.update().
			super.update(p_deltaTime, p_parentTransformUpdate, p_parentColorUpdate);

			if( dragon == null ) return ;
			updateMove() ;
			moveHeadAndEyes() ;
		}

		private function moveHeadAndEyes(): void {
			var headRot:Number = 0 ;

			// head pivot (in global armature space) used as the center point for rotation.
			var dragonHeadY: Number = dragon.node.transform.y + udata.boneHead.global.y ;
			var dragonHeadX: Number = dragon.node.transform.x + udata.boneHead.global.x ;

			var dx: Number = node.core.stage.mouseX - _vhw - dragonHeadX ;
			var dy: Number = node.core.stage.mouseY - _vhh - dragonHeadY ;
			var ang: Number = Math.atan2( dy, dx * dragon.node.transform.scaleX );
			if( udata.mouseDown ){
				headRot = Math.PI + ang ;
				if( headRot > Math.PI ) headRot -= Math.PI * 2 ;
				// reduce the movement
				headRot *= 0.4 ;
			}
			// move eyes.
			var eyeX:Number = Math.cos(ang) * 5 ;
			var eyeY:Number = Math.sin(ang) * 5 ;

			// Watch out, bone.node represents DBTransform, not a GNode!
			// Always modify the properties of DBTransform if u want to override
			// the animation of a specific bone.
			udata.boneEyeL.node.x += ( eyeX - udata.boneEyeL.node.x ) / 4 ;
			udata.boneEyeL.node.y += ( eyeY - udata.boneEyeL.node.y ) / 4 ;
			udata.boneEyeR.node.x = udata.boneEyeL.node.x ;
			udata.boneEyeR.node.y = udata.boneEyeL.node.y ;

			udata.boneHead.node.rotation += ( headRot - udata.boneHead.node.rotation ) / 9 ;
		}

		private function updateMove(): void {
			if( udata.speedX != 0 ){
				dragon.node.transform.x += udata.speedX ;
				if( dragon.node.transform.x < -_vhw ){
					dragon.node.transform.x = -_vhw ;
				} else if( dragon.node.transform.x > _vhw ){
					dragon.node.transform.x = _vhw ;
				}
			}
			if( udata.speedY != 0 ){
				dragon.node.transform.y += udata.speedY ;
				if( dragon.node.transform.y > udata.floorY ){
					dragon.node.transform.y = udata.floorY ;
					udata.isJumping = false ;
					udata.speedY = 0 ;
					updateBehaviour();
				}
			}
			if( udata.isJumping ){
				if( udata.speedY <= 0 && udata.speedY + 1 > 0 ){
					armature.animation.gotoAndPlay('fall', 0.3, 0.3 ) ;
				}
				udata.speedY += 0.6 ;
			}
		}

	}
}
