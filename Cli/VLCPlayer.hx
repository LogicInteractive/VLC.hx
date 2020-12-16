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
import haxe.rtti.Meta;

/**
 * ...
 * @author Tommy S.
 * 
 */

////// Headers needed ///////////////////////////////////////////////////////////////////
 
@:buildXml('<include name="../../src/vlc/build/VLCBuild.xml" />')
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
@:unreflective
class VLCPlayer
{
	// Properties ///////////////////////////////////////////////////////////////////////

	static public var i		: VLCPlayer;
	var instance			: LibVLC_Instance_p;
	var media				: LibVLC_Media_p;
	var mediaPlayer			: LibVLC_Media_Player_p;
	// public static var formatCB			: LibVLC_Video_Display_CB;

	public var source		: String;
	public var isPlaying	: Bool;
	public var windowed		: Bool;
	public var dingDong		: Bool;
	public var ding			: Float			= 23;

	public var width		: Int			= 0;
	public var height		: Int			= 0;
	public var position		: Float			= 0;
	public var currentTime	: Int			= 0;
	// public var pixelData	: Pointer<UInt8>;

	public function new(?source:String)
	{
		position = 1.0;
		// fishy();
		// var tjo:()->Void = fishy;
		// tjo();

		// untyped __cpp__('
		// 	void (VLCPlayer_obj::*ff)() = &VLCPlayer_obj::fishy;

		// 	(this->*ff)();
		// ');

		// return;
		i = this;
		instance = newInstance(0, null);
		dingDong = false;
		if (source!=null)
			play(source);
	}	

	function fishy()
	{
		untyped __cpp__('std::cout << "fish fish fish" << std::endl');	
		// untyped __cpp__('
		
		//     libvlc_event_attach( eventManager, libvlc_MediaPlayerPlaying, VLCPlayer_obj::&eventCallbacks, this );			
		
		// ');

	}

	function loop()
	{
		while (true)
		{
			Sys.sleep(0.1);
			update();
			// trace(position);
			trace(width,height);
			// print(Std.string(position));
			// untyped __cpp__('std::cout << position << std::endl');	
		}
	}

	function update()
	{
		var _w:UInt32 = 0;
		var _h:UInt32 = 0;
		videoGetSize(mediaPlayer,0,Native.addressOf(_w),Native.addressOf(_h));
		width = _w;
		height = _h;
	}

	// Methods /////////////////////////////////////////////////////////////////////////

 	public function play(source:String)
	{
		setSource(source);
		mediaPlayerPlay(mediaPlayer);
		loop();		
	}

	public function stop()
	{
		if (mediaPlayer!=null)
			mediaPlayerStop(mediaPlayer);
	}

	inline function setSource(source:String)
	{
		if (source!=null)
			this.source = source;

		if (instance==null)
			return;

		if (media!=null)
			mediaRelease(media);	

		if (mediaPlayer!=null)
			mediaPlayerRelease(mediaPlayer);		

		media = mediaNewPath(instance,this.source);
		mediaPlayer = mediaPlayerNewFromMedia(media);
		mediaParse(media);
		mediaRelease(media);


		// formatCB = Function.fromStaticFunction(VLCPlayer.displayX);

		createCtx();
		// setFormatCallbacks(mediaPlayer, Function.fromStaticFunction(formatSetup), Function.fromStaticFunction(formatCleanup));
		// setFormatCallbacks(mediaPlayer, untyped format_setup, Function.fromStaticFunction(formatCleanup));
		// setCallbacks(mediaPlayer, untyped lock, untyped unlock, untyped display, untyped __cpp__("&ctx"));
		setCallbacks(mediaPlayer, Function.fromStaticFunction(lock), Function.fromStaticFunction(unlock), Function.fromStaticFunction(display), untyped __cpp__("&ctx"));
		// setCallbacks(mediaPlayer, Function.fromStaticFunction(lock), Function.fromStaticFunction(unlock), Function.fromStaticFunction(display), Native.addressOf(this));

		// untyped __cpp__('
		
		// libvlc_video_set_callbacks(mediaPlayer,lock,unlock,displayX,&ctx);
		
		// ');

		// var eventManager:LibVLC_Event_Manager_p = mediaPlayerEventManager(mediaPlayer);
		// setupEvents(eventManager);

		// mediaPlayerPlay(mediaPlayer);
		// Sys.sleep(10);

		// audioSetVolume(mediaPlayer, 10);
		// media = null;
	}

	public function pling()
	{
		// trace("PLING!");
	}

	public function setFullscreen(fullscreen:Bool=true)
	{
		if (mediaPlayer!=null && windowed)
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

	function setupEvents(eventManager:LibVLC_Event_Manager_p)
	{
		// var l:VoidStar = untyped __cpp__('this');
		var l = untyped __cpp__('this');
		var cb:LibVLC_Callback = Function.fromStaticFunction(eventCallbacks);

		// untyped __cpp__('std::cout << "a: " << l << std::endl');

 //		eventAttach( eventManager, LibVLC_EventType.mediaPlayerTimeChanged, cb, l);
		// eventAttach( eventManager, LibVLC_EventType.mediaPlayerPlaying, cb, l);
/*		eventAttach( eventManager, LibVLC_EventType.mediaPlayerPaused, cb, l);
		eventAttach( eventManager, LibVLC_EventType.mediaPlayerStopped, cb, l);
		eventAttach( eventManager, LibVLC_EventType.mediaPlayerEndReached, cb, l);
		eventAttach( eventManager, LibVLC_EventType.mediaPlayerPositionChanged, cb, l);
		eventAttach( eventManager, LibVLC_EventType.mediaPlayerLengthChanged, cb, l);
		eventAttach( eventManager, LibVLC_EventType.mediaPlayerEncounteredError, cb, l);
		eventAttach( eventManager, LibVLC_EventType.mediaPlayerPausableChanged, cb, l);
		eventAttach( eventManager, LibVLC_EventType.mediaPlayerSeekableChange, cb, l); */
	
	}

/*
			void (VLCPlayer_obj::*cbb)(const struct libvlc_event_t *,void*) = &VLCPlayer_obj::eventCallbacksX;
			// libvlc_callback_t cbb = &VLCPlayer_obj::eventCallbacksX;
			// (this->*cbb)(nullptr,nullptr);

			libvlc_event_attach( eventManager, libvlc_MediaPlayerPlaying, cbb, this);
		');	
*/

	static public function lock(data:VoidStar, p_pixels:VoidStarStar):VoidStar
	{
		// var ctx:Pointer<Ctx> = cast data;
		// ctx.value.imagemutex.lock();
		// untyped __cpp__('*p_pixels = ctx->get_value().pixeldata');
/* 		untyped __cpp__('
			t_ctx *ctx = (t_ctx*)data;
			ctx->imagemutex.lock();
			*p_pixels = ctx->pixeldata;
		'); */
		return null;
	}

	static public function unlock(data:VoidStar, id:VoidStar, p_pixels:VoidStarConstStar)
	{
/* 		untyped __cpp__('
			t_ctx *ctx = (t_ctx *)data;
			ctx->imagemutex.unlock();
		');	 */	
		// var ctx:cpp.Star<Ctx> = cast data;
		// var ctx:Pointer<Ctx> = cast data;
		// ctx.value.imagemutex.unlock();

	}

	static public function formatSetup(opaque:VoidStarStar, chroma:CharStar, _width:UnsignedStar, _height:UnsignedStar, pitches:UnsignedStar, lines:UnsignedStar):Unsigned
	{
		var width:Int = Pointer.fromStar(_width).value;
		var height:Int = Pointer.fromStar(_height).value;
		// VLCPlayer.i.width = width;
		// VLCPlayer.i.height = height;
		var pitch:UInt = width*4;
		var frame:UInt = width*height*4;
		// Pointer.fromStar(pitches).setAt(0,pitch);

		// var vlcp:Pointer<VLCPlayer> = Pointer.fromStar(opaque).value;
		// var v:VLCPlayer = cast vlcp;
		// v.ding = Math.random();
		
		untyped __cpp__('		
			struct ctx *callback = reinterpret_cast<struct ctx *>(*opaque);	
			
			// unsigned _pitch = width*4;
			// unsigned _frame = width*height*4;
			
			(*pitches) = pitch;
			(*lines) = height;
			memcpy(chroma, "RV32", 4);
			
			if (callback->pixeldata != 0)
				delete callback->pixeldata;

			std::cout << width << " x " << height << std::endl;		
			// std::cout << vlcp << std::endl;		
				
			callback->pixeldata = new unsigned char[frame];
		');
		return cast 1;		
	}

	static public function formatCleanup(opaque:VoidStar)
	{
	}

	static public function display(opaque:VoidStar, picture:VoidStar)
	{
		// var vlcp:VLCPlayer = untyped __cpp__('reinterpret_cast<VLCPlayer_obj*>( opaque )');
		var vlcp:VLCPlayer = fromVoidStar(opaque);
		vlcp.fishy();
		// var self:VLCPlayer = cast opaque;
		//t_ctx *ctx = (t_ctx *)data;
		//self->flags[15]=1;
		
		// var what=Pointer.fromPointer(untyped __cpp__('opaque'));

/* 		untyped __cpp__('
			// VLCPlayer_obj* self = reinterpret_cast<VLCPlayer_obj*>( opaque );
			// std::cout << "ok then... " << std::endl;
			// std::cout << self << std::endl;
			std::cout << opaque << std::endl;
			// self->ss();
		
		'); */
		// dingDong = true;
		// trace("Helloo..???");
		// i.dingDong = true;

	}	
	
	function eventCallbacksX(eventPtr:cpp.ConstStar<LibVLC_Event>,userDataPtr:VoidStar)
	{
		untyped __cpp__('std::cout << "hepp" << std::endl');	
	}
	
//yourDataType *yourData = (yourDataType*) userDataPointer; /

	static public function eventCallbacks(eventPtr:cpp.ConstStar<LibVLC_Event>,userDataPtr:VoidStar)
	{
		return;

		var vlcp:VLCPlayer = fromVoidStar(userDataPtr);

		// var vl:cpp.Pointer<VLCPlayer> = untyped __cpp__('reinterpret_cast<VLCPlayer_obj*>( userDataPtr )');		
		// var vlcp:VLCPlayer = cast Pointer.fromStar(userDataPtr).value;	
		// var vlcp:VLCPlayer = untyped __cpp__('reinterpret_cast<VLCPlayer_obj*>( userDataPtr )');
		// var vv1:Self = untyped __cpp__('reinterpret_cast<VLCPlayer_obj*>( userDataPtr )');		
		// var vl:cpp.Pointer<VLCPlayer> = cast vv1;	
		// var vlcp:VLCPlayer = cast vv1;
		// var vlcp:VLCPlayer = vl.value;
		// vlcp.ding = Math.random();
		// var vlcp:VLCPlayer = i;
		// var vlcp:VLCPlayer = cast userDataPtr;	
		// var rr = Math.random();
/* 		untyped __cpp__('
		// 	VLCPlayer_obj* slf = reinterpret_cast<VLCPlayer_obj*>( userDataPtr );
		// 	std::cout << slf->ding << std::endl;
			// std::cout << vl->get_value()->ding << std::endl;
			// std::cout << vlcp->ding << std::endl;
		
		'); */
		// untyped __cpp__('std::cout << vl->get_value()->ding << std::endl');
		// untyped __cpp__('vl->get_value()->ding = 10.0');
		// untyped __cpp__('vl->get_value()->ding = 10.0');

		// var vvv:VLCPlayer = cast Pointer.fromStar(vl).value;
		// vvv.fishy();

		var event:LibVLC_Event = cast eventPtr;

		// var time:Int = 0;
		// var pos:Float = 0;


		switch ( event.type )
		{
			case LibVLC_EventType.mediaPlayerPlaying:
			{
				print("Playing!!");
			}
			case LibVLC_EventType.mediaPlayerPaused:
			{
			}
			case LibVLC_EventType.mediaPlayerStopped:
			{
			}
			case LibVLC_EventType.mediaPlayerEndReached:
			{
			}
			case LibVLC_EventType.mediaPlayerTimeChanged:
			{
				// time = VLCPlayer.mediaPlayerGetTime(vlcp.mediaPlayer);
				vlcp.currentTime = event.u.media_player_time_changed.new_time;
			}
			case LibVLC_EventType.mediaPlayerPositionChanged:
			{
				vlcp.position = event.u.media_player_position_changed.new_position;
			}
			case LibVLC_EventType.mediaPlayerLengthChanged:
			{
			// self->flags[7]=event->u.media_player_length_changed.new_length;				
			}
			case LibVLC_EventType.mediaPlayerEncounteredError:
			{
			}
			case LibVLC_EventType.mediaPlayerSeekableChange:
			{
			}
			case LibVLC_EventType.mediaPlayerPausableChanged:
			{
			}
			case LibVLC_EventType.mediaPlayerTitleChanged:
			{
			}
			case LibVLC_EventType.mediaPlayerNothingSpecial:
			{
			}
			case LibVLC_EventType.mediaPlayerOpening:
			{
			}
			case LibVLC_EventType.mediaPlayerBuffering:
			{
			}
			case LibVLC_EventType.mediaPlayerForward:
			{
			}
			case LibVLC_EventType.mediaPlayerBackward:
			{
			}
			default:
		}		

		// vlcp.currentTime = time;

		// untyped __cpp__('std::cout << vlcp->position << std::endl');			
	}

	// Inject code //////////////////////////////////////////////////////////////////////

	static public function unsignedCharToInt(value:UnsignedStar):Int
	{
		return untyped __cpp__('(*value)');
	}

	inline function createCtx()
	{
		untyped __cpp__('
			t_ctx ctx;
			ctx.pixeldata = 0;
		');
	}

	static function fromVoidStar(ptr:VoidStar):VLCPlayer
	{
		return untyped __cpp__('reinterpret_cast<VLCPlayer_obj*>( ptr )');
	}

	static public function Play(source:String):VLCPlayer
	{
		return new VLCPlayer(source);
	}
	
	static public function print(input:String)
	{
		untyped __cpp__('std::cout << input << std::endl');		
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

	/////////////////////////////////////////////////////////////////////////////////////	
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

/*

#include <mutex>
#include <iostream>
#include <string>
#include <StdInt.h>
#include <windows.h> 

using std::string;
using namespace std;

/////////////////////////////////////////////////////////////////////////////////////

LibVLC::LibVLC(void)
{
	char const *Args[] =
	{
		//"--aout", "amem",
		"--drop-late-frames",
		"--ignore-config",
		"--intf", "dummy",
		"--no-disable-screensaver",
		"--no-snapshot-preview",
		"--no-stats",
		"--no-video-title-show",
		"--text-renderer", "dummy",
		"--quiet",
		//"--no-xlib", //no xlib if linux
		//"--vout", "vmem"
		//"--avcodec-hw=dxva2",
		//"--verbose=2"
	};	
	
	int Argc = sizeof(Args) / sizeof(*Args);
	libVlcInstance = libvlc_new(Argc, Args);
	//libVlcInstance = libvlc_new(0, NULL);
	
}
//#if PLATFORM_LINUX
//"--no-xlib",
//#endif
//#if DEBUG
//"--verbose=2",
//#else
//#endif

LibVLC::~LibVLC(void)
{ 
    libvlc_event_detach( eventManager, libvlc_MediaPlayerSnapshotTaken, 	callbacks, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerTimeChanged, 		callbacks, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerPlaying, 			callbacks, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerPaused, 			callbacks, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerStopped, 			callbacks, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerEndReached, 		callbacks, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerPositionChanged,	callbacks, this );
    //stop();
    libvlc_media_player_release( libVlcMediaPlayer );	
	libvlc_release( libVlcInstance );
	
	delete libVlcInstance;
	delete libVlcMediaItem;
	delete libVlcMediaPlayer;
	
	delete ctx.pixeldata;
}

LibVLC* LibVLC::create()
{
    return new LibVLC;
}

/////////////////////////////////////////////////////////////////////////////////////

static void *lock(void *data, void **p_pixels)
{
	t_ctx *ctx = (t_ctx*)data;
	ctx->imagemutex.lock();
	if (ctx->bufferFlip)
		*p_pixels = ctx->pixeldata;
	else
		*p_pixels = ctx->pixeldata2;
	ctx->bufferFlip = !(ctx->bufferFlip);
	return NULL;
}

static void unlock(void *data, void *id, void *const *p_pixels)
{
	t_ctx *ctx = (t_ctx *)data;
	ctx->imagemutex.unlock();
}

static void display(void *opaque, void *picture)
{
	//t_ctx *ctx = (t_ctx *)data;
	//self->flags[15]=1;
	//std::cout << "display " << self << std::endl;
}

static unsigned format_setup(void** opaque, char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
{
    //LibVLC* self = reinterpret_cast<LibVLC*>( opaque );
	struct ctx *callback = reinterpret_cast<struct ctx *>(*opaque);	
	
	unsigned _w = (*width);
	unsigned _h = (*height);
	unsigned _pitch = _w*4;
	unsigned _frame = _w*_h*4;
	
	(*pitches) = _pitch;
	(*lines) = _h;
	memcpy(chroma, "RV32", 4);
	
	if (callback->pixeldata != 0)
		delete callback->pixeldata;
	if (callback->pixeldata2 != 0)
		delete callback->pixeldata2;
		
	callback->pixeldata = new unsigned char[_frame];
	callback->pixeldata2 = new unsigned char[_frame];
	return 1;
}

static void format_cleanup(void *opaque)
{
}

/////////////////////////////////////////////////////////////////////////////////////

uint8_t* LibVLC::getPixelData()
{
	//return pixels;
	if (ctx.bufferFlip)
		return ctx.pixeldata2;
	else
		return ctx.pixeldata;
}

void LibVLC::setPath(const char* path)
{
	//std::cout << "set location: " << path << std::endl;
	//libVlcMediaItem = libvlc_media_new_path(libVlcInstance, path);
	libVlcMediaItem = libvlc_media_new_location(libVlcInstance, path);
	//libVlcMediaItem = libvlc_media_new_location(libVlcInstance, "file:///C:\\Program Files (x86)\\Xms Client 3\\resources\\downloaded\\files\\ac079337-dbd1-11e6-a59e-f681aa9a2e27.mp4");
	libVlcMediaPlayer = libvlc_media_player_new_from_media(libVlcMediaItem);
	libvlc_media_parse(libVlcMediaItem);
	libvlc_media_release(libVlcMediaItem);
	useHWacceleration(true);
	if (libVlcMediaItem!=nullptr)
	{
		std::string sa = "input-repeat=";
		sa += std::to_string(repeat);
		libvlc_media_add_option(libVlcMediaItem, sa.c_str() );	
		//if (repeat==-1)
			//libvlc_media_add_option(libVlcMediaItem, "input-repeat=-1" );	
		//else if (repeat==0)
			//libvlc_media_add_option(libVlcMediaItem, "input-repeat=0" );	
		//std::cout << "Num repeats: " << sa << std::endl;
	}
}

void LibVLC::play()
{
	libvlc_media_player_play(libVlcMediaPlayer);
}

void LibVLC::play(const char* path)
{
	setPath(path);
	ctx.pixeldata = 0;
	ctx.pixeldata2 = 0;
		
	libvlc_video_set_format_callbacks(libVlcMediaPlayer, format_setup, format_cleanup);
	libvlc_video_set_callbacks(libVlcMediaPlayer, lock, unlock, display, &ctx);
	eventManager = libvlc_media_player_event_manager( libVlcMediaPlayer );
	registerEvents();
	libvlc_media_player_play(libVlcMediaPlayer);
	libvlc_audio_set_volume(libVlcMediaPlayer, 0);
}

void LibVLC::playInWindow()
{
	//libvlc_video_set_format_callbacks(libVlcMediaPlayer, format_setup, format_cleanup);
	ctx.pixeldata = 0;
	ctx.pixeldata2 = 0;
	eventManager = libvlc_media_player_event_manager( libVlcMediaPlayer );
	registerEvents();
	libvlc_media_player_play(libVlcMediaPlayer);
	//libvlc_audio_set_volume(libVlcMediaPlayer, 0);
}

void LibVLC::playInWindow(const char* path)
{
	setPath(path);
	ctx.pixeldata = 0;
	ctx.pixeldata2 = 0;
	//libvlc_video_set_format_callbacks(libVlcMediaPlayer, format_setup, format_cleanup);
	eventManager = libvlc_media_player_event_manager( libVlcMediaPlayer );
	registerEvents();
	libvlc_media_player_play(libVlcMediaPlayer);
	//libvlc_audio_set_volume(libVlcMediaPlayer, 0);
}

void LibVLC::setInitProps()
{
	setVolume(vol);
}

void LibVLC::stop()
{
	libvlc_media_player_stop(libVlcMediaPlayer);
}

void LibVLC::fullscreen(bool fullscreen)
{
	libvlc_set_fullscreen(libVlcMediaPlayer, fullscreen);
}

void LibVLC::pause()
{
	libvlc_media_player_pause(libVlcMediaPlayer);
}

void LibVLC::resume()
{
    libvlc_media_player_pause( libVlcMediaPlayer );
}

libvlc_time_t LibVLC::getLength()
{
	return libvlc_media_player_get_length(libVlcMediaPlayer);
}

libvlc_time_t LibVLC::getDuration()
{
	return libvlc_media_get_duration(libVlcMediaItem);
}

int LibVLC::getWidth()
{
	return libvlc_video_get_width(libVlcMediaPlayer);
}

int LibVLC::getHeight()
{
	return libvlc_video_get_height(libVlcMediaPlayer);
}

int LibVLC::isPlaying()
{
	return libvlc_media_player_is_playing(libVlcMediaPlayer);
}

void LibVLC::setRepeat(int numRepeats)
{
	// repeat = numRepeats;
	// if (libVlcMediaItem!=nullptr)
	// {
	// 	std::string sa = "input-repeat=";
	// 	sa += std::to_string(repeat);
	// 	//libvlc_media_add_option(libVlcMediaItem, sa.c_str() );	
	// 	if (repeat==-1)
	// 		libvlc_media_add_option(libVlcMediaItem, "input-repeat=-1" );	
	// 	else if (repeat==0)
	// 		libvlc_media_add_option(libVlcMediaItem, "input-repeat=0" );	
	// 	//std::cout << "Num repeats: " << sa << std::endl;
	// }

}

int LibVLC::getRepeat()
{
	return repeat;
}

const char* LibVLC::getLastError()
{
	return libvlc_errmsg();	
}

void LibVLC::setVolume(float volume)
{
	if (volume>255)
		volume = 255.0;

	vol = volume;
	if (libVlcMediaPlayer!=NULL && libVlcMediaPlayer!=nullptr)
	{
		try
		{
			//libvlc_audio_set_volume(libVlcMediaPlayer, volume);
			libvlc_audio_set_volume(libVlcMediaPlayer, 255.0);
		}
		catch(int e)
		{
		}
	}
}

float LibVLC::getVolume()
{
    float volume = libvlc_audio_get_volume( libVlcMediaPlayer );
    return volume;
}

libvlc_time_t LibVLC::getTime()
{
	if (libVlcMediaPlayer!=NULL && libVlcMediaPlayer!=nullptr)
	{
		try
		{
			int64_t t = libvlc_media_player_get_time( libVlcMediaPlayer );
			return t;
		}
		catch(int e)
		{
			return 0;
		}
	}
	else
		return 0;
}

void LibVLC::setTime(libvlc_time_t time)
{
	libvlc_media_player_set_time(libVlcMediaPlayer, time);
}

float LibVLC::getPosition()
{
    return libvlc_media_player_get_position( libVlcMediaPlayer );
}

void LibVLC::setPosition(float pos)
{
	libvlc_media_player_set_position(libVlcMediaPlayer, pos);
}

bool LibVLC::isSeekable()
{
    return ( libvlc_media_player_is_seekable( libVlcMediaPlayer ) == 1 );
}

void LibVLC::openMedia(const char* mediaPathName)
{
	libVlcMediaItem = libvlc_media_new_location(libVlcInstance, mediaPathName);
	//libVlcMediaItem = libvlc_media_new_path(libVlcInstance, mediaPathName);
    libvlc_media_player_set_media(libVlcMediaPlayer, libVlcMediaItem);    
}

//void MediaPlayer::setMedia( Media* media )
//{
    //libvlc_media_player_set_media( m_internalPtr, media->getInternalPtr() );
//}

//void
//MediaPlayer::getSize( quint32 *outWidth, quint32 *outHeight )
//{
    //libvlc_video_get_size( m_internalPtr, 0, outWidth, outHeight );
//}

float LibVLC::getFPS()
{
    return libvlc_media_player_get_fps( libVlcMediaPlayer );
}

void LibVLC::nextFrame()
{
    libvlc_media_player_next_frame( libVlcMediaPlayer );
}

bool LibVLC::hasVout()
{
    return libvlc_media_player_has_vout( libVlcMediaPlayer );
}


/////////////////////////////////////////////////////////////////////////////////////

void LibVLC::useHWacceleration(bool hwAcc)
{
	if (hwAcc)
	{
		//libvlc_media_add_option(libVlcMediaItem, ":hwdec=vaapi");
		//libvlc_media_add_option(libVlcMediaItem, ":ffmpeg-hw");
		//libvlc_media_add_option(libVlcMediaItem, ":avcodec-hw=dxva2.lo");
		//libvlc_media_add_option(libVlcMediaItem, ":avcodec-hw=any");
		//libvlc_media_add_option(libVlcMediaItem, ":avcodec-hw=dxva2");
		//libvlc_media_add_option(libVlcMediaItem, "--avcodec-hw=dxva2");
		//libvlc_media_add_option(libVlcMediaItem, ":avcodec-hw=vaapi");
	}
}

/////////////////////////////////////////////////////////////////////////////////////

void LibVLC::registerEvents()
{
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPlaying,         callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerSnapshotTaken,   callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerTimeChanged,     callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPlaying,         callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPaused,          callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerStopped,         callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerEndReached,      callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPositionChanged, callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerLengthChanged,   callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerEncounteredError,callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPausableChanged, callbacks, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerSeekableChanged, callbacks, this );
}

void LibVLC::callbacks( const libvlc_event_t* event, void* ptr )
{
    LibVLC* self = reinterpret_cast<LibVLC*>( ptr );
	
    switch ( event->type )
    {
		case libvlc_MediaPlayerPlaying:
			//cout << "playing" << endl;
			//msg = "LibVLC::playing";
			self->flags[1]=1;
			self->setInitProps();
			break;
		case libvlc_MediaPlayerPaused:
			//msg = "LibVLC::paused";
			self->flags[2]=1;
			break;
		case libvlc_MediaPlayerStopped:
			//msg = "LibVLC::stopped";
			self->flags[3]=1;
			break;
		case libvlc_MediaPlayerEndReached:
			//msg = "LibVLC::endReached";
			self->flags[4]=1;
			break;
		case libvlc_MediaPlayerTimeChanged:
			//msg = String("LibVLC::timeChangeed");
			//self->emit timeChanged( event->u.media_player_time_changed.new_time );
			self->flags[5]=event->u.media_player_time_changed.new_time;
			break;
		case libvlc_MediaPlayerPositionChanged:
			//msg = String("LibVLC::positionChanged");
			//self->emit positionChanged( event->u.media_player_position_changed.new_position );
			self->flags[6]=event->u.media_player_position_changed.new_position;
			break;
		case libvlc_MediaPlayerLengthChanged:
			//msg = String("LibVLC::lengthChanged");
			//self->emit lengthChanged( event->u.media_player_length_changed.new_length );
			self->flags[7]=event->u.media_player_length_changed.new_length;
			break;
		case libvlc_MediaPlayerSnapshotTaken:
			//msg = String("LibVLC::snapshotTaken");
			//self->emit snapshotTaken( event->u.media_player_snapshot_taken.psz_filename );
			//flags[8]=event->u.media_player_length_changed.new_length;
			break;
		case libvlc_MediaPlayerEncounteredError:
			//msg = "LibVLC::error";
			//qDebug() << '[' << (void*)self << "] libvlc_MediaPlayerEncounteredError received."
					//<< "This is not looking good...";
			self->flags[9]=1;
			
			//RaiseException(0x0000DEAD,0,0,0);
			
			break;
		case libvlc_MediaPlayerSeekableChanged:
			//msg = String("LibVLC::seekableChanged");
			//self->emit volumeChanged();
			self->flags[10]=1;
			break;
		case libvlc_MediaPlayerPausableChanged:
		case libvlc_MediaPlayerTitleChanged:
		case libvlc_MediaPlayerNothingSpecial:
		case libvlc_MediaPlayerOpening:
			//msg = "LibVLC::opening";
			self->flags[11]=1;
			break;
		case libvlc_MediaPlayerBuffering:
			//msg = "LibVLC::buffering";
			self->flags[12]=1;
			break;
		case libvlc_MediaPlayerForward:
			self->flags[13]=1;
			break;
		case libvlc_MediaPlayerBackward:
			self->flags[14]=1;
			break;
		default:
	//        qDebug() << "Unknown mediaPlayerEvent: " << event->type;
			break;
    }
	
}

/////////////////////////////////////////////////////////////////////////////////////


*/



/* Nice tips!


@:cppFileCode('
// cppFileCode can "see" the definition of Receiver, and can put
//   stuff in the global namespace
void setDataToHaxe(unsigned char *inData, int length)
{
   Receiver_obj::onNativeData(inData, length);
}

// This is what would go in your native code:
extern void setDataToHaxe(unsigned char *inData, int length);

void fakeNative()
{
   setDataToHaxe((unsigned char *)"hello", 6);
}

')
class Receiver
{
   @:keep public static function onNativeData(ptr:cpp.Star<cpp.UInt8>, length:Int)
   {
      trace("Got data " + ptr + "*" + length);

      // Wrap in haxe.io.Bytes for use with internal APIs...
      var data = new Array< cpp.UInt8 >();
      cpp.NativeArray.setUnmanagedData(data,cast ptr, length);
      var bytes = haxe.io.Bytes.ofData(data);

      trace( bytes.toString() );
   }

   @:extern @:native("fakeNative")
   public static function runFakeNative() : Void { }

   public static function main()
   {
      runFakeNative();
   }
}

*/