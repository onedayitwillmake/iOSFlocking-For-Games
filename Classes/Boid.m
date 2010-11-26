
/**
 * Boid.m
 * This is an Objective-C/Cocos2D port of an AS3 Boid behavior class 
 * (original class shown here http://blog.soulwire.co.uk/laboratory/flash/as3-flocking-steering-behaviors)
 * 
 * You can modify this script in any way you choose
 * and use it for any purpose providing this header 
 * remains intact and the original author is credited
 *  
 * Created by Mario Gonzalez on 2/13/10.
 * Copyright 2010 http://onedayitwillmake.com. All rights reserved.
 **/ 
/**		
 * 
 *	Boid v1.00
 *	15/10/2008 11:31
 * 
 *	© JUSTIN WINDLE | soulwire ltd
 *	http://blog.soulwire.co.uk
 *	
 *	Released under the Creative Commons 3.0 license
 *	@see http://creativecommons.org/licenses/by/3.0/
 *	
 *	You can modify this script in any way you choose 
 *	and use it for any purpose providing this header 
 *	remains intact and the original author is credited
 * 
 **/

#import "Boid.h"

#define rad2Deg 57.2957795

#define leftEdge 0.0f
#define bottomEdge 0.0f
#define topEdge 320.0f
#define rightEdge 480.0f

#define IGNORE 1.0f


@implementation Boid
@synthesize maxForce=_maxForce, maxSpeed=_maxSpeed;
@synthesize edgeBehavior=_edgeBehavior;
@synthesize doRotation=_doRotation;
#pragma mark Initialization
- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		self.maxForce = 0.0f;
		self.maxSpeed = 0.0f;
		self.edgeBehavior = EDGE_NONE;
		self.doRotation = false;
		
		_wanderTheta = 0.0f;
		_next = nil;
		
		[self resetVectorsToZero];
		_acceleration = ccp(CCRANDOM_0_1() * 0.5, CCRANDOM_0_1() * 0.5);
		// Debug
		//		[self setSpeedMax: 2.5f andSteeringForceMax: 0.5f];
		//		[self setWanderingRadius:8.0f lookAheadDistance:30.0f andMaxTurningAngle:0.25f];
	}
	return self;
}
-(void) setSpeedMax:(float)speed andSteeringForceMax:(float)force
{
	self.maxSpeed = speed;
	self.maxForce = force;
}

-(void) setSpeedMax:(float)speed withRandomRangeOf:(float)speedRange andSteeringForceMax:(float)force withRandomRangeOf:(float)forceRange
{ 
    [self
     setSpeedMax:randRange(speed - speedRange, speed + speedRange) 
     andSteeringForceMax:randRange(force - forceRange, force + forceRange)];
}

-(void) setWanderingRadius:(float)radius lookAheadDistance:(float)distance andMaxTurningAngle:(float)turningAngle
{
	_wanderMaxTurnCircleRadius = radius;
	_wanderLookAheadDistance = distance;
	_wanderTurningRadius = turningAngle;
}

-(void) resetVectorsToZero
{
	_velocity = CGPointZero;
	_internalPosition = CGPointZero;
	_oldInternalPosition = CGPointZero;
	_acceleration = CGPointZero;
	_steeringForce = CGPointZero;
}

#pragma mark Update
-(void) update
{
	_oldInternalPosition.x = _internalPosition.x;
	_oldInternalPosition.y = _internalPosition.y;
	_velocity = ccpAdd(_velocity, _acceleration);
	
	// Cap the velocity
	float velocityLengthSquared = ccpLengthSQ(_velocity);
	if(velocityLengthSquared > _maxSpeedSQ)
	{
		_velocity = normalize(_velocity);
		_velocity = ccpMult(_velocity, _maxSpeed);
	}
	
	// Move the boid and reset the acceleartion
	_internalPosition = ccpAdd(_internalPosition, _velocity);
	
	if (_doRotation) {
		self.rotation = atan2f(_oldInternalPosition.y-_internalPosition.y, _oldInternalPosition.x-_internalPosition.x ) * -rad2Deg;
	}
	
	_acceleration = CGPointZero;	
	[self handleBorder];
	
	self.position = ccp(_internalPosition.x, _internalPosition.y);
}
-(void) handleBorder
{
	if(_edgeBehavior == EDGE_WRAP)
	{
		if(_internalPosition.x < leftEdge) [self setPos:ccp(rightEdge, CCRANDOM_0_1() * 160 + 30)];
		else if (_internalPosition.y < bottomEdge) [self setPos:ccp(_internalPosition.x, topEdge)];
		else if (_internalPosition.x > rightEdge) [self setPos:ccp(leftEdge, CCRANDOM_0_1() * 160 + 60)];
		else if (_internalPosition.y > topEdge) [self setPos:ccp(_internalPosition.x, bottomEdge)];
	} 
	else if (_edgeBehavior == EDGE_BOUNCE)
	{	
		if(_internalPosition.x < leftEdge) {_internalPosition.x = leftEdge; _velocity.x *= -1.0f;}
		else if (_internalPosition.x > rightEdge) {_internalPosition.x = rightEdge; _velocity.x *= -1.0f;}
		if (_internalPosition.y < bottomEdge) { _internalPosition.y = bottomEdge; _velocity.y *= -1.0f;}
		else if (_internalPosition.y > topEdge) { _internalPosition.y = topEdge; _velocity.y *= -1.0f;}
	}
}

