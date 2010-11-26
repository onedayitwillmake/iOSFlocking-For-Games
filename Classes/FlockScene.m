//
//  HelloWorldLayer.m
//  BoidsExample
//
//  Created by Mario.Gonzalez on 9/16/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

// Import the interfaces
#import "FlockScene.h"

// HelloWorld implementation
@implementation FlockScene
@synthesize _flockPointer;
@synthesize _sheet;
@synthesize _currentTouch;
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	FlockScene *layer = [FlockScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] ))
	{
		srandom(time(NULL));
		
		//[self setColor: ccc3(128, 128, 128)];
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		CGRect boidRect = CGRectMake(0,0, 16, 16);
		
		
		self._sheet = [CCSpriteSheet spriteSheetWithFile:@"boid.png" capacity:201];
		self.isTouchEnabled = YES;
		self._currentTouch = CGPointZero;
		[_sheet setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE}];
		[self addChild:_sheet z:0 tag:0];
		
		
		_flockPointer = [Boid spriteWithSpriteSheet:_sheet rect: boidRect];
		Boid* previousBoid = _flockPointer;
		Boid *boid = _flockPointer;
		
		
		// Create many of them
		float count = 50.0f;
		for (int i = 0; i < count; i++) 
		{
			// Create a linked list
			// The first one has no previous and is made for us already
			if(i != 0)
			{
				boid = [Boid spriteWithSpriteSheet:_sheet rect: boidRect];
				previousBoid->_next = boid; // special case for the first one
			}
			
			previousBoid = boid;
			
			boid.doRotation = YES;
			
			// Initialize behavior properties for this boid
			// You want the flock to behavior basically the same, but have a TINY variation among members

			//[boid setSpeedMax: 2.0f andSteeringForceMax:1.0f];			
			[boid setSpeedMax: 2.2f withRandomRangeOf:0.15f andSteeringForceMax:1.0f withRandomRangeOf:0.15f];
			[boid setWanderingRadius: 16.0f lookAheadDistance: 40.0f andMaxTurningAngle:0.2f];
			[boid setEdgeBehavior: CCRANDOM_0_1() < 0.9 ? EDGE_WRAP : EDGE_BOUNCE];
			
			// Cocos properties
			[boid setScale: 1.0];
			[boid setPos: ccp( CCRANDOM_MINUS1_1() * screenSize.width,  screenSize.height / 2)];
			// Color
			[boid setOpacity:128];
			[_sheet addChild:boid];
		}
		
		
		[self schedule: @selector(tick:)];

	}
	return self;
}

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
	
}

-(void) tick: (ccTime) dt
{
	Boid* boid = _flockPointer;
	while(boid)
	{
		Boid* b = boid;
		boid = b->_next;
		//[b wander: 0.15f];
		
		// Uncomment one of these to get user interaction
		if ( CGPointEqualToPoint( _currentTouch, CGPointZero ) == NO )
		{
			//[b flee: self._currentTouch panicAtDistance:35 usingMultiplier:0.25f]; // avoid touch
			[b seek:self._currentTouch withinRange:75 usingMultiplier:0.05f]; // go towards touch
		}
		
		[b 
		 flock:_flockPointer
		 withSeparationWeight:0.9f
		 andAlignmentWeight:0.0f
		 andCohesionWeight:0.0f
		 andSeparationDistance: 64.0f
		 andAlignmentDistance: 0.0f
		 andCohesionDistance: 0.0f
		 ];

		
		[b update];
	}
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	self._currentTouch = [self convertTouchToNodeSpace: touch];
	return YES;
}
// touch updates:
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	self._currentTouch = [self convertTouchToNodeSpace: touch];
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	self._currentTouch = CGPointZero;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end