package vlc;

import cpp.Char;
import cpp.Function;
import cpp.Int64;
import cpp.Native;
import cpp.NativeString;
import cpp.Pointer;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.Reference;
import cpp.Star;
import cpp.UInt16;
import cpp.UInt32;
import cpp.UInt8;

/**
 * ...
 * @author Tommy S.
 * 
 */

////// Headers needed ///////////////////////////////////////////////////////////////////
 
@:headerInclude('vlc/vlc.h')
@:headerCode('
#include <mutex>
#include <iostream>

typedef struct ctx
{
	unsigned char *pixeldata;
	std::mutex imagemutex;
} t_ctx;

')
@:cppFileCode('

static void *lock(void *data, void **p_pixels)
{
	// t_ctx *ctx = (t_ctx*)data;
	// ctx->imagemutex.lock();
	//*p_pixels = ctx->pixeldata;
	return NULL;
}

static void unlock(void *data, void *id, void *const *p_pixels)
{
	// t_ctx *ctx = (t_ctx *)data;
	// ctx->imagemutex.unlock();
}

static void display(void *opaque, void *picture)
{
}

static unsigned format_setup(void** opaque, char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
{
	struct ctx *callback = reinterpret_cast<struct ctx *>(*opaque);	
	
	unsigned _w = (*width);
	unsigned _h = (*height);
	unsigned _pitch = _w*4;
	unsigned _frame = _w*_h*4;

	std::cout << _w << " x " << _h << std::endl;
	
	(*pitches) = _pitch;
	(*lines) = _h;
	memcpy(chroma, "RV32", 4);
	
	if (callback->pixeldata != 0)
		delete callback->pixeldata;
	callback->pixeldata = new unsigned char[_frame];
	return 1;
}

static void format_cleanup(void *opaque)
{
}
')
@:headerClassCode('
t_ctx ctx;
')
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
		// media = null;

		untyped __cpp__('
			ctx.pixeldata = 0;
			
			libvlc_video_set_callbacks(mediaPlayer, lock, unlock, display, &ctx);			
			libvlc_video_set_format_callbacks(mediaPlayer, format_setup, format_cleanup);
			
			');
		// setFormatCallbacks(mediaPlayer, untyped format_setup, untyped format_cleanup);
		// setCallbacks(mediaPlayer, untyped lock, untyped unlock, untyped display, untyped __cpp__("&ctx"));		
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
	extern public static function newInstance(argc:Int, argv:String):LibVLC_Instance_p;

	/*
	* Create a media for a certain file path.
	*/
	@:native("libvlc_media_new_path")
	extern public static function mediaNewPath(p_instance:LibVLC_Instance_p, path:String):LibVLC_Media_p;

	/*
	* Create a Media Player object from a Media.
	*/
	@:native("libvlc_media_player_new_from_media")
	extern public static function mediaPlayerNewFromMedia(p_md:LibVLC_Media_p):LibVLC_Media_Player_p;

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
	* Play
	*/
	@:native("libvlc_media_player_play")
	extern public static function mediaPlayerPlay(p_mi:LibVLC_Media_Player_p):Void;
 	
	/*
	* Stop
	*/
	@:native("libvlc_media_player_stop")
	extern public static function mediaPlayerStop(p_mi:LibVLC_Media_Player_p):Void;
 	
	/*
	* Release a media_player after use Decrement the reference count of a media player object.
	*/
	@:native("libvlc_media_player_release")
	extern public static function mediaPlayerRelease(p_mi:LibVLC_Media_Player_p):Void;
 	
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
	extern public static function audioGetVolume(p_mi:LibVLC_Media_Player_p):Int;
 	
	/*
	* Set current software audio volume.
	*/
	@:native("libvlc_audio_set_volume")
	extern public static function audioSetVolume(p_mi:LibVLC_Media_Player_p,i_volume:Int):Int;
 	
	/*
	* Set fullscreen (window)
	*/
	@:native("libvlc_set_fullscreen")
	extern public static function setFullscreenWindow(p_mi:LibVLC_Media_Player_p,fullscreen:Bool):Void;
 	
	/*
	* Set decoded video chroma and dimensions.
	* libvlc_video_set_format_callbacks (libvlc_media_player_t *mp, libvlc_video_format_cb setup, libvlc_video_cleanup_cb cleanup)
	*/
	@:native("libvlc_video_set_format_callbacks")
	extern public static function setFormatCallbacks(mp:LibVLC_Media_Player_p,setup:LibVLC_Video_Format_CB,cleanup:LibVLC_Video_Cleanup_CB):Void;
	
 	
	/*
	* Set callbacks and private data to render decoded video to a custom area in memory.
	* libvlc_video_set_callbacks (libvlc_media_player_t *mp, libvlc_video_lock_cb lock, libvlc_video_unlock_cb unlock, libvlc_video_display_cb display, void *opaque)
	*/
	@:native("libvlc_video_set_callbacks")
	extern public static function setCallbacks(mp:LibVLC_Media_Player_p,lock:LibVLC_Video_Lock_CB,unlock:LibVLC_Video_Unlock_CB,display:LibVLC_Video_Display_CB, opaque):Void;
	
	/*
	*/
	@:native("libvlc_media_player_event_manager")
	extern public static function mediaPlayerEventManager(p_mi:LibVLC_Media_Player_p):LibVLC_Event_Manager_p;
	
	/*
	* Register for an event notification
	*/
	@:native("libvlc_event_attach")
	extern public static function eventAttach(p_event_manager:LibVLC_Event_Manager_p,i_event_type:LibVLC_EventType,f_callback:LibVLC_Callback,user_data:VoidStar):Int;

	/*
	* Registers a callback for the LibVLC exit event
	*/
	@:native("libvlc_set_exit_handler")
	extern public static function setExitHandler(p_instance:LibVLC_Instance_p,cb,opaque):Void;

	/*
	* Registers a callback for the LibVLC exit event
	*/
	@:native("libvlc_media_player_get_time")
	extern public static function mediaPlayerGetTime(p_mi:LibVLC_Media_Player_p):Int64;

	/**
	* Get the pixel dimensions of a video.
	*
	* \param p_mi media player
	* \param num number of the video (starting from, and most commonly 0)
	* \param px pointer to get the pixel width [OUT]
	* \param py pointer to get the pixel height [OUT]
	* \return 0 on success, -1 if the specified video does not exist
	*/
	@:native("libvlc_video_get_size")
	extern public static function videoGetSize(p_mi:LibVLC_Media_Player_p, num:UInt,width:UnsignedStar, height:UnsignedStar ):Int;
}

typedef LibVLC_Video_Format_CB = cpp.Callable<(opaque:VoidStarStar, chroma:CharStar,width:UnsignedStar, height:UnsignedStar, pitches:UnsignedStar, lines:UnsignedStar) -> Unsigned>;
typedef LibVLC_Video_Cleanup_CB = cpp.Callable<(opaque:VoidStar) -> Void>;
typedef LibVLC_Video_Lock_CB = cpp.Callable<(data : vlc.VoidStar, p_pixels : vlc.VoidStarStar) -> VoidStar>;
typedef LibVLC_Video_Unlock_CB = cpp.Callable<(data:VoidStar, id:VoidStar, p_pixels:VoidStarConstStar) -> Void>;
typedef LibVLC_Video_Display_CB = cpp.Callable<(opaque : vlc.VoidStar, picture : vlc.VoidStar) -> Void>;
typedef LibVLC_Callback = cpp.Callable<(p_event:cpp.ConstStar<LibVLC_Event>,p_data:VoidStar) -> Void>;
typedef CharStar = cpp.Star<cpp.Char>;
typedef UnsignedCharStar = cpp.Star<cpp.UInt8>;
typedef UnsignedStar = cpp.Star<cpp.UInt32>;
typedef Unsigned = cpp.UInt32;
typedef VoidStar = cpp.Star<cpp.Void>;
typedef VoidStarStar = cpp.Star<cpp.Star<cpp.Void>>;
// typedef VoidStarConstStar = cpp.Star<cpp.Star<cpp.Void>>;
@:native("void *const *") 	extern class VoidStarConstStar {}
//  void( * libvlc_callback_t) (const struct libvlc_event_t *p_event, void *p_data)

// @:structAccess
@:native("VLCPlayer_obj*") 
extern class Self
{
}

@:native("libvlc_instance_t*") 
extern class LibVLC_Instance_p
{
	@:native("libvlc_instance_t*")	
	static public function declare()	: LibVLC_Instance_p;	
}

@:native("t_ctx") 
@:structAccess
extern class Ctx
{
	public var imagemutex:Mutex;
	public var pixeldata:Pointer<UInt8>;
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

@:native("libvlc_event_manager_t*") 
extern class LibVLC_Event_Manager_p
{
}

@:native("libvlc_event_t") 
@:structAccess
extern class LibVLC_Event
{
	public var type			: LibVLC_EventType;	
	public var u			: LibVLC_Event_U;	
}

@:native("std::mutex") 
@:structAccess
extern class Mutex
{
	public function lock() : Void;		
	public function unlock() : Void;		
}

@:native("libvlc_event_t::u") 
@:structAccess
extern class LibVLC_Event_U
{
	public var media_player_position_changed	: LIBVLC_MediaPlayer_PositionChanged;	
	public var media_player_time_changed		: LIBVLC_MediaPlayer_TimeChanged;	
}

@:native("media_player_position_changed") 
@:structAccess
extern class LIBVLC_MediaPlayer_PositionChanged
{
	public var new_position		: Float;		
}

@:native("media_player_time_changed") 
@:structAccess
extern class LIBVLC_MediaPlayer_TimeChanged
{
	public var new_time			: Int64;		
}


@:native("libvlc_event_type_t") 
enum abstract LibVLC_EventType(Int) from Int to Int
{
	var mediaMetaChanged				= 0;
	var mediaSubItemAdded				= 1;
	var mediaDurationChanged			= 2;
	var mediaParsedChanged				= 3;
	var mediaFreed						= 4;
	var mediaStateChanged				= 5;
	var mediaSubItemTreeAdded			= 6;

	var mediaPlayerMediaChanged			= 256;
	var mediaPlayerNothingSpecial		= 257;
	var mediaPlayerOpening				= 258;
	var mediaPlayerBuffering			= 259;
	var mediaPlayerPlaying				= 260;
	var mediaPlayerPaused				= 261;
	var mediaPlayerStopped				= 262;
	var mediaPlayerForward				= 263;
	var mediaPlayerBackward				= 264;
	var mediaPlayerEndReached			= 265;
	var mediaPlayerEncounteredError		= 266;
	var mediaPlayerTimeChanged			= 267;
	var mediaPlayerPositionChanged		= 268;
	var mediaPlayerSeekableChange		= 269;
	var mediaPlayerPausableChanged		= 270;
	var mediaPlayerTitleChanged			= 271;
	var mediaPlayerSnapshotTaken		= 272;
	var mediaPlayerLengthChanged		= 273;
	var mediaPlayerVout					= 274;
	var mediaPlayerScrambledChanged		= 275;
	var mediaPlayerCorked				= 279;
	var mediaPlayerUncorked				= 280;
	var mediaPlayerMuted				= 281;
	var mediaPlayerUnmuted				= 282;
	var mediaPlayerAudioVolume			= 283;

	var mediaListItemAdded				= 512;
	var mediaListWillAddItem			= 513;
	var mediaListItemDeleted			= 514;
	var mediaListWillDeleteItem			= 515;

	var mediaListViewItemAdded			= 768;
	var mediaListViewWillAddItem		= 769;
	var mediaListViewItemDeleted		= 770;
	var mediaListViewWillDeleteItem		= 771;

	var mediaListPlayerPlayed			= 1024;
	var mediaListPlayerNextItemSet		= 1025;
	var mediaListPlayerStopped			= 1026;

	var vlmMediaAdded					= 1536;
	var vlmMediaRemoved					= 1537;
	var vlmMediaChanged					= 1538;
	var vlmMediaInstanceStarted			= 1539;
	var vlmMediaInstanceStopped			= 1540;
	var vlmMediaInstanceStatusInit		= 1541;
	var vlmMediaInstanceStatusOpening	= 1542;
	var vlmMediaInstanceStatusPlaying	= 1543;
	var vlmMediaInstanceStatusPause		= 1544;
	var vlmMediaInstanceStatusEnd		= 1545;
	var vlmMediaInstanceStatusError		= 1546;


}
/////////////////////////////////////////////////////////////////////////////////////
