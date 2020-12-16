package vlc;

@:headerCode('
#include <Kore/pch.h>
#include "LibVLCVideo.h"
')

@:headerClassCode('Kore::LibVLCVideo* video;')
class VLCVideo extends kha.Video
{
	public function new(filename: String, ?uniqueFullscreenMode:Bool=false)
	{
		super();
		// setUniqueFullscreenMode(uniqueFullscreenMode);
		init(filename);
	}
	
	@:functionCode('video = new Kore::LibVLCVideo(filename.c_str());')
	private function init(filename: String) {}

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
	
	@:functionCode('video->update(value / 1000.0); return value;')
	override function set_position(value: Int): Int { return 0; }
	
	@:functionCode('return video->finished;')
	override public function isFinished(): Bool { return false; }

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

		@:privateAccess g2.setPipeline(kha.graphics4.Graphics2.videoPipeline);

		var image:kha.Image = @:privateAccess new kha.Image(false);
		@:privateAccess image.format = kha.graphics4.TextureFormat.RGBA32;
		@:privateAccess image.initVideoX(this);

		g2.color = kha.Color.White;
		// g2.drawScaledSubImage(image, 0, 0, width(), height(), x, y, w, h);
		g2.drawScaledSubImage(image, 0, 0, 1920, 1080, x, y, w, h);
		@:privateAccess g2.setPipeline(null);
	}
}
