package vlc;

#if kha_kore

import cpp.Char;
import cpp.ConstStar;
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
std::mutex vlcMutex;
std::vector<libvlc_event_t>internalEvent;
')
@:unreflective
@:cppNamespaceCode('

// Static callbacks ///////////////////////////////////////////////////////////////////////

#ifndef vlcCallbacks
#define vlcCallbacks

using namespace Kore;

void *VLCVideo_lockStatic(void *data, void **p_pixels)
{
	if (((VLCVideo_obj *)data)->canDraw)
		*p_pixels=&((VLCVideo_obj *)data)->pixels[0];
	return NULL;
}

void VLCVideo_unlockStatic(void *data, void *id, void *const *p_pixels)
{
}

void VLCVideo_displayStatic(void *data, void *picture)
{
}

unsigned VLCVideo_setupStatic(void** data, char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
{
	((VLCVideo_obj *)*data)->cb_setup_active=true;

 	unsigned _w = (*width);
	unsigned _h = (*height);
	unsigned _pitch = _w*4;
	unsigned _frame = _w*_h*4;
	(*pitches) = _pitch;
	(*lines) = _h;
	memcpy(chroma, "RV32", 4);

	((VLCVideo_obj *)*data)->videoWidth=_w;
	((VLCVideo_obj *)*data)->videoHeight=_h;
	return 1;
}

void VLCVideo_cleanupStatic(void *data)
{
	((VLCVideo_obj *)data)->cb_cleanup_active=true;	
}

void VLCVideo_eventStatic(const libvlc_event_t *event, void *data)
{
	((VLCVideo_obj *)data)->internalEvent.push_back((*event));
}
#endif

')
@:keep
class VLCVideo extends kha.Video
{
	var cb_cleanup_active		: Bool					= false;
	var cb_setup_active			: Bool					= false;

	static public var vlcInstance: LibVLC_Instance_p;
	public var mediaPlayer		: LibVLC_MediaPlayer_p;
	public var media			: LibVLC_Media_p;
	public var audioOutList		: LibVLC_AudioOutput_p;
	public var eventManager		: LibVLC_Eventmanager_p;

	public var pixels			: Array<cpp.UInt8>;
	public var texture			: kha.Image;
	public var canDraw			: Bool					= false;
	public var videoWidth		: Int					= 0;
	public var videoHeight		: Int					= 0;
	public var currentTime		: Int					= 0;

	// public var vlcMutex			: Mutex2;

	public function new(?path:String, ?uniqueFullscreenMode:Bool=false)
	{
		super();
		if (vlcInstance==null)
			vlcInstance = LibVLC.New(0, null);

		audioOutList = LibVLC.getAudioOutputList(vlcInstance);
		
		if (pipeline==null)
			createPipeline();

		// setUniqueFullscreenMode(uniqueFullscreenMode);
		if (path!=null)
			setSource(path);

		 LibVLC.mediaPlayerPlay(mediaPlayer);
	}
	
	function setSource(path:String)
	{
		path = processPath(path);
		media = LibVLC.mediaNewPath(vlcInstance,path);		
		mediaPlayer = LibVLC.mediaPlayerNewFromMedia(media);
		LibVLC.mediaParse(media);
		LibVLC.mediaRelease(media);
		
		LibVLC.setAudioOutput(mediaPlayer,"waveout");
		LibVLC.audioSetVolume(mediaPlayer, 10);

		pixels = [];

		LibVLC.setFormatCallbacks(mediaPlayer, getSetupStaticCB(), getCleanupStaticCB());		
		LibVLC.setCallbacks(mediaPlayer, getLockStaticCB(), getUnlockStaticCB(), getDisplayStaticCB(), getThisPointer());	

		eventManager = LibVLC.setEventmanager(mediaPlayer);	
		setupEvents(eventManager);
	}

	function processPath(p:String):String
	{
		p = p.split("/").join("\\");
		return p;
	}

	// Setup functions ////////////////////////////////////////////////////////////////////////

	function setupFormat()
	{
		cb_setup_active = false;
		pixels.resize(videoWidth*videoHeight*4);
		texture = kha.Image.create(videoWidth,videoHeight,kha.graphics4.TextureFormat.RGBA32);
		canDraw = true;
	}

	function cleanupFormat()
	{
		cb_cleanup_active = false;
	}

	///////////////////////////////////////////////////////////////////////////////////////////

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
		checkEvents();

		if (!canDraw)
			return;

		grabFrame();

		@:privateAccess g2.setPipeline(pipeline);
		g2.color = kha.Color.White;
		g2.drawScaledSubImage(texture, 0, 0, texture.width, texture.height, x, y, w, h);
		@:privateAccess g2.setPipeline(null);

	}
	
	///////////////////////////////////////////////////////////////////////////////////////////

	function checkEvents()
	{
		if (cb_setup_active)
			setupFormat();
		if (cb_cleanup_active)
			cleanupFormat();

		while(!isInternalQueueEmpty())
		{
			var e:LibVLC_Event = untyped __cpp__('internalEvent[0]');
			eraseOldestItemFromInternalQueue();
			onVlcEvent(e);
		}
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

	function onVlcEvent(event:LibVLC_Event)
	{
		switch ( event.type )
		{
			case LibVLC_EventType.mediaPlayerPlaying:
			{
				// vlcp.isPlaying = true;
				trace("IS PLAYING!");
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
				currentTime = event.u.media_player_time_changed.new_time;
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

		// trace(event.type);
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

	@:functionCode("return &pixels[0];")
	function getPixelBuffer():LibVLC_PixelBuffer_p { return null; }

	@:functionCode("return VLCVideo_setupStatic;")
	function getSetupStaticCB():LibVLC_Video_Format_CB { return null; }

	@:functionCode("return VLCVideo_cleanupStatic;")
	function getCleanupStaticCB():LibVLC_Video_Cleanup_CB { return null; }

	@:functionCode("return VLCVideo_lockStatic;")
	function getLockStaticCB():LibVLC_Video_Lock_CB { return null; }

	@:functionCode("return VLCVideo_unlockStatic;")
	function getUnlockStaticCB():LibVLC_Video_Unlock_CB { return null; }

	@:functionCode("return VLCVideo_displayStatic;")
	function getDisplayStaticCB():LibVLC_Video_Display_CB { return null; }

	@:functionCode("return VLCVideo_eventStatic;")
	function getEventStaticCB():LibVLC_Callback { return null; }

	@:functionCode("return this;")
	function getThisPointer():cpp.Star<cpp.Void> { return null; }

	// @:functionCode("if (!internalEvent.empty()) return internalEvent.back(); else return NULL;")
	// function getLastInternalEventQueueItem():LibVLC_Event { return null; }

	// @:functionCode("return internalEvent[0];") @:void
	// function getOldestItemFromInternalQueue():LibVLC_Event { return null; }

	@:functionCode("internalEvent.erase(internalEvent.begin());")
	function eraseOldestItemFromInternalQueue() { }

	@:functionCode("return internalEvent.empty();")
	function isInternalQueueEmpty():Bool { return true; }

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

	///////////////////////////////////////////////////////////////////////////////////////////
}

#else

class VLCVideo extends kha.Video
{
	// Not implemented here
	public function new(?path:String, ?uniqueFullscreenMode:Bool=false) { super(); }
	override public function play(loop:Bool=false) { }
	public function draw(g2:kha.graphics2.Graphics, ?x:Null<Float>, ?y:Null<Float>, ?w:Null<Float>, ?h:Null<Float>){}
}

#end