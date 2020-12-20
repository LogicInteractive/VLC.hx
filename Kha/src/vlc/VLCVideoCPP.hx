package vlc;

@:headerCode('
#include <Kore/pch.h>
#include "LibVLCVideo.h"
')

@:headerClassCode('Kore::LibVLCVideo* video;')
class VLCVideoCPP extends kha.Video
{
	public function new(?filename:String, ?uniqueFullscreenMode:Bool=false)
	{
		super();
		init();
		if (pipeline==null)
			createPipeline();
		setUniqueFullscreenMode(uniqueFullscreenMode);
		if (filename!=null)
			setSource(filename);
	}
	
	@:functionCode('video = new Kore::LibVLCVideo();')
	private function init() {}

	@:functionCode('video->setSource(filename.c_str());') 
	public function setSource(filename:String): Void {}
	
	@:functionCode('video->play();')
	override public function play(loop: Bool = false): Void	{}
	
	@:functionCode('video->pause();') 
	override public function pause(): Void {}

	@:functionCode('video->stop();')
	override public function stop(): Void {}
	
	@:functionCode('return static_cast<int>(video->duration * 1000.0);')
	override public function getLength(): Int { return 0; } // Miliseconds
	
	@:functionCode('return static_cast<int>(video->position * 1000.0);')
	override public function getCurrentPos(): Int { return 0; } // Miliseconds
	
	override function get_position(): Int { return getCurrentPos(); }
	
	@:functionCode('video->setPosition(value / 1000.0); return value;')
	override function set_position(value:Int): Int { return 0; }
	
	@:functionCode('return video->finished;')
	override public function isFinished(): Bool { return false; }

	@:functionCode('return video->width();')
	override public function width(): Int { return 100; }

	@:functionCode('return video->height();')
	override public function height(): Int { return 100; }

	@:functionCode('delete video; video = nullptr;')
	override public function unload(): Void {}

	@:functionCode('return video->canDraw;')
	function canDraw(): Bool { return false; }

	@:functionCode('video->uniqueFullscreenMode=fullscreenMode;')
	public function setUniqueFullscreenMode(fullscreenMode:Bool=true): Void {}

	public function draw(g2:kha.graphics2.Graphics, ?x:Null<Float>, ?y:Null<Float>, ?w:Null<Float>, ?h:Null<Float>)
	{
		if (!canDraw())
			return;

		// @:privateAccess g2.setPipeline(kha.graphics4.Graphics2.videoPipeline);
		@:privateAccess g2.setPipeline(pipeline);

		var image:kha.Image = @:privateAccess new kha.Image(false);
		@:privateAccess image.format = kha.graphics4.TextureFormat.RGBA32;
		@:privateAccess image.initVideoX(this);

		g2.color = kha.Color.White;
		g2.drawScaledSubImage(image, 0, 0, width(), height(), x, y, w, h);
		@:privateAccess g2.setPipeline(null);
	}

	/////////////////////////////////////////////////////////////////////////////////////

	static var pipeline : kha.graphics4.PipelineState;
	static function createPipeline()
	{
		pipeline = new kha.graphics4.PipelineState();
		var structure = new kha.graphics4.VertexStructure();
		structure.add("vertexPosition", kha.graphics4.VertexData.Float3);
		structure.add("texPosition", kha.graphics4.VertexData.Float2);
		structure.add("vertexColor", kha.graphics4.VertexData.Float4);
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = kha.Shaders.painter_image_vert;
		pipeline.fragmentShader = kha.Shaders.vlcvideo_frag;
		pipeline.blendSource = kha.graphics4.BlendingFactor.BlendOne;
		pipeline.blendDestination = kha.graphics4.BlendingFactor.InverseSourceAlpha;
		pipeline.alphaBlendSource = kha.graphics4.BlendingFactor.BlendOne;
		pipeline.alphaBlendDestination = kha.graphics4.BlendingFactor.InverseSourceAlpha;		 
		pipeline.compile();
	}	
}