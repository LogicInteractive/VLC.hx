package vlc;

class LibVLC
{
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

	/*
	* Set decoded video chroma and dimensions.
	* libvlc_video_set_format_callbacks (libvlc_media_player_t *mp, libvlc_video_format_cb setup, libvlc_video_cleanup_cb cleanup)
	*/
	@:native("libvlc_video_set_format_callbacks")
	extern public static function setFormatCallbacks(mp:LibVLC_MediaPlayer_p,setup:LibVLC_Video_Format_CB,cleanup:LibVLC_Video_Cleanup_CB):Void;
	 	
	/*
	* Set callbacks and private data to render decoded video to a custom area in memory.
	* libvlc_video_set_callbacks (libvlc_media_player_t *mp, libvlc_video_lock_cb lock, libvlc_video_unlock_cb unlock, libvlc_video_display_cb display, void *opaque)
	*/
	@:native("libvlc_video_set_callbacks") @:void
	extern public static function setCallbacks(mp:LibVLC_MediaPlayer_p,lock:LibVLC_Video_Lock_CB,unlock:LibVLC_Video_Unlock_CB,display:LibVLC_Video_Display_CB, opaque):Void;

}

typedef LibVLC_Instance_p 						= cpp.Star<LibVLC_Instance>;
typedef LibVLC_AudioOutput_p 					= cpp.Star<LibVLC_AudioOutput>;
typedef LibVLC_MediaPlayer_p 					= cpp.Star<LibVLC_MediaPlayer>;
typedef LibVLC_Media_p 							= cpp.Star<LibVLC_Media>;
typedef LibVLC_Eventmanager_p 					= cpp.Star<LibVLC_Eventmanager>;

@:native("libvlc_audio_output_t") 				extern class LibVLC_AudioOutput {}
@:native("libvlc_instance_t") 					extern class LibVLC_Instance {}
@:native("libvlc_media_player_t") 				extern class LibVLC_MediaPlayer {}
@:native("libvlc_media_t") 						extern class LibVLC_Media {}
@:native("libvlc_event_manager_t")				extern class LibVLC_Eventmanager {}


typedef LibVLC_Video_Format_CB = cpp.Callable<(opaque:VoidStarStar, chroma:CharStar,width:UnsignedStar, height:UnsignedStar, pitches:UnsignedStar, lines:UnsignedStar) -> Unsigned>;
typedef LibVLC_Video_Cleanup_CB = cpp.Callable<(opaque:VoidStar) -> Void>;
typedef LibVLC_Video_Lock_CB = cpp.Callable<(data : vlc.VoidStar, p_pixels : vlc.VoidStarStar) -> VoidStar>;
typedef LibVLC_Video_Unlock_CB = cpp.Callable<(data:VoidStar, id:VoidStar, p_pixels:VoidStarConstStar) -> Void>;
typedef LibVLC_Video_Display_CB = cpp.Callable<(opaque : vlc.VoidStar, picture : vlc.VoidStar) -> Void>;
// typedef LibVLC_Callback = cpp.Callable<(p_event:cpp.ConstStar<LibVLC_Event>,p_data:VoidStar) -> Void>;
typedef CharStar = cpp.Star<cpp.Char>;
typedef UnsignedCharStar = cpp.Star<cpp.UInt8>;
typedef UnsignedStar = cpp.Star<cpp.UInt32>;
typedef Unsigned = cpp.UInt32;
typedef VoidStar = cpp.Star<cpp.Void>;
typedef VoidStarStar = cpp.Star<cpp.Star<cpp.Void>>;
// typedef VoidStarConstStar = cpp.Star<cpp.Star<cpp.Void>>;
@:native("void *const *") 	extern class VoidStarConstStar {}