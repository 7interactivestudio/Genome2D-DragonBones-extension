package examples.common {
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.core.Genome2D;

	import examples.*;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;

	[SWF(width="800", height="600", backgroundColor="#121212", frameRate="60")]
	public class Examples extends Sprite {


		public function Examples() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage(event: Event): void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			stage.showDefaultContextMenu = false;

			var config:GConfig = new GConfig(new Rectangle(0,0,800,600));
			config.enableStats = true ;
			config.useFastMem = true ;
			Genome2D.getInstance().onInitialized.addOnce(onGenomeInitialized);
			Genome2D.getInstance().init(stage, config);
		}

		private function onGenomeInitialized(): void {
			// build the demo.
			var demoClass:Class = ExampleDragonChangeCloths ;
//			var demoClass:Class = ExampleAnimation ;
//			var demoClass:Class = ExampleCybor ;
//			var demoClass:Class = ExampleKnight ;
//			var demoClass:Class = ExampleStressTest ;
			Genome2D.getInstance().root.addChild(GNodeFactory.createNodeWithComponent(demoClass).node);
		}

	}
}
