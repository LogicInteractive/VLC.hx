package vlc;

import cpp.Star;

@:headerCode('
#include <Kore/pch.h>
#include "LibVLCVideo.h"
')

@:unreflective
@:headerClassCode('Kore::LibVLCVideo* video;')
class VLCVideo extends kha.Video
{
	public var vlcInstance		: LibVLC_Instance_p;
	public var mediaPlayer		: LibVLC_MediaPlayer_p;
	public var media			: LibVLC_Media_p;
	public var audioOutList		: LibVLC_AudioOutput_p;

	public function new(?path:String, ?uniqueFullscreenMode:Bool=false)
	{
		super();
		init();
		// vlcInstance = New(0, null);
		// audioOutList = getAudioOutputList(vlcInstance);
		
		// media = mediaNewPath(vlcInstance,path);		
		// mediaPlayer = mediaPlayerNewFromMedia(media);
		// mediaParse(media);
		// mediaRelease(media);
		
		// setAudioOutput(mediaPlayer,"waveout");
		// audioSetVolume(mediaPlayer, 10);
		
		// mediaPlayerPlay(mediaPlayer);

		// setUniqueFullscreenMode(uniqueFullscreenMode);
		if (path!=null)
			setSource(path);
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

		@:privateAccess g2.setPipeline(kha.graphics4.Graphics2.videoPipeline);

		var image:kha.Image = @:privateAccess new kha.Image(false);
		@:privateAccess image.format = kha.graphics4.TextureFormat.RGBA32;
		@:privateAccess image.initVideoX(this);

		g2.color = kha.Color.White;
		g2.drawScaledSubImage(image, 0, 0, width(), height(), x, y, w, h);
		@:privateAccess g2.setPipeline(null);
	}








	// Externs /////////////////////////////////////////////////////////////////////////

	/*
	* Create and initialize a libvlc instance. 
	*/
	@:native("libvlc_new")
	extern public static function New(argc:Int, argv:String):LibVLC_Instance_p;

	/*
	* Create a media for a certain file path.
	*/
	@:native("libvlc_media_new_path")
	extern public static function mediaNewPath(p_instance:LibVLC_Instance_p, path:String):LibVLC_Media_p;

	/*
	* Create a Media Player object from a Media.
	*/
	@:native("libvlc_media_player_new_from_media")
	extern public static function mediaPlayerNewFromMedia(p_md:LibVLC_Media_p):LibVLC_MediaPlayer_p;

	/*
	* ...
	*/
	@:native("libvlc_audio_output_list_get")
	extern public static function getAudioOutputList(vlcInst:LibVLC_Instance_p):LibVLC_AudioOutput_p;

	/*
	* ...
	*/
	@:native("libvlc_audio_output_set")
	extern public static function setAudioOutput(p_mi:LibVLC_MediaPlayer_p,deviceName:String):Void;
	
	/*
	* Play
	*/
	@:native("libvlc_media_player_play")
	extern public static function mediaPlayerPlay(p_mi:LibVLC_MediaPlayer_p):Void;
 	
	/*
	* Stop
	*/
	@:native("libvlc_media_player_stop")
	extern public static function mediaPlayerStop(p_mi:LibVLC_MediaPlayer_p):Void;
 	
	/*
	* Release a media_player after use Decrement the reference count of a media player object.
	*/
	@:native("libvlc_media_player_release")
	extern public static function mediaPlayerRelease(p_mi:LibVLC_MediaPlayer_p):Void;
 	
	/*
	* Decrement the reference count of a libvlc instance, and destroy it if it reaches zero.
	*/
	@:native("libvlc_release")
	extern public static function release(p_instance:LibVLC_Instance_p):Void;

	/*
	* Increments the reference count of a libvlc instance.
	*/
	@:native("libvlc_retain")
	extern public static function retain(p_instance:LibVLC_Instance_p):Void;

	/*
	* Get current software audio volume.
	*/
	@:native("libvlc_audio_get_volume")
	extern public static function audioGetVolume(p_mi:LibVLC_MediaPlayer_p):Int;
 	
	/*
	* Set current software audio volume.
	*/
	@:native("libvlc_audio_set_volume")
	extern public static function audioSetVolume(p_mi:LibVLC_MediaPlayer_p,i_volume:Int):Int;
 	
	/*
	* Decrement the reference count of a media descriptor object.
	*/
	@:native("libvlc_media_release")
	extern public static function mediaRelease(p_md:LibVLC_Media_p):Void;
 	
	/*
	* Parse flags used by libvlc_media_parse_with_options()
	*/
	@:native("libvlc_media_parse")
	extern public static function mediaParse(p_md:LibVLC_Media_p):Void;
 	
}

typedef LibVLC_Instance_p 						= Star<LibVLC_Instance>;
typedef LibVLC_AudioOutput_p 					= Star<LibVLC_AudioOutput>;
typedef LibVLC_MediaPlayer_p 					= Star<LibVLC_MediaPlayer>;
typedef LibVLC_Media_p 							= Star<LibVLC_Media>;
typedef LibVLC_Eventmanager_p 					= Star<LibVLC_Eventmanager>;

@:native("libvlc_audio_output_t") 				extern class LibVLC_AudioOutput {}
@:native("libvlc_instance_t") 					extern class LibVLC_Instance {}
@:native("libvlc_media_player_t") 				extern class LibVLC_MediaPlayer {}
@:native("libvlc_media_t") 						extern class LibVLC_Media {}
@:native("libvlc_event_manager_t")				extern class LibVLC_Eventmanager {}
