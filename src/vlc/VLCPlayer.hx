package vlc;

import cpp.Char;
import cpp.Native;
import cpp.NativeString;
import cpp.Pointer;
import cpp.Reference;
import cpp.UInt8;

/**
 * ...
 * @author Tommy S.
 * 
 */

////// Headers needed ///////////////////////////////////////////////////////////////////
 
@:buildXml('<include name="../../src/vlc/build/VLCBuild.xml" />')
@:headerInclude('vlc/vlc.h')
@:unreflective
class VLCPlayer
{
	// Properties ///////////////////////////////////////////////////////////////////////

	var instance		: LibVLC_Instance_p;
	var media			: LibVLC_Media_p;
	var mediaPlayer		: LibVLC_Media_Player_p;

	public function new()
	{
		instance = newInstance(0, null);
	}	
	
	// Methods /////////////////////////////////////////////////////////////////////////

	public function play(path:String)
	{
		setSource(path);
		mediaPlayerPlay(mediaPlayer);
	}

	public function stop()
	{
		if (mediaPlayer!=null)
			mediaPlayerStop(mediaPlayer);
	}

	function setSource(path:String)
	{
		if (instance==null)
			return;

		if (media!=null)
			mediaRelease(media);	

		media = mediaNewPath(instance,path);
		createPlayer();
	}

	function createPlayer()
	{
		if (media==null)
			return;

		if (mediaPlayer!=null)
			mediaPlayerRelease(mediaPlayer);		

		mediaPlayer = mediaPlayerNewFromMedia(media);
		mediaParse(media);
		mediaRelease(media);
		audioSetVolume(mediaPlayer, 10);
		media = null;
	}

	public function setFullscreen(fullscreen:Bool=true)
	{
		if (mediaPlayer!=null)
			setFullscreenWindow(mediaPlayer,fullscreen);
	}

	public function dispose()
	{
		stop();
		mediaPlayerRelease(mediaPlayer);
		release(instance);

		media = null;
		mediaPlayer = null;
		instance = null;
	}

	// Externs /////////////////////////////////////////////////////////////////////////

	/*
	* Create and initialize a libvlc instance. 
	*/
	@:native("libvlc_new")
	extern private static function newInstance(argc:Int, argv:String):LibVLC_Instance_p;

	/*
	* Create a media for a certain file path.
	*/
	@:native("libvlc_media_new_path")
	extern private static function mediaNewPath(p_instance:LibVLC_Instance_p, path:String):LibVLC_Media_p;

	/*
	* Create a Media Player object from a Media.
	*/
	@:native("libvlc_media_player_new_from_media")
	extern private static function mediaPlayerNewFromMedia(p_md:LibVLC_Media_p):LibVLC_Media_Player_p;

	/*
	* Decrement the reference count of a media descriptor object.
	*/
	@:native("libvlc_media_release")
	extern private static function mediaRelease(p_md:LibVLC_Media_p):Void;
 	
	/*
	* Parse flags used by libvlc_media_parse_with_options()
	*/
	@:native("libvlc_media_parse")
	extern private static function mediaParse(p_md:LibVLC_Media_p):Void;
 	
	/*
	* Play
	*/
	@:native("libvlc_media_player_play")
	extern private static function mediaPlayerPlay(p_mi:LibVLC_Media_Player_p):Void;
 	
	/*
	* Stop
	*/
	@:native("libvlc_media_player_stop")
	extern private static function mediaPlayerStop(p_mi:LibVLC_Media_Player_p):Void;
 	
	/*
	* Release a media_player after use Decrement the reference count of a media player object.
	*/
	@:native("libvlc_media_player_release")
	extern private static function mediaPlayerRelease(p_mi:LibVLC_Media_Player_p):Void;
 	
	/*
	* Decrement the reference count of a libvlc instance, and destroy it if it reaches zero.
	*/
	@:native("libvlc_release")
	extern private static function release(p_instance:LibVLC_Instance_p):Void;
 	
	/*
	* Get current software audio volume.
	*/
	@:native("libvlc_audio_get_volume")
	extern private static function audioGetVolume(p_mi:LibVLC_Media_Player_p):Int;
 	
	/*
	* Set current software audio volume.
	*/
	@:native("libvlc_audio_set_volume")
	extern private static function audioSetVolume(p_mi:LibVLC_Media_Player_p,i_volume:Int):Int;
 	
	/*
	* Set fullscreen (window)
	*/
	@:native("libvlc_set_fullscreen")
	extern private static function setFullscreenWindow(p_mi:LibVLC_Media_Player_p,fullscreen:Bool):Void;
 	
	/////////////////////////////////////////////////////////////////////////////////////	
}

// @:structAccess
@:native("libvlc_instance_t*") 
extern class LibVLC_Instance_p
{
	@:native("libvlc_instance_t*")	
	static public function declare()	: LibVLC_Instance_p;	
}

@:native("libvlc_media_t*") 
extern class LibVLC_Media_p
{
	@:native("libvlc_media_t*")	
	static public function declare()	: LibVLC_Media_p;	
}

@:native("libvlc_media_player_t*") 
extern class LibVLC_Media_Player_p
{
	@:native("libvlc_media_player_t*")	
	static public function declare()	: LibVLC_Media_Player_p;	
}
