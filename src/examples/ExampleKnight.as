/**
 * Created by rodrigo on 9/26/13.
 */
package examples {
	import com.genome2d.components.particles.GSimpleEmitter;
	import com.genome2d.components.particles.fields.GForceField;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.rodrigolopezpeker.genome2d.dragonbones.GDBComponent;
	import com.rodrigolopezpeker.genome2d.dragonbones.GDBNode;

	import dragonBones.Bone;
	import dragonBones.events.AnimationEvent;
	import dragonBones.events.FrameEvent;

	import examples.common.BaseScene;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	public class ExampleKnight extends BaseScene {

		private var hero: GDBComponent;
		private var udata: Object ;
		private var emitter: GSimpleEmitter ;

		public function ExampleKnight(pNode:GNode) {
			super(pNode);
			udata = node.userData ;
			_assetPath = 'assets/knight/' ;
			_armatureId = 'knight' ;
			node.core.config.backgroundColor = 0x454545 ;
			init() ;
		}

		override protected function handleArmatureReady(): void {
			udata.moveDir = udata.speedX = udata.speedY = 0 ;
			udata.isJumping = false ;
			udata.floorY = 200 ;
			udata.weaponID = 0 ;
			udata.face = 1 ;
			udata.isAttacking = false ;
			udata.isComboAttack = false ;
			udata.hitCount = 0  ;
			udata.arrows = [] ;

			udata.horseEye = armature.getBone("horseHead").childArmature.getBone("eye");
			udata.arm = armature.getBone("armOutside") ;
			udata.arm.childArmature.addEventListener(AnimationEvent.MOVEMENT_CHANGE, armMovementHandler);
			udata.arm.childArmature.addEventListener(AnimationEvent.COMPLETE, armMovementHandler);
			udata.arm.childArmature.addEventListener(FrameEvent.MOVEMENT_FRAME_EVENT, armFrameEventHandler);

			hero = GNodeFactory.createNodeWithComponent(GDBComponent) as GDBComponent ;
			hero.setArmature(armature);
			hero.node.transform.y = udata.floorY ;
			node.addChild(hero.node);
			armature.animation.gotoAndPlay('stand');

			initEmitter() ;
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
				case Keyboard.C:
					if(!pIsDown) changeWeapon();
					break ;
				case Keyboard.SPACE:
					if(pIsDown) attack();
					break ;
				case Keyboard.W:
				case Keyboard.UP:
					jump() ;
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
				udata.speedX = udata.moveDir > 0 ? 5 : -5 ;
				hero.node.transform.scaleX = udata.moveDir < 0 ? -1 :1 ;
				armature.animation.gotoAndPlay( 'run', 0.1, 0.3 ) ;
			}
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

			if( hero == null ) return ;
			updateMove() ;
			updateArrows() ;

			// update emitter position by world bounds (local bounds concatenated to worldBounds).
			// this calculation needs to be optimized with an invalidation or something.
			var bb:Rectangle =  udata.horseEye.display.processBounds() ;
			emitter.node.transform.setPosition( bb.x + bb.width * 0.5, bb.y + bb.height * 0.5 );
		}

		private function updateMove(): void {
			if( udata.speedX != 0 ){
				hero.node.transform.x += udata.speedX ;
				if( hero.node.transform.x < -_vhw ){
					hero.node.transform.x = -_vhw ;
				} else if( hero.node.transform.x > _vhw ){
					hero.node.transform.x = _vhw ;
				}
			}
			if( udata.speedY != 0 ){
				hero.node.transform.y += udata.speedY ;
				if( hero.node.transform.y > udata.floorY ){
					hero.node.transform.y = udata.floorY ;
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


// ----- WEAPONS ----

		private const SWORD:String = "sword";
		private const PIKE:String = "pike";
		private const AXE:String = "axe";
		private const BOW:String = "bow";
		private const WEAPON_NAMES:Array = [SWORD, PIKE, AXE, BOW];

		private function armMovementHandler(event: AnimationEvent): void {
			if(event.type == AnimationEvent.MOVEMENT_CHANGE ){
				udata.isComboAttack = false ;
			} else if( event.type == AnimationEvent.COMPLETE ){
				if( udata.isComboAttack ) {
					udata.arm.childArmature.animation.gotoAndPlay( "ready_" + WEAPON_NAMES[udata.weaponID]);
				} else {
					udata.isAttacking = false ;
					udata.hitCount = 1 ;
					udata.isComboAttack = false ;
				}
			}
		}

		private function armFrameEventHandler(event: FrameEvent): void {
			if( event.frameLabel == 'ready' ){
				udata.isAttacking = false ;
				udata.isComboAttack = false ;
				udata.hitCount++ ;
			} else if( event.frameLabel == 'fire'){
				var bow:Bone = udata.arm.childArmature.getBone('bow');
				var arrow:Bone = bow.childArmature.getBone('arrow');
				// buffer arrow location.
				if( !udata.arrowPoint )
					udata.arrowPoint = new Point();

				var rot: Number = 0 ;
				if ( hero.node.transform.scaleX > 0) {
					rot = hero.node.transform.rotation + bow.global.rotation;
				} else {
					rot = hero.node.transform.rotation - bow.global.rotation + Math.PI;
				}

				// update global bounds.
				arrow.display.processBounds() ;

				udata.arrowPoint.x = arrow.display.bounds.x - _vhw;
				udata.arrowPoint.y = arrow.display.bounds.y - _vhh;
				createArrow( rot, udata.arrowPoint );
			}
		}


		private function changeWeapon(): void {
			if ( ++udata.weaponID >= WEAPON_NAMES.length) udata.weaponID = 0 ;
			var weaponName:String= WEAPON_NAMES[ udata.weaponID ];
			udata.arm.childArmature.animation.gotoAndPlay( "ready_" + weaponName );
		}

		private function attack(): void {
			if (udata.isAttacking) return;
			udata.isAttacking = true;
			var weaponName: String = WEAPON_NAMES[udata.weaponID];
			var movementName: String = "attack_" + weaponName + "_" + udata.hitCount;
			udata.arm.childArmature.animation.gotoAndPlay( movementName );
		}

		private function createArrow(rotation: Number, position: Point): void {
			var arrowDisplay:GDBNode = factory.getTextureDisplay("knightFolder/arrow_1") as GDBNode ;
			var spr:GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite ;
			spr.setTexture(arrowDisplay.texture);
			arrowDisplay.userData.sprite = spr ;

			// position.
			spr.node.transform.setPosition(position.x, position.y );
			spr.node.transform.rotation = rotation ;
			node.addChild( spr.node );

			udata.arrows.push({ display: arrowDisplay, vx: Math.cos(rotation) * 10, vy: Math.sin(rotation) * 10 });
		}

		private function updateArrows(): void {
			// Use GNodePool in a real project :)
			var len:int = udata.arrows.length ;
			for (var i: int = len-1; i >= 0 ; i--) {
				var arrow: Object = udata.arrows[i];
				var sprite:GSprite = arrow.display.userData.sprite ;
				arrow.vy += 0.1 ;
				sprite.node.transform.x += arrow.vx ;
				sprite.node.transform.y += arrow.vy ;
				sprite.node.transform.rotation = Math.atan2(arrow.vy,arrow.vx) ;
				if( sprite.node.transform.y > _vhh - 50 ){
					udata.arrows.splice(i, 1);
					sprite.node.parent.removeChild(sprite.node);
				}
			}
		}


		private function initEmitter(): void {
			// init emitter.
			var forceField:GForceField = GNodeFactory.createNodeWithComponent(GForceField) as GForceField;
			hero.node.addChild(forceField.node);

			emitter = GNodeFactory.createNodeWithComponent(GSimpleEmitter) as GSimpleEmitter ;
			emitter.emit = true ;
			emitter.emission = 60 ;
			emitter.emissionVariance = 20 ;
			emitter.textureId = 'hitarea_tx' ;
			emitter.initialVelocity = 20 ;
			emitter.initialVelocityVariance = 10 ;
			emitter.initialAngularVelocity = 0 ;
			emitter.initialAngularVelocityVariance = .005 ;
			emitter.energy = 0.7 ;
			emitter.energyVariance = 0.4 ;
			emitter.dispersionAngle = -Math.PI/2 - 0.13 ;
			emitter.dispersionAngleVariance = 0.6 ;
			emitter.initialScale = 0.5 ;
			emitter.initialScaleVariance = 0.2 ;
			emitter.endScale = 0.1 ;
			emitter.endScaleVariance = 0.2 ;
			emitter.initialBlueVariance = 0.4 ;
			emitter.initialAlpha = 0.4 ;
			emitter.initialAlphaVariance = 0.3 ;
			emitter.endAlpha = 0 ;
			emitter.endBlueVariance = 0.4 ;
			emitter.initialColor = 0xFF0000 ;
			emitter.endColor = 0x00FF00 ;
			emitter.blendMode = GBlendMode.ADD ;
			emitter.addField(forceField);
			emitter.node.transform.useWorldSpace = true ;
			hero.node.addChild( emitter.node );
		}

	}
}