#pragma mark Movement
-(CGPoint) steer:(CGPoint)target easeAsApproaching:(BOOL)ease withEaseDistance:(float)easeDistance
{
	_steeringForce = ccp(target.x, target.y);
	_steeringForce = ccpSub(_steeringForce, _internalPosition);
	
	float distanceSquared = ccpLengthSQ(_steeringForce);
	
	if(distanceSquared > FLT_EPSILON)
	{
		// Slow down or not
		if(ease && distanceSquared < easeDistance * easeDistance) {
			float distance = sqrtf(distanceSquared);
			_steeringForce = ccpMult(_steeringForce, _maxSpeed * (distance/easeDistance) );
		} else {
			_steeringForce = ccpMult(_steeringForce, _maxSpeed);
		}
		
		// Slow down
		_steeringForce = ccpSub(_steeringForce, _velocity);
		
		// Cap
		float steeringForceLengthSquared = ccpLengthSQ(_steeringForce);
		if(steeringForceLengthSquared > _maxForceSQ)
		{
			_steeringForce = normalize(_steeringForce);
			_steeringForce = ccpMult(_steeringForce, _maxForce);
		}
	}
	
	return _steeringForce;
}

-(void) brake:(float)brakingForce
{
	_velocity = ccpMult(_velocity, 1.0f - brakingForce);
}

#pragma mark Behaviors
-(void) seek:(CGPoint)target usingMultiplier:(float)multiplier
{
	_steeringForce = [self steer:target easeAsApproaching:NO withEaseDistance:IGNORE];
	
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}

-(void) seek:(CGPoint)target withinRange:(float)range usingMultiplier:(float)multiplier
{
	float rangeSQ = range * range;
	float distanceSQ = getDistanceSquared(_internalPosition, target);
	
	// we're as close as we want to get 
	if(distanceSQ < rangeSQ) {
		return;
	}
	
	_steeringForce = [self steer:target easeAsApproaching:NO withEaseDistance:IGNORE];
	
	// Pass in zero to ignore mutliplier, is this faster than just doing the operation? I dunno
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}

-(void) arrive:(CGPoint)target withEaseDistance:(float)easeDistance usingMultiplier:(float)multiplier
{
	_steeringForce = [self steer:target easeAsApproaching:YES withEaseDistance:easeDistance];
	
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}



-(void) flee:(CGPoint)target panicAtDistance:(float)panicDistance usingMultiplier:(float)multiplier
{
	float panicDistanceSQ = panicDistance * panicDistance;
	float distanceSQ = getDistanceSquared(_internalPosition, target);
	
	// we're far away enough not to care
	if(distanceSQ > panicDistanceSQ) {
		return;
	}
	
	_steeringForce = [self steer:target easeAsApproaching:YES withEaseDistance:panicDistance];
	
	// Pass in zero to ignore mutliplier, is this faster than just doing the operation? I dunno
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_steeringForce = ccpNeg(_steeringForce);
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}


-(void) wander:(float)multiplier
{
	_wanderTheta += CCRANDOM_MINUS1_1() * _wanderTurningRadius;
	
	// Add our speed to where we are, plus _wanderDistnace ( how far we project ourselves wandering )
	CGPoint futurePosition = ccp(_velocity.x, _velocity.y);
	futurePosition = normalize( futurePosition );
	futurePosition = ccpMult(futurePosition, _wanderLookAheadDistance);
	futurePosition = ccpAdd(futurePosition, _internalPosition);
	
	// move left or right a little
	CGPoint offset = CGPointZero;
	offset.x = _wanderMaxTurnCircleRadius * cosf(_wanderTheta);
	offset.y = _wanderMaxTurnCircleRadius * sinf(_wanderTheta);
	
	// steer to our new random position
	CGPoint target = ccpAdd(futurePosition, offset);
	_steeringForce = [self steer:target easeAsApproaching:NO withEaseDistance:IGNORE];
	
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}

#pragma mark Flocking 
-(void) flock:(Boid*)head withSeparationWeight:(float)separationWeight andAlignmentWeight:(float)alignmentWeight andCohesionWeight:(float)cohesionWeight andSeparationDistance:(float)separationDistance andAlignmentDistance:(float)alignmentDistance andCohesionDistance:(float)cohesionDistance
{
	[self separate:head withSeparationDistance:separationDistance usingMultiplier:separationWeight];
	[self align:head withAlignmentDistance:alignmentDistance usingMultiplier:alignmentWeight];
	[self cohesion:head withNeighborDistance:cohesionDistance usingMultiplier:cohesionWeight];
}

