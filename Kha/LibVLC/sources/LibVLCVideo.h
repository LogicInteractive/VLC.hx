#include <Kore/Graphics4/Texture.h>
#include "vlc/vlc.h"
#include <mutex>

namespace Kore
{
	class LibVLCVideo
	{

	public:
		LibVLCVideo();
		~LibVLCVideo()
		{
			// delete image;
			dispose();
		}
		Graphics4::Texture* currentImage();
		void setSource(const char* filename);
		void play();
		void pause();
		void stop();
		int width();
		int height();
		float getPosition();
		void setPosition(float newPosition);
		void setAudioOutput(const char* audioDeviceName);		
		void rewind();
		void seek(float position);
		bool isPlaying();
		libvlc_time_t getTimeMillis();
		void setTimeMillis(libvlc_time_t ms);
		void setFrame(int frame);
		int getCurrentFrame();
		int getVolume();
		float getDuration();
		void setVolume(int volume);
		void toggleMute();
		void setLoop(bool loop);

		double duration;
		double position;
		bool finished;
		bool paused;
		bool loop;

		void *lock(void **p_pixels);
		void unlock(void *picture, void *const *p_pixels);
		void display(void *picture);
		unsigned setupFormat(char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines);
		void cleanupFormat();
		void vlcEvent(const libvlc_event_t *event);
		void registerEvents();
		void unRegisterEvents();
		void dispose();

		bool canDraw;
		bool needsUpdate = false;
		bool uniqueFullscreenMode = false;

		//Static callbacks
		static void *lockStatic(void *data, void **p_pixels);
		static void unlockStatic(void *data, void *id, void *const *p_pixels);
		static void displayStatic(void *data, void *id);
		static unsigned setupStatic(void** data, char* chroma, unsigned* width, unsigned* height, unsigned* pitches, unsigned* lines);
		static void cleanupStatic(void *data);
		static void vlcEventStatic(const libvlc_event_t *event, void *data);

	private:
		u8* pixels;
		std::mutex vlcMutex;
		Graphics4::Texture* image;
		bool flip = false;

		libvlc_instance_t* instance;
		libvlc_media_t* mediaItem;
		libvlc_media_player_t* mediaPlayer;
		libvlc_event_manager_t* eventManager;
		libvlc_audio_output_t* audioOutList;
		
	};
}