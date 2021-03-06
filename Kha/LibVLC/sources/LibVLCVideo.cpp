#include <Kore/pch.h>
#include "LibVLCVideo.h"
#include <iostream>
#include <algorithm>

using namespace Kore;

// Static callbacks ///////////////////////////////////////////////////////////////////////

void *LibVLCVideo::lockStatic(void *data, void **p_pixels)
{
	return ((LibVLCVideo *)data)->lock(p_pixels);
}

void LibVLCVideo::unlockStatic(void *data, void *id, void *const *p_pixels)
{
    ((LibVLCVideo *)data)->unlock(id, p_pixels);
}

void LibVLCVideo::displayStatic(void *data, void *picture)
{
	((LibVLCVideo *)data)->display(picture);
}

unsigned LibVLCVideo::setupStatic(void** data, char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
{
	return ((LibVLCVideo *)*data)->setupFormat(chroma, width, height, pitches, lines);
}

void LibVLCVideo::cleanupStatic(void *data)
{
	((LibVLCVideo *)data)->cleanupFormat();
}

void LibVLCVideo::vlcEventStatic(const libvlc_event_t *event, void *data)
{
	((LibVLCVideo *)data)->vlcEvent(event);
}

///////////////////////////////////////////////////////////////////////////////////////////

LibVLCVideo::LibVLCVideo()
{
	duration = 1000 * 10;
	position = 0;
	finished = false;
	paused = false;
	canDraw = false;

	this->position = 0;

	char const *Args[] = {
		// "--no-directx-hw-yuv",
		// "--directx-hw-yuv",
		// "--avcodec-hw=dxva2",
		"--vmem-chroma=chroma",
	   	"--no-xlib", 
        "--no-video-title-show",		
		"--no-osd",
        "-I", "dummy",            // Don't use any interface
        "--ignore-config",        // Don't use VLC config
        // "--extraintf=logger",     // Log anything
        // "--verbose=4",            // Be verbose
        // "--ffmpeg-hw",
        // "--avcodec-hw=any"
        // "--sout", smem_options    // Stream to memory		
	};		

	int Argc = sizeof(Args) / sizeof(*Args);
	instance = libvlc_new(Argc, Args);		
	if(instance==NULL)
	{
        std::cout << "LibVLC initialization failure. Missing DLL's or Plugin Folder?" << std::endl;
        return;
    }	
	audioOutList = libvlc_audio_output_list_get(instance);
}

void LibVLCVideo::setSource(const char* filename)
{
	if (filename==nullptr)
		return;

	mediaItem = libvlc_media_new_path(instance, filename);
	mediaPlayer = libvlc_media_player_new_from_media(mediaItem);

	setAudioOutput("waveout");

	// videoWidth = libvlc_video_get_width(mediaPlayer);
	// videoHeight = libvlc_video_get_height(mediaPlayer);
	// video_length_ms = libvlc_media_get_duration(mediaItem);

	libvlc_media_parse(mediaItem);
	libvlc_media_release(mediaItem);

	if (!uniqueFullscreenMode)
	{
		libvlc_video_set_format_callbacks(mediaPlayer, setupStatic, cleanupStatic);
	}
	libvlc_video_set_callbacks(mediaPlayer, lockStatic, unlockStatic, displayStatic, this);
	// libvlc_video_set_format(mediaPlayer, "RGBA", 1920, 1080, 1920 * 4);
	registerEvents();	
}

// Setup functions ////////////////////////////////////////////////////////////////////////

void *LibVLCVideo::lock(void **p_pixels)
{
	vlcMutex.lock();
	*p_pixels = pixels;
    return NULL;
}

void LibVLCVideo::unlock(void *id, void *const *p_pixels)
{
	vlcMutex.unlock();
	flip=!flip;
}

void LibVLCVideo::display(void *id)
{
}

unsigned LibVLCVideo::setupFormat(char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
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
			pixels[y * _w * 4 + x * 4 + 0] = 0;
			pixels[y * _w * 4 + x * 4 + 1] = 0;
			pixels[y * _w * 4 + x * 4 + 2] = 0;
			pixels[y * _w * 4 + x * 4 + 3] = 255;
		}
	}
	
	image = new Graphics4::Texture(_w, _h, Graphics4::Image::RGBA32, false);
	canDraw=true;

	duration = libvlc_media_get_duration(mediaItem);

	// input_item_t *it = mediaItem->p_input_item;
    // float fps;
    // for (int i = 0; i < it->i_es; i++)
	// {
    //     es_format_t *es = it->es[i];
    //     if (es)
	// 	{
    //         if (es->video.i_frame_rate)
	// 		{
    //             fps = (float)es->video.i_frame_rate / es->video.i_frame_rate_base;
    //             cout << "fps: " << fps << endl;
    //         }
    //         //cout << es->video.i_width << endl;
    //     }
    // }	
	return 1;	
}

void LibVLCVideo::cleanupFormat()
{
}

Graphics4::Texture* LibVLCVideo::currentImage()
{
	u8* buffer = image->lock();
	unsigned w= image->width;
	unsigned h= image->height;
	int stride = image->stride();
	unsigned frame = w*h*4;
	memcpy(buffer, pixels, frame);

	// 	for (int y = 0; y < h; ++y)
	// 	{
	// 		for (int x = 0; x < w; ++x)
	// 		{
	// 			buffer[y * stride + x * 4 + 0] = pixels[y * w * 4 + x * 4 + 2];
	// 			buffer[y * stride + x * 4 + 1] = pixels[y * w * 4 + x * 4 + 1];
	// 			buffer[y * stride + x * 4 + 2] = pixels[y * w * 4 + x * 4 + 0];
	// 			// buffer[y * stride + x * 4 + 3] = 255;
	// 		}
	// 	}

	image->unlock();
	return image;
}

int LibVLCVideo::width()
{
	return image->width;
}

int LibVLCVideo::height()
{
	return image->height;
}

void LibVLCVideo::play()
{
    // if (loop)
	// 	libvlc_media_add_option(mediaPlayer, "input-repeat=-1");
    // else
	// 	libvlc_media_add_option(mediaPlayer, "input-repeat=0");

	libvlc_media_player_play(mediaPlayer);
}

void LibVLCVideo::pause()
{
	libvlc_media_player_pause(mediaPlayer);
}

void LibVLCVideo::stop()
{
	libvlc_media_player_stop(mediaPlayer);

	//....
	libvlc_media_player_release(mediaPlayer);
	libvlc_media_release(mediaItem);
}

float LibVLCVideo::getPosition()
{
	return libvlc_media_player_get_position(mediaPlayer);
}

void LibVLCVideo::setPosition(float newPosition)
{
	libvlc_media_player_set_position(mediaPlayer, newPosition);
}

void LibVLCVideo::setAudioOutput(const char* audioDeviceName)
{
	// waveout, directsound ...
	libvlc_audio_output_set(mediaPlayer, audioDeviceName);
}

void LibVLCVideo::rewind()
{
    libvlc_media_player_set_position(mediaPlayer, 0);
}

void LibVLCVideo::seek(float position)
{
    libvlc_media_player_set_position(mediaPlayer, position);
}

void LibVLCVideo::setLoop(bool loop)
{
    this->loop = loop;
}

bool LibVLCVideo::isPlaying()
{
    return libvlc_media_player_is_playing(mediaPlayer);
}

libvlc_time_t LibVLCVideo::getTimeMillis()
{
	return libvlc_media_player_get_time(mediaPlayer);
}

void LibVLCVideo::setTimeMillis(libvlc_time_t ms)
{
	libvlc_media_player_set_time(mediaPlayer, ms);
}

// float LibVLCVideo::getFPS() {
//     return fps;
// }

float LibVLCVideo::getDuration()
{
	return duration;
}

// void LibVLCVideo::setFrame(int frame)
// {
//     libvlc_time_t ms = 1000 * frame / fps;
//     setTimeMillis(ms);
// }

// int LibVLCVideo::getCurrentFrame()
// {
//     libvlc_time_t ms = getTimeMillis();
//     int frame = fps * ms / 1000;
//     return frame;
// }

// int LibVLCVideo::getTotalNumFrames() {
//     return fps * video_length_ms / 1000;
// }

int LibVLCVideo::getVolume()
{
    return libvlc_audio_get_volume(mediaPlayer);
}

void LibVLCVideo::setVolume(int volume)
{
    libvlc_audio_set_volume(mediaPlayer, volume);
}

void LibVLCVideo::toggleMute()
{
    libvlc_audio_toggle_mute(mediaPlayer);
}


// Dispose ////////////////////////////////////////////////////////////////////////////////

void LibVLCVideo::dispose()
{
	unRegisterEvents();
	eventManager = NULL;
	libvlc_release(instance);
}

// Setup functions ////////////////////////////////////////////////////////////////////////

void LibVLCVideo::vlcEvent(const libvlc_event_t *event)
{
	// std::cout << "Event: " << event->type << std::endl;
	
    // if (event->type == libvlc_MediaPlayerEndReached) {
    //     movieFinished = true;
    // }
}

void LibVLCVideo::registerEvents()
{
    eventManager = libvlc_media_player_event_manager(mediaPlayer);
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPlaying,         vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerSnapshotTaken,   vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerTimeChanged,     vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPlaying,         vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPaused,          vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerStopped,         vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerEndReached,      vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPositionChanged, vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerLengthChanged,   vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerEncounteredError,vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerPausableChanged, vlcEventStatic, this );
    libvlc_event_attach( eventManager, libvlc_MediaPlayerSeekableChanged, vlcEventStatic, this );
}

void LibVLCVideo::unRegisterEvents()
{
    if (eventManager==nullptr)
		return;

    libvlc_event_detach( eventManager, libvlc_MediaPlayerPlaying,         vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerSnapshotTaken,   vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerTimeChanged,     vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerPlaying,         vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerPaused,          vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerStopped,         vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerEndReached,      vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerPositionChanged, vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerLengthChanged,   vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerEncounteredError,vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerPausableChanged, vlcEventStatic, this );
    libvlc_event_detach( eventManager, libvlc_MediaPlayerSeekableChanged, vlcEventStatic, this );
}

///////////////////////////////////////////////////////////////////////////////////////////