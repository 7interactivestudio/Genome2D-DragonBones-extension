/**
 * Created by rodrigo on 9/25/13.
 */
package examples {
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.rodrigolopezpeker.genome2d.dragonbones.GDBComponent;

	import examples.common.BaseScene;

	public class ExampleBasic extends BaseScene{

		private var dragon: GDBComponent;

		public function ExampleBasic(pNode:GNode) {
			super(pNode);
			_assetPath = 'assets/dragon/' ;
			_armatureId = 'dragon' ;
			init() ;
		}

		override protected function armatureReady(): void {
			dragon = GNodeFactory.createNodeWithComponent(GDBComponent) as GDBComponent ;
			dragon.setArmature(armature);
			node.addChild(dragon.node);
			dragon.node.transform.y = 150 ;
			dragon.armature.animation.gotoAndPlay('walk');

			// mouse detection.
			dragon.useHitArea = true ;
			dragon.setHitAreaTextureId( 'hitarea_tx' );
			dragon.node.mouseEnabled = true ;
			dragon.node.onMouseOver.add( onDragonMouse );
			dragon.node.onMouseOut.add( onDragonMouse );
		}

		private function onDragonMouse(signal:GMouseSignal): void {
			signal.target.transform.red = signal.type == 'mouseOver' ? 3 : 1 ;
		}
	}
}
