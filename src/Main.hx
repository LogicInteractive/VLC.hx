package;

import vlc.VLCPlayer;

class Main
{
	/////////////////////////////////////////////////////////////////////////////////////
	

	static function main()
	{
		var v:VLCPlayer = new VLCPlayer();	
		v.play("movie2.mp4");
		v.setFullscreen();

		Sys.sleep(10);

		v.dispose();
	}
	
	/////////////////////////////////////////////////////////////////////////////////////
}