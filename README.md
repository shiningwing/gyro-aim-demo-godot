# Gyro Aim Demo for Godot

This is a simple first-person shooter demo game for Godot Engine made to make use of gyro aim, featuring aim trainer style gameplay. It currently only works on mobile, as no other platform currently supports gyro built-in under Godot. In the future, it might feature another extension to make use of it for controllers, if I can find a good one.

This project is more just me experimenting with programming various features I would like to use for future projects. If you want to use this as a basis for your own project, you're on your own.

If you're on desktop, press Escape to exit the main game scene.

## Features:
	
- Gyro aim (only on mobile for now)
	- Configurable horizontal and vertical sensitivity
	- Acceleration, with configurable multiplier, and slow and fast thresholds
	- Smoothing, with a configurable threshold and buffer length
	- Tightening, with a configurable threshold
	- Sensor fusion, with "player space" and "world space" gyro aim
	- A gyro modifier button, which can be set to turn gyro aim on or off when held, or toggled when pressed.
- Simple mouse aim
	- You can adjust the sensitivity, that's it
- Touch controls
	- Touch aim uses the same sensitivity as mouse aim
	- Touch buttons for firing and the gyro modifier
- Aim trainer style gameplay
	- Resembles the "spidershot" gameplay style in a basic sense
	- A target that starts in the middle, and moves to a random place when shot, then resets to the middle when shot again
	- A score value that increases when the target is shot, with the point value depending on how fast you shoot it
	- A score multiplier up to 5x, awarded for consecutive hits and zeroed after a miss
	- A timer ticking down from 60 seconds, starting when the target is first shot
	- A final score display when the timer runs out
	- A ticking sound when the timer is in the last 5 seconds

Gyro aim code in this project is based on guides from [Jibb Smart's GyroWiki](http://gyrowiki.jibbsmart.com/).

This project uses some stock assets (prototype textures and sound effects) from [Kenney](https://kenney.nl).