-(void) separate:(Boid*)head withSeparationDistance:(float)separationDistance usingMultiplier:(float)multiplier
{
	CGPoint		force = CGPointZero;
	CGPoint		difference = CGPointZero;
	int			count = 0;
	float		distance;
	float		distanceSQ;
	float		separationDistanceSQ = separationDistance * separationDistance;
	
	
	Boid* node = head;
	while(node)
	{
		Boid* boid = node;
		node = boid->_next;
		
		distanceSQ = getDistanceSquared(_internalPosition, boid->_internalPosition);
		
		if(distanceSQ > 0.1f && distanceSQ < separationDistanceSQ)
		{
			distance = sqrtf(distanceSQ);
			
			difference = ccpSub(_internalPosition, boid->_internalPosition);
			difference = normalize(difference);
			difference = ccpMult(difference, 1.0f / distance );
			
			force = ccpAdd(force, difference);
			count++;
		}
	}
	
	// Average
	if(count > 0)
		force = ccpMult(force, 1.0f / (float) count);
	
	// apply 
	if(multiplier != IGNORE)
		force = ccpMult(force, multiplier);
	
	_acceleration = ccpAdd(_acceleration, force);
}

-(void) align:(Boid*)head withAlignmentDistance:(float)neighborDistance usingMultiplier:(float)multiplier;
{
	CGPoint		force = CGPointZero;
	int			count = 0;
	float		distanceSQ;
	float		neighborDistanceSQ = neighborDistance * neighborDistance;
	
	Boid* node = head;
	while(node)
	{
		Boid* boid = node;
		node = boid->_next;
		
		distanceSQ = getDistanceSquared(_internalPosition, boid->_internalPosition);
		
		if(distanceSQ > 0.1f && distanceSQ < neighborDistanceSQ)
		{			
			force = ccpAdd(force, boid->_velocity);
			count++;
		}	
	}
	
	if(count > 0)
	{
		force = ccpMult(force, 1.0f / (float)count );
		float forceLengthSquared = ccpLengthSQ(force);
		
		if(forceLengthSquared > _maxForceSQ)
		{
			force = normalize(force);
			force = ccpMult(force, _maxForce);
		}
	}
	
	if(multiplier != IGNORE)
		force = ccpMult(force, multiplier);
	
	_acceleration = ccpAdd(_acceleration, force);
}
-(void) cohesion:(Boid*)head withNeighborDistance:(float)neighborDistance usingMultiplier:(float)multiplier
{
	CGPoint		force = CGPointZero;
	int			count = 0;
	float		distanceSQ;
	float		neighborDistanceSQ = neighborDistance * neighborDistance;
	
	Boid* node = head;
	while(node)
	{
		Boid* boid = node;
		node = boid->_next;
		
		distanceSQ = getDistanceSquared(_internalPosition, boid->_internalPosition);
		
		if(distanceSQ > 0.1f && distanceSQ < neighborDistanceSQ)
		{			
			force = ccpAdd(force, boid->_internalPosition);
			count++;
		}	
	}
	
	if(count > 0)
	{
		force = ccpMult(force, (1.0f / (float) count));
		force = [self steer:force easeAsApproaching:NO withEaseDistance:IGNORE];
	}
	
	if(multiplier != IGNORE)
		force = ccpMult(force, multiplier);
	
	_acceleration = ccpAdd(_acceleration, force);
}

#pragma mark Deallocation
- (void) dealloc
{
	_next = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark GETTERS / SETTERS 
- (void) setMaxForce:(float)value
{
	if(value < 0.0f)
		value = 0;
	
	self->_maxForce = value;
	self->_maxForceSQ = value * value;
}
- (void) setMaxSpeed:(float)value
{
	if(value < 0.0f)
		value = 0;
	
	self->_maxSpeed = value;
	self->_maxSpeedSQ = value * value;
}

- (void) setEdgeBehavior:(int)value
{
	if(value != EDGE_WRAP && value != EDGE_BOUNCE) {
		_edgeBehavior = EDGE_NONE;
	}
	
	_edgeBehavior = value;
}

-(void) setPos:(CGPoint)value
{
	self.position = value;
	self->_oldInternalPosition = self->_internalPosition;
	self->_internalPosition = ccp(value.x, value.y);
}

#pragma mark -
#pragma mark Inlined Helper Functions
inline float randRange(float min,float max)
{
	return CCRANDOM_0_1() * (max-min) + min;
}

inline CGPoint normalize(CGPoint point)
{
	float length = sqrtf(point.x*point.x + point.y*point.y);
	if (length < FLT_EPSILON) length = 0.001f; // prevent divide by zero
	
	float invLength = 1.0f / length;
	point.x *= invLength;
	point.y *= invLength;
	
	return point;
}
//#define distanceSquared(__X__, __Y__) ccpLengthSQ( ccpSub(__X__, __Y__) )

inline float getDistanceSquared( CGPoint pointA, CGPoint pointB )
{
	float deltaX = pointB.x - pointA.x;
	float deltaY = pointB.y - pointA.y;
	return (deltaX * deltaX) + (deltaY * deltaY);
}

inline float getDistance( CGPoint pointA, CGPoint pointB )
{
	return sqrtf( getDistanceSquared(pointA, pointB) );
}
@end

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	
	switch( i )
	{
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
	
	*r *= 255;
	*g *= 255;
	*b *= 255;
}