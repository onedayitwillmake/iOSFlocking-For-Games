//
//  HelloWorldLayer.m
//  BoidsExample
//
//  Created by Mario.Gonzalez on 9/16/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

// Import the interfaces
#import "SeakScene.h"

// HelloWorld implementation
@implementation SeakScene
@synthesize _flockPointer;
@synthesize _sheet;
@synthesize _currentTouch;
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SeakScene *layer = [SeakScene node];
	
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
		CGRect boidRect = CGRectMake(0,0, 32, 32);
		
		
		self._sheet = [CCSpriteSheet spriteSheetWithFile:@"blocks.png" capacity:201];
		[_sheet setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE}];
		self.isTouchEnabled = YES;
		self._currentTouch = CGPointZero;
		
		[self addChild:_sheet z:0 tag:0];
		
		
		_flockPointer = [Boid spriteWithSpriteSheet:_sheet rect: boidRect];
		Boid* previousBoid = _flockPointer;
		Boid *boid = _flockPointer;
		
		// Create many of them
		float count = 180.0f;
		for (int i = 0; i < count; i++) 
		{
			// Create a linked list
			// The first one has no previous.
			if(i != 0)
			{
				boid = [Boid spriteWithSpriteSheet:_sheet rect: boidRect];
				previousBoid->_next = boid; // special case for the first one
			}
			
			previousBoid = boid;
			
			// Initialize behavior properties for this boid
			boid.doRotation = NO;
			[boid setSpeedMax:4.0f withRandomRangeOf:1.5f andSteeringForceMax:0.75f withRandomRangeOf:0.25f];
			[boid setWanderingRadius: 16.0f lookAheadDistance: 40.0f andMaxTurningAngle:0.2f];
			[boid setEdgeBehavior: CCRANDOM_0_1() < 0.9 ? EDGE_WRAP : EDGE_BOUNCE];
			
			// Cocos properties
			[boid setScale: 0.2 + CCRANDOM_0_1() * 1.4];
			[boid setPos: ccp(CCRANDOM_0_1() * screenSize.width, CCRANDOM_0_1() * screenSize.height )];
			// Color
			float r,g,b;
			HSVtoRGB(&r, &g, &b, (float) i / count * 10.0f + 35.0f, 0.5f + CCRANDOM_0_1()*0.5, 1.0f);
			[boid setColor: ccc3(r,g,b)];
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
	//	[b wander: 0.15f];
		
		// go towards touch
		if ( CGPointEqualToPoint( _currentTouch, CGPointZero ) == NO ) {
			[b arrive:self._currentTouch withEaseDistance:45 usingMultiplier:0.6f]; 
			[b wander:0.2f];
		}
		
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