--------
iOS Flocking
--------
This is a port of the concept of Boids / SteeringBehaviors to iOS writen in `Objective-C`. 
The focus of this port is to make it easy to use in iOS games and/or visual experiments. 
For this reason it comes with an example project, which already has several Cocos2D set up and running for you, showing you the various combination of rules that can be used to create varied behavior.

------
Usage
------
`	
	boid = [Boid spriteWithSpriteSheet:_sheet rect: boidRect];
	[boid setSpeedMax: 2.0f andSteeringForceMax: 1.0f];
	[boid setWanderingRadius: 16.0f lookAheadDistance: 40.0f andMaxTurningAngle:0.2f];
`	 
## On your update function
`
	while(boid)
	{
		Boid* b = boid;
		boid = b->_next;
		[b wander: 0.19f];
		[b 
		 flock:_flockPointer
		 withSeparationWeight:0.6f
		 andAlignmentWeight:0.1f
		 andCohesionWeight:0.2f
		 andSeparationDistance:10.0f
		 andAlignmentDistance:30.0f
		 andCohesionDistance:20.0f
		 ];
 
		[b flee:badThingPosition panicAtDistance:5 usingMultiplier:0.6f]; // avoid touch
		[b seek:yummyFoodPosition withinRange:75 usingMultiplier:0.35f]; // go towards touch
                [b update];
	}
`

------
A bit of history 
------
Created in the 1980′s from by Criag Renolds, the gist of it is that using 3 simple behaviors, surprisingly complex motion can be formed when you have many actors (Referred to as Boids, i think Craig meant it as a another way of saying Birds, a more new york way).  
A few months ago a friend of mine gave a talk based on Kieth Peters book AdvancED ActionScript 3.0 Animation (a great book). This re-sparked my interest in them, and with my on going interest in iphone development – I decided to try and port Kieth Peters code to Objective-C as best I could with the more limited knowledge I had at the time.

It actually didn’t work all that great, but, I came across SoulWire’s interpretation of Flocking (also in AS3), and I ported that. Maybe it was because it was my second attempt at porting, but this time I got really great results.
200 Objects flocking, all aware of every single other one, on a tiny iphone in your hand, that was very rewarding.
The problem was that I used Box2D’s point class B2Vec2, and then i modified it a little to boot, because I wanted to add a few operators it didn’t have built in. So it left me with something I could not really share with anyone else, and also it was now Combining Objective-C and C++, which always seems like you should avoid it whenever possible.

This was many months ago (march according to my SVN), and i had my fun playing with it and left it at that.
However, recently on the Cocos2D forums someone brought up making a heat seeking missile and I mentioned that stearing behaviors would be a great for that, if maybe over complicated but being a game forum – you worry about that less as it might be a great jumping platform from which additional gameplay ideas stem.

I decided I would revisit my class, as I had been wanting to for a long time, and re-write it using only CGPoints so that it could be pure `Objective-C`.

