/**
* Created by Julián Mancera
**/

package;

import logger.Logger;
import msignal.Signal.Signal0;
import input.TouchManager;
import input.Touch;
import input.VirtualInputManager;
import graphics.Graphics;
import runloop.RunLoop;
import runloop.MainRunLoop;

class Main
{
	/// callbacks
	public var onEnterFrame(default, null): Signal0 = new Signal0();
	public var onRender(default, null): Signal0 = new Signal0();
	public var onExitFrame(default, null): Signal0 = new Signal0();

	/// runloop
	public var loopTheMainLoopOnRender: Bool = true;
	public var mainLoop : MainRunLoop = RunLoop.getMainLoop();

	/// graphics
	public var clearAndPresentDefaultBuffer: Bool = true;

	private var touchNumber: Int = 0;
	private var virtualInputVisible: Bool = false;

	public function new()
	{
		trace("Logger Test");

		Graphics.initialize(function()
		{
			TouchManager.initialize(function()
			{
				VirtualInputManager.initialize(function()
				{
					Logger.initialize(function()
					{
						startApp();
					});
				});
			});
		});
	}

	private function startApp() : Void
	{
		// Graphics, required to solve the flashing screen on Android
		Graphics.instance().onRender.add(performOnRender);

		// Touch
		TouchManager.instance().onTouches.add(function(touchEventArray : Array<Touch>)
		{
			for (touch in touchEventArray)
			{
				var id: Int = touch.id;
				var x: Int = touch.x;
				var y: Int = touch.y;
				var state: String = touchState(touch.state);

				if (touch.state == TouchState.TouchStateBegan)
				{
					touchNumber++;
				}
				else if (touch.state == TouchState.TouchStateEnded ||
				touch.state == TouchState.TouchStateCancelled)
				{
					if (touchNumber > 0)
					{
						// toggle the virtual input after touching the screen with two fingers
						if (touchNumber == 2)
						{
							toggleVirtualInput();
						}

						touchNumber--;
					}
				}

				trace('Touch [$id] $state ($x, $y), $touchNumber touches');
			}
		});

		// Virtual input
		VirtualInputManager.instance().getVirtualInput().onInputStarted.add(function()
		{
			virtualInputVisible = true;
			trace('Input started');
		});

		VirtualInputManager.instance().getVirtualInput().onTextChanged.add(function(string: String)
		{
			trace('Text changed: $string');
		});

		VirtualInputManager.instance().getVirtualInput().onInputEnded.add(function()
		{
			virtualInputVisible = false;
			trace('Input ended');
		});
	}

	// Display Sync
	private function performOnRender(): Void
	{
		try
		{
			// Input Processing in here
			onEnterFrame.dispatch();

			if (loopTheMainLoopOnRender)
			{
				// Mainloop, runs the timers, delays and async executions
				mainLoop.loopMainLoop();
			}

			// Rendering
			if (clearAndPresentDefaultBuffer)
			{
				Graphics.instance().clearAllBuffers();
			}

			onRender.dispatch();

			if (clearAndPresentDefaultBuffer)
			{
				Graphics.instance().present();
			}

			onExitFrame.dispatch();
		}
		catch(e : Dynamic)
		{
			trace("error onRender");
		}
	}

	private function touchState(state : TouchState) : String
	{
		switch (state)
		{
			case TouchState.TouchStateBegan:
				return "Began";

			case TouchState.TouchStateMoved:
				return "Moved";

			case TouchState.TouchStateStationary:
				return "Stationary";

			case TouchState.TouchStateEnded:
				return "Ended";

			case TouchState.TouchStateCancelled:
				return "Cancelled";
		}
	}

	private function toggleVirtualInput()
	{
		if (virtualInputVisible == true)
		{
			VirtualInputManager.instance().hide();

			// log the log file :)
			var logPath: String = Logger.getLogPath();
			trace('Log path: $logPath');

			// append and flush
			Logger.flush();
		}
		else
		{
			VirtualInputManager.instance().show();

			// log a standard text
			trace("trace: toggle virtual input");
			Logger.print("print: toggle virtual input");
		}
	}

	/// MAIN
	static var _main : Main;
	static function main() : Void
	{
		_main = new Main();
	}
}