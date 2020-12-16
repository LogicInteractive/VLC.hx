// #include "pch.h"
#include <Kore/pch.h>

#include "LibVLCVideo.h"

// #include <streams.h>
#include <iostream>

using namespace Kore;

void *LibVLCVideo::lockStatic(void *data, void **p_pixels)
{
	return ((LibVLCVideo *)data)->lock(p_pixels);
	// bf = image->lock();
	// vlcMutex.lock();

	// *p_pixels = pixels;
	// *p_pixels = bf;
	// return NULL;
}

void LibVLCVideo::unlockStatic(void *data, void *id, void *const *p_pixels)
{
    ((LibVLCVideo *)data)->unlock(id, p_pixels);
	// vlcMutex.unlock();
	// image->unlock();
	// needsUpdate = true;
}

void LibVLCVideo::displayStatic(void *data, void *picture)
{
	((LibVLCVideo *)data)->display(picture);
	// if (image==nullptr)
		// return;

 	// u8* buffer = image->lock();
	//unsigned w= image->width;
	//unsigned h= image->height;
	//unsigned frame = w*h*4;
	// memcpy(buffer, pixels, frame);
	// image->unlock();	
	//memcpy(bf, pixels, frame);
}

unsigned LibVLCVideo::setupStatic(void** data, char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
{
	return ((LibVLCVideo *)*data)->setupFormat(chroma, width, height, pitches, lines);
	// unsigned _w = (*width);
	// unsigned _h = (*height);
	// unsigned _pitch = _w*4;
	// unsigned _frame = _w*_h*4;
	
	// (*pitches) = _pitch;
	// (*lines) = _h;
	// // memcpy(chroma, "RGBA", 4);
	// // memcpy(chroma, "RV24", 4);
	// memcpy(chroma, "RV32", 4);

	// pixels = new u8[_frame];
	// for (int y = 0; y < _h; ++y)
	// {
	// 	for (int x = 0; x < _w; ++x)
	// 	{
	// 		pixels[y * _w * 4 + x * 4 + 0] = 0;
	// 		pixels[y * _w * 4 + x * 4 + 1] = 0;
	// 		pixels[y * _w * 4 + x * 4 + 2] = 0;
	// 		pixels[y * _w * 4 + x * 4 + 3] = 255;
	// 	}
	// }
	
	// image = new Graphics4::Texture(_w, _h, Graphics4::Image::RGBA32, false);
	// std::cout << "size " << _w << " " << _h << std::endl;
	// ((LibVLCVideo *)*opaque)->ready=true;//OBS!!!
	// return 1;//((LibVLCVideo *)data)->setupFormat(chroma, width, height, pitches, lines);

}

void LibVLCVideo::cleanupStatic(void *data)
{
	((LibVLCVideo *)data)->cleanupFormat();
}

// unsigned format_setup(void** opaque, char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
// {
// 	unsigned _w = (*width);
// 	unsigned _h = (*height);
// 	unsigned _pitch = _w*4;
// 	unsigned _frame = _w*_h*4;
	
// 	(*pitches) = _pitch;
// 	(*lines) = _h;
// 	// memcpy(chroma, "RGBA", 4);
// 	memcpy(chroma, "RV32", 4);
	
// 	pixels = new u8[_frame];
// 	image = new Graphics4::Texture(_w, _h, Graphics4::Image::RGBA32, false);
// 	return 1;
// }




LibVLCVideo::LibVLCVideo(const char* filename)
{
	duration = 1000 * 10;
	position = 0;
	finished = false;
	paused = false;
	canDraw = false;

	this->position = 0;

	char const *Args[] = {
		// "--no-directx-hw-yuv",
		"--directx-hw-yuv",
		"--avcodec-hw=dxva2",
		"--vmem-chroma=chroma",
	   	"--no-xlib", 
        "--no-video-title-show",		
		"--no-osd"
	};		

	int Argc = sizeof(Args) / sizeof(*Args);
	instance = libvlc_new(Argc, Args);		
	audioOutList = libvlc_audio_output_list_get(instance);
	
	setSource(filename);
}

void LibVLCVideo::setSource(const char* filename)
{
	if (filename==nullptr)
		return;

	mediaItem = libvlc_media_new_path(instance, filename);
	mediaPlayer = libvlc_media_player_new_from_media(mediaItem);

	libvlc_audio_output_set(mediaPlayer, "waveout");
	// libvlc_audio_output_set(libVlcMediaPlayer, "directsound");

	// int videoWidth, videoHeight;
	// float fps;
	// libvlc_time_t video_length_ms;
	// videoWidth = 0;
	// videoHeight = 0;

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
	// pixels = new u8[1920*1090*4];
	// image = new Graphics4::Texture(1920, 1090, Graphics4::Image::RGBA32, false);
	// ready=true;
}

Graphics4::Texture* LibVLCVideo::currentImage()
{
	// if(vlcMutex.try_lock())
	// {
         if (needsUpdate)
		{
			u8* buffer = image->lock();
			unsigned w= image->width;
			unsigned h= image->height;
			int stride = image->stride();
			unsigned frame = w*h*4;
			// memcpy(buffer, bf, frame);
			// memcpy(buffer, pixels, frame);

			for (int y = 0; y < h; ++y)
			{
				for (int x = 0; x < w; ++x)
				{
					buffer[y * stride + x * 4 + 0] = pixels[y * w * 4 + x * 4 + 2];
					buffer[y * stride + x * 4 + 1] = pixels[y * w * 4 + x * 4 + 1];
					buffer[y * stride + x * 4 + 2] = pixels[y * w * 4 + x * 4 + 0];
					// buffer[y * stride + x * 4 + 3] = 255;
				}
			}

			image->unlock();
			needsUpdate = false;
        }
        // vlcMutex.unlock();
	// }
	
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
	libvlc_media_player_play(mediaPlayer);
}

void LibVLCVideo::pause()
{
	libvlc_media_player_pause(mediaPlayer);
}

void LibVLCVideo::stop()
{
	libvlc_media_player_stop(mediaPlayer);
	libvlc_media_player_release(mediaPlayer);
	libvlc_media_release(mediaItem);
	libvlc_release(instance);
}

float LibVLCVideo::getPosition()
{
	return libvlc_media_player_get_position(mediaPlayer);
}

void LibVLCVideo::update(double time)
{
	// mediaPosition->put_CurrentPosition(time);
}

void *LibVLCVideo::lock(void **p_pixels)
{
	*p_pixels = pixels;
    return NULL;
}

void LibVLCVideo::unlock(void *id, void *const *p_pixels)
{
	needsUpdate = true;
}

void LibVLCVideo::display(void *id)
{
	// return;
	// u8* buffer = image->lock();
	// unsigned _frame = image->width*image->height*4;
	// memcpy(buffer, pixels, _frame);
	// image->unlock();	
}

unsigned LibVLCVideo::setupFormat(char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines)
{
	unsigned _w = (*width);
	unsigned _h = (*height);
	unsigned _pitch = _w*4;
	unsigned _frame = _w*_h*4;
	
	(*pitches) = _pitch;
	(*lines) = _h;
	// memcpy(chroma, "RGBA", 4);
	// memcpy(chroma, "RV24", 4);
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
	// std::cout << "size " << _w << " " << _h << std::endl;
	canDraw=true;
	return 1;	
}

void LibVLCVideo::cleanupFormat()
{
}

