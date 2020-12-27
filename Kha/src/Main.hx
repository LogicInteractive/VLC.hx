package;

import haxe.Timer;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import vlc.VLCVideo;

class Main
{
	static function update(): Void
	{
		
	}

	public static function main()
	{
		System.start({title: "Project", width: 1920, height: 1080}, function (_)
		{
			Assets.loadEverything(function ()
			{
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (framebuffers) { mainRender(framebuffers); });

				init();
			});
		});
	}

	static function mainRender(fba:Array<Framebuffer>)
	{	
		var g2=fba[0].g2;
		g2.begin();
		g2.opacity = 1.0;
		g2.color = kha.Color.White;
		g2.imageScaleQuality = kha.graphics2.ImageScaleQuality.High;
		if (vid!=null)
			vid.draw(g2,0,0,System.windowWidth(),System.windowHeight());

		g2.opacity = 0.5;
		g2.color = kha.Color.Red;
		g2.fillRect(100,100+(Math.sin(Scheduler.time()*20)*40),300,200);

		g2.opacity = 0.25;
		g2.color = kha.Color.Green;
		g2.fillRect(100,400+(Math.sin(Scheduler.time()*10)*20),200,100);

		g2.end();
	}

	static var vid:VLCVideo;
	// static var vid:vlc.VLCVideoCPP;

	static function init()
	{
		// vid = new vlc.VLCVideoCPP("movie2.mp4",false);	
		// vid.play();

		var vidfile:String = "C:/dev/Tools/video/test/bbb.mp4";

		vid = new VLCVideo(vidfile);
		vid.onPlaying = (v)->trace("playing");
		vid.onStopped = (v)->trace("stopped");
		
		// Timer.delay(()->vid.dispose(),10000);

		// var v:VLCPlayer = new VLCPlayer();	
		// v.play("movie2.mp4");
		// v.setFullscreen();

		// vid = new VLCVideo()

		// Sys.sleep(20);
		// v.dispose();		
	}
}