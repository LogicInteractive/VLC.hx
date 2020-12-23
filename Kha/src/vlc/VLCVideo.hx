package vlc;

import cpp.Function;
import cpp.Star;
import haxe.io.Bytes;
import vlc.LibVLC;

@:headerCode('
#include <iostream>
#include <mutex>
#include <vector>
using namespace Kore;
')
@:headerInclude('vlc/vlc.h')
@:headerClassCode('
void *cplock(void **p_pixels);
void cpunlock(void *picture, void *const *p_pixels);
void cpdisplay(void *picture);
unsigned cpsetupFormat(char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines);
void cpcleanupFormat();
void fish();
void cpvlcEvent(const libvlc_event_t *event);
std::mutex vlcMutex;
u8* pixels;
std::vector<const libvlc_event_t*>internalEvent;
')
@:unreflective
@:cppNamespaceCode('

using namespace Kore;

// Static callbacks ///////////////////////////////////////////////////////////////////////

void *lockStatic(void *data, void **p_pixels)
{
	return ((VLCVideo_obj *)data)->cplock(p_pixels);
}

void unlockStatic(void *data, void *id, void *const *p_pixels)
{
    ((VLCVideo_obj *)data)->cpunlock(id, p_pixels);
}

void displayStatic(void *data, void *picture)
{
	((VLCVideo_obj *)data)->cpdisplay(picture);
}

unsigned setupStatic(void** data, char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
{
	return ((VLCVideo_obj *)*data)->cpsetupFormat(chroma, width, height, pitches, lines);
}

void cleanupStatic(void *data)
{
	((VLCVideo_obj *)data)->cpcleanupFormat();
}

void vlcEventStatic(const libvlc_event_t *event, void *data)
{
	// ((VLCVideo_obj *)data)->cpvlcEvent(event);
	// ((VLCVideo_obj *)data)->vlcEvent(event);

	// ((VLCVideo_obj *)data)->internalEvent->push(1);
	// ((VLCVideo_obj *)data)->earr[0]=event;
	((VLCVideo_obj *)data)->internalEvent.push_back(event);
}

// Setup functions ////////////////////////////////////////////////////////////////////////

void *VLCVideo_obj::cplock(void **p_pixels)
{
 	// vlcMutex.lock();
 	*p_pixels = pixels;
    return NULL;
 }

void VLCVideo_obj::cpunlock(void *id, void *const *p_pixels)
{
	// vlcMutex.unlock();
}

void VLCVideo_obj::cpdisplay(void *id)
{
}

unsigned VLCVideo_obj::cpsetupFormat(char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
{
 	unsigned _w = (*width);
	unsigned _h = (*height);
	unsigned _pitch = _w*4;
	unsigned _frame = _w*_h*4;
	
	(*pitches) = _pitch;
	(*lines) = _h;
	//memcpy(chroma, "RGBA", 4);
	//memcpy(chroma, "RV16", 4);
	//memcpy(chroma, "RV24", 4);
	memcpy(chroma, "RV32", 4);

 	pixels = new u8[_frame];
	for (int y = 0; y < _h; ++y)
	{
		for (int x = 0; x < _w; ++x)
		{
			pixels[y * _w * 4 + x * 4 + 0] = 255;
			pixels[y * _w * 4 + x * 4 + 1] = 0;
			pixels[y * _w * 4 + x * 4 + 2] = 0;
			pixels[y * _w * 4 + x * 4 + 3] = 255;
		}
	}

	canDraw=true;

	return 1;	
}

void VLCVideo_obj::cpcleanupFormat()
{
}

void VLCVideo_obj::fish()
{
 	std::cout << "Fish" << std::endl;
}

// void VLCVideo_obj::cpvlcEvent(const libvlc_event_t *event)
// {
	// std::cout << "Event: " << event->type << std::endl;

	// hxcb();
    // if (event->type == libvlc_MediaPlayerEndReached) {
    //     movieFinished = true;
    // }
// }


')
// @:buildXml('<include name="../../src/vlc/build/VLCBuild.xml" />')
class VLCVideo extends kha.Video
{
	public var vlcInstance		: LibVLC_Instance_p;
	public var mediaPlayer		: LibVLC_MediaPlayer_p;
	public var media			: LibVLC_Media_p;
	public var audioOutList		: LibVLC_AudioOutput_p;
	public var eventManager		: LibVLC_Eventmanager_p;

	// public var pixels			: Array<cpp.UInt8>;
	public var texture			: kha.Image;
	public var canDraw			: Bool					= false;
	// public var vlcMutex			: Mutex2;

	public function new(?path:String, ?uniqueFullscreenMode:Bool=false)
	{
		super();
		// init();
		vlcInstance = LibVLC.New(0, null);
		audioOutList = LibVLC.getAudioOutputList(vlcInstance);
		
		if (pipeline==null)
			createPipeline();

		// setUniqueFullscreenMode(uniqueFullscreenMode);
		if (path!=null)
			setSource(path);

		// internalEvent.push(2);

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

		// pixels = [];
		// pixels.resize(1920*1090*4);

	 	// untyped __cpp__('earr = new libvlc_event_t[40000]');

		texture = kha.Image.create(1920,1080,kha.graphics4.TextureFormat.RGBA32);
		LibVLC.setFormatCallbacks(mediaPlayer, getSetupStaticCB(), getCleanupStaticCB());		
		LibVLC.setCallbacks(mediaPlayer, getLockStaticCB(), getUnlockStaticCB(), getDisplayStaticCB(), getThisPointer());	

		eventManager = LibVLC.setEventmanager(mediaPlayer);	
		setupEvents(eventManager);
	}

	// @:functionCode('libvlc_video_set_callbacks(mediaPlayer, clockStatic, cunlockStatic, cdisplayStatic, this);') 
	// public function setupCallbacks(): Void {}

	override public function play(loop:Bool=false)
	{
		LibVLC.mediaPlayerPlay(mediaPlayer);
	}

	function grabFrame()
	{
		var buffer:LibVLC_PixelBuffer_p = lockTexture(texture);
		var frameSize:UInt = getTextureWidth(texture)*getTextureHeight(texture)*4;
		cpp.Native.nativeMemcpy(cast buffer, cast getPixelBuffer(), frameSize);
		unlockTexture(texture);	
	}

	public function draw(g2:kha.graphics2.Graphics, ?x:Null<Float>, ?y:Null<Float>, ?w:Null<Float>, ?h:Null<Float>)
	{
		var e:LibVLC_Event_const_p = getLastInternalEventQueueItem();
		if (e!=null)
			onVlcEvent(cast e);
		
		if (!canDraw)
			return;

		grabFrame();

		@:privateAccess g2.setPipeline(pipeline);
		g2.color = kha.Color.White;
		g2.drawScaledSubImage(texture, 0, 0, texture.width, texture.height, x, y, w, h);
		@:privateAccess g2.setPipeline(null);

	}
	
	function setupEvents(eventManager:LibVLC_Eventmanager_p)
	{
		var self:cpp.Star<cpp.Void> = getThisPointer();
		var cb:LibVLC_Callback = getEventStaticCB();

		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerTimeChanged, cb, self);
		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerPlaying, cb, self);
		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerStopped, cb, self);
		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerEndReached, cb, self);
		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerPositionChanged, cb, self);
		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerLengthChanged, cb, self);
		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerEncounteredError, cb, self);
		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerPausableChanged, cb, self);
		LibVLC.eventAttach( eventManager, LibVLC_EventType.mediaPlayerSeekableChange, cb, self);
	}

	static public function eventCallbacks(eventPtr:LibVLC_Event_const_p,userDataPtr:VoidStar)
	{

	}

	@:void
	public function vlcEvent(event:LibVLC_Event_const_p):Void
	{
	}


	function onVlcEvent(event:LibVLC_Event)
	{
		switch ( event.type )
		{
			case LibVLC_EventType.mediaPlayerPlaying:
			{
				// vlcp.isPlaying = true;
			}
			case LibVLC_EventType.mediaPlayerPaused:
			{
				// vlcp.isPlaying = false;
			}
			case LibVLC_EventType.mediaPlayerStopped:
			{
				// vlcp.isPlaying = false;
			}
			case LibVLC_EventType.mediaPlayerEndReached:
			{
				// vlcp.isPlaying = false;
			}
			case LibVLC_EventType.mediaPlayerTimeChanged:
			{
				// time = VLCPlayer.mediaPlayerGetTime(vlcp.mediaPlayer);
				// vlcp.currentTime = event.u.media_player_time_changed.new_time;
			}
			case LibVLC_EventType.mediaPlayerPositionChanged:
			{
				// vlcp.position = event.u.media_player_position_changed.new_position;
			}
			case LibVLC_EventType.mediaPlayerLengthChanged:
			{
				// vlcp.length = event.u.media_player_length_changed.new_length;
			// self->flags[7]=event->u.media_player_length_changed.new_length;				
			}
			case LibVLC_EventType.mediaPlayerEncounteredError:
			{
			}
			case LibVLC_EventType.mediaPlayerSeekableChange:
			{
				// event.u.media_player_seekable_changed.new_seekable
			}
			case LibVLC_EventType.mediaPlayerPausableChanged:
			{
				// event.u.media_player_pausable_changed.new_pausable
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
				// event.u.media_player_buffering.new_cache;
			}
			case LibVLC_EventType.mediaPlayerForward:
			{
			}
			case LibVLC_EventType.mediaPlayerBackward:
			{
			}
			default:
		}		

		trace(event.type);
	}

	// Raw c++ interface //////////////////////////////////////////////////////////////////////

	@:functionCode("return tx->texture->lock();")
	function lockTexture(tx:kha.Image):LibVLC_PixelBuffer_p { return null; }

	@:functionCode("tx->texture->unlock();")
	function unlockTexture(tx:kha.Image) { }

	@:functionCode("return tx->texture->width;")
	function getTextureWidth(tx:kha.Image):UInt { return 0; }

	@:functionCode("return tx->texture->height;")
	function getTextureHeight(tx:kha.Image):UInt { return 0; }

	@:functionCode("return pixels;")
	function getPixelBuffer():LibVLC_PixelBuffer_p { return null; }

	@:functionCode("return setupStatic;")
	function getSetupStaticCB():LibVLC_Video_Format_CB { return null; }

	@:functionCode("return cleanupStatic;")
	function getCleanupStaticCB():LibVLC_Video_Cleanup_CB { return null; }

	@:functionCode("return lockStatic;")
	function getLockStaticCB():LibVLC_Video_Lock_CB { return null; }

	@:functionCode("return unlockStatic;")
	function getUnlockStaticCB():LibVLC_Video_Unlock_CB { return null; }

	@:functionCode("return displayStatic;")
	function getDisplayStaticCB():LibVLC_Video_Display_CB { return null; }

	@:functionCode("return vlcEventStatic;")
	function getEventStaticCB():LibVLC_Callback { return null; }

	@:functionCode("return this;")
	function getThisPointer():cpp.Star<cpp.Void> { return null; }

	@:functionCode("if (!internalEvent.empty()) return internalEvent.back(); else return NULL;")
	function getLastInternalEventQueueItem():LibVLC_Event_const_p { return null; }

	// Pipeline ///////////////////////////////////////////////////////////////////////////////

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

@:native("vlc::setupStatic")		extern class SetupStatic_CB {}
@:native("vlc::cleanupStatic")		extern class CleanupStatic_CB {}

@:native("std::mutex")
extern class Mutex2 {}

