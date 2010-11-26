//
//  HelloWorldLayer.m
//  BoidsExample
//
//  Created by Mario.Gonzalez on 9/16/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

// Import the interfaces
#import "ObstacleCourseScene.h"

// HelloWorld implementation
@implementation ObstacleCourseScene
@synthesize _flockPointer;
@synthesize _obstaclesPointer;

@synthesize _sheet;
@synthesize _currentTouch;
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ObstacleCourseScene *layer = [ObstacleCourseScene node];
	
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
		
		//[self setColor: ccc3(128, 128, 128)]
		self._sheet = [CCSpriteSheet spriteSheetWithFile:@"blocks.png" capacity:201];
		self.isTouchEnabled = YES;
		self._currentTouch = CGPointZero;
		
		[_sheet setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE}];
		[self addChild:_sheet z:0 tag:0];
		
		// Slightly to the right of the screen so they can never get there (because they're being sent back to the left side when they pass the screen bounds)
		CGPointOfInterest = ccp([[CCDirector sharedDirector] winSize].width + 5, [[CCDirector sharedDirector] winSize].height/2);
		
		[self createRandomObstacles];
		[self createTouchChasingFlock];
		
		[self schedule: @selector(tick:)];
		
	}
	return self;
}

- (void) createRandomObstacles
{
	
}

- (void) createTouchChasingFlock
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CGRect boidRect = CGRectMake(0, 0, 32, 32);
	
	_flockPointer = [Boid spriteWithSpriteSheet:_sheet rect: boidRect];
	Boid *previousBoid = _flockPointer;
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
		
		//boid.doRotation = YES;
		
		// Initialize behavior properties for this boid
		// You want the flock to behavior basically the same, but have a TINY variation among members
		
		//[boid setSpeedMax: 2.0f andSteeringForceMax:1.0f];			
		[boid setSpeedMax: 3.0f withRandomRangeOf:0.5f andSteeringForceMax:1.0f withRandomRangeOf:0.0f];
		boid.maxForce = boid.maxSpeed * 0.8;
		
		[boid setWanderingRadius: 16.0f lookAheadDistance: 40.0f andMaxTurningAngle:0.2f];
		[boid setEdgeBehavior: EDGE_WRAP];
		
		// Cocos properties
		
		[boid setPos: ccp( CCRANDOM_0_1() * screenSize.width,  CCRANDOM_0_1() * screenSize.height)];
		// Color
		[boid setOpacity:128];
		
		float r,g,b;
		HSVtoRGB(&r, &g, &b, (float) i / count * 10.0f + 35.0f, 0.5f + CCRANDOM_0_1()*0.5, 1.0f);
		[boid setColor: ccc3(r,g,b)];
		
		[boid setScale: 0.8 + CCRANDOM_0_1() * 0.4];
		[_sheet addChild:boid];
	}
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
	float center = ([[CCDirector sharedDirector] winSize].height*0.5);
	float radius = 100;
	incriment += 0.01f;
	CGPointOfInterest.y = center+ sinf(incriment) * radius;
	[self updateObstacles:dt];
	[self updateFlock:dt];
}

-(void) updateObstacles:(ccTime)dt
{
	Boid* boid = _obstaclesPointer;
	while(boid)
	{
		Boid* b = boid;
		boid = b->_next;
		[b wander: 1.0f];
		[b update];
	}
}

-(void) updateFlock:(ccTime)dt
{
	Boid* boid = _flockPointer;
	
	while(boid)
	{
		Boid* b = boid;
		boid = b->_next;
		
		//[b wander: 0.45f];
		
		// Go to where the user is touching, OR go to the center of the screen other wise but care less about getting there
		if ( CGPointEqualToPoint( _currentTouch, CGPointZero ) == NO ) [b seek:self._currentTouch usingMultiplier:0.35f]; // go towards touch
	//	else [b seek:CGPointOfInterest usingMultiplier:0.25f]; // go towards center of screen
		
		// Flock
		[b 
		 flock:_flockPointer
		 withSeparationWeight:0.8f
		 andAlignmentWeight:0.00f
		 andCohesionWeight:0.0f
		 andSeparationDistance:15.0f
		 andAlignmentDistance:1.0f
		 andCohesionDistance:1.0f
		 ];
		
		// Flee away from all obstacles
		Boid *nextObstacle = _flockPointer;
		while(nextObstacle)
		{
			Boid *currentObstacle = nextObstacle;
			nextObstacle = currentObstacle->_next;
			
			[b flee:currentObstacle->_internalPosition panicAtDistance:40 usingMultiplier:1.0f];
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