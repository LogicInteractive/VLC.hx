package vlc;

import cpp.Function;
import cpp.Star;
import vlc.LibVLC;

@:headerCode('
#include <Kore/pch.h>
#include "LibVLCVideo.h"
#include <iostream>
')

@:unreflective
@:headerClassCode('Kore::LibVLCVideo* video;')
@:cppNamespaceCode('

void *clockStatic(void *data, void **p_pixels)
{
	// return ((vlc::VLCVideo_obj *)data)->lock(p_pixels);
	// ((VLCVideo_obj *)data)->lock(p_pixels);

	// std::cout << ((VLCVideo_obj *)data) << std::endl;

	// ((VLCVideo_obj *)data)->fish();

	return NULL;
}

void cunlockStatic(void *data, void *id, void *const *p_pixels)
{
    // ((VLCVideo_obj *)data)->unlock(id, p_pixels);
}

void cdisplayStatic(void *data, void *picture)
{
	// ((VLCVideo_obj *)data)->display(picture);
}

')
class VLCVideo extends kha.Video
{
	public var vlcInstance		: LibVLC_Instance_p;
	public var mediaPlayer		: LibVLC_MediaPlayer_p;
	public var media			: LibVLC_Media_p;
	public var audioOutList		: LibVLC_AudioOutput_p;

	public function new(?path:String, ?uniqueFullscreenMode:Bool=false)
	{
		super();
		// init();
		vlcInstance = LibVLC.New(0, null);
		audioOutList = LibVLC.getAudioOutputList(vlcInstance);
		
		// setUniqueFullscreenMode(uniqueFullscreenMode);
		if (path!=null)
			setSource(path);

		 LibVLC.mediaPlayerPlay(mediaPlayer);
	}
	
	function setSource(path:String)
	{
		media = LibVLC.mediaNewPath(vlcInstance,path);		
		mediaPlayer = LibVLC.mediaPlayerNewFromMedia(media);
		LibVLC.mediaParse(media);
		LibVLC.mediaRelease(media);
		
		LibVLC.setAudioOutput(mediaPlayer,"waveout");
		LibVLC.audioSetVolume(mediaPlayer, 10);

		// setupCallbacks();
		// untyped __cpp__(' std::cout << this << std::endl ');
		// untyped __cpp__(' 
			// ((VLCVideo_obj *)this)->fish();
		//  ');

		// LibVLC.setCallbacks(mediaPlayer, Function.fromStaticFunction(staticLock), Function.fromStaticFunction(staticUnlock), Function.fromStaticFunction(staticDisplay), untyped __cpp__('this'));		
		// LibVLC.setCallbacks(mediaPlayer, cpp.Callable.fromStaticFunction(staticLock), cpp.Callable.fromStaticFunction(staticUnlock), cpp.Callable.fromStaticFunction(staticDisplay), untyped __cpp__('this'));		
		// LibVLC.setCallbacks(mediaPlayer, cpp.Callable.fromStaticFunction(staticLock), cpp.Callable.fromStaticFunction(staticUnlock), cpp.Callable.fromStaticFunction(staticDisplay), untyped __cpp__('this'));		
		// LibVLC.setCallbacks(mediaPlayer, untyped __cpp__('staticLock'), untyped __cpp__('staticUnlock'), untyped __cpp__('staticDisplay'), untyped __cpp__('this'));		
		// LibVLC.setCallbacks(mediaPlayer, untyped __cpp__('clockStatic'), untyped __cpp__('cunlockStatic'), untyped __cpp__('cdisplayStatic'), untyped __cpp__('&this'));		
		// untyped __cpp__('libvlc_video_set_callbacks(mediaPlayer, clockStatic, cunlockStatic, cdisplayStatic, this)');

		var stll:LibVLC_Video_Lock_CB = cpp.Callable.fromStaticFunction(staticLock);
		untyped __cpp__('
			//helloq....
		');
	}

	@:functionCode('libvlc_video_set_callbacks(mediaPlayer, clockStatic, cunlockStatic, cdisplayStatic, this);') 
	public function setupCallbacks(): Void {}

	override public function play(loop:Bool=false)
	{
		LibVLC.mediaPlayerPlay(mediaPlayer);
	}

	@:functionCode('video = new Kore::LibVLCVideo();')
	private function init() {}

	// @:functionCode('video->setSource(filename.c_str());') 
	// public function setSource(filename:String): Void {}

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

		@:privateAccess g2.setPipeline(kha.graphics4.Graphics2.videoPipeline);

		var image:kha.Image = @:privateAccess new kha.Image(false);
		@:privateAccess image.format = kha.graphics4.TextureFormat.RGBA32;
		@:privateAccess image.initVideoX(this);

		g2.color = kha.Color.White;
		g2.drawScaledSubImage(image, 0, 0, width(), height(), x, y, w, h);
		@:privateAccess g2.setPipeline(null);
	}

	public function fish()
	{
		untyped __cpp__(' std::cout << "booooo" << std::endl ');
	}

	// Setup functions ////////////////////////////////////////////////////////////////////////

	public function lock(p_pixels:VoidStarStar):VoidStar
	{
		// *p_pixels = pixels;
		return null;
	}

	@:void 
	public function unlock(id:VoidStar, p_pixels:VoidStarConstStar):Void
	{
		// needsUpdate = true;
	}

	@:void 
	static public function display(id:VoidStar):Void
	{
	}
	
	// Static callbacks ////////////////////////////////////////////////////////////////

	@:void 
	static public function staticLock(data:VoidStar, p_pixels:VoidStarStar):VoidStar
	{
		// untyped __cpp__('((VLCVideo_obj *)data)->lock(p_pixels)');
		// fromVoidStar(data).lock(p_pixels);
		return null;
	}

	@:void 
	static public function staticUnlock(data:VoidStar, id:VoidStar, p_pixels:VoidStarConstStar):Void
	{
		// untyped __cpp__('((VLCVideo_obj *)data)->unlock(id, p_pixels)');
		// fromVoidStar(data).unlock(id, p_pixels);
	}

	@:void 
	static public function staticDisplay(data:VoidStar, picture:VoidStar):Void
	{
	}
	
	static public function staticFormatSetup(data:VoidStarStar, chroma:CharStar, _width:UnsignedStar, _height:UnsignedStar, pitches:UnsignedStar, lines:UnsignedStar):Unsigned
	{
		return cast 1;		
	}

	static public function staticFormatCleanup(data:VoidStar)
	{
	}

	static function fromVoidStar(ptr:VoidStar):VLCVideo
	{
		// return untyped __cpp__('reinterpret_cast<VLCVideo_obj*>( ptr )');
		return untyped __cpp__('((VLCVideo_obj *)ptr)');
	}	

}
