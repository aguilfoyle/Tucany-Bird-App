/***************************************
* Author:	Alan Guilfoyle 
* Project:	Tucany Bird
* File:		GameScene.swift
* 
*
* Created by Alan Guilfoyle on 4/13/15.
* Copyright (c) 2015 Think Thrice Tech. 
* All rights reserved.
***************************************/

// *** IMPORT(S) ***
import SpriteKit



/*******************************************************
* CLASS: GameScene | SUBCLASS: SKScene
* PURPOSE: 
*******************************************************/
class GameScene: SKScene, SKPhysicsContactDelegate
{
	// *** VARIABLE(S) ***
	//UInt32(s)
	let birdCategory: UInt32 = 1 << 0
	let groundCategory: UInt32 = 1 << 1
	let polesCategory: UInt32 = 1 << 2
	//SKSpriteNode(s)
	var bird = SKSpriteNode()
	let sky = SKSpriteNode( imageNamed: "sky" )
	var movingParts = SKNode()
	let poles = SKNode()
	
	
	// MARK - Override Functions
	/*******************************************************
	* FUNC: didMoveToView | PARAM: SKView | RETURN: Void
	* PURPOSE: Called immediately after a scene is presented 
	*		by a view.
	*******************************************************/
    override func didMoveToView( view: SKView ) 
	{
		self.addChild( self.movingParts )
		//Adds the top and bottom pole
		self.movingParts.addChild( self.poles )
		self.physicsWorld.gravity = CGVectorMake( 0, -3 )
		self.physicsWorld.contactDelegate = self
		
		//**************************
		// MARK - Sky Attributes
		//Sky position on screen
		sky.position = CGPoint( x: self.frame.size.width / 2, y: self.frame.size.height / 2 )
		
		//Adding child to scene
		self.addChild( sky )
		
		
		//**************************
		// MARK - Barrier Attributes
		let createPoles = SKAction.runBlock({
			() in self.createPoleBarriers()
		})
		let wait = SKAction.waitForDuration( 3 )
		let createAndWait = SKAction.sequence( [createPoles, wait] )
		let createAndWaitForever = SKAction.repeatActionForever( createAndWait )
		self.runAction( createAndWaitForever )
		
		//**************************
		// MARK - Sky Attributes
		//Sky sprite node
		let groundTexture = SKTexture( imageNamed: "groundPiece" )
		
		//SKAction to move ground on X axis the length of ground
		let groundMovingLeft = SKAction.moveByX( -groundTexture.size().width, y: 0, duration: NSTimeInterval( groundTexture.size().width * 0.015 ))
		
		//SkAction to move ground on X axis back to orginal position
		let resetGround = SKAction.moveByX( groundTexture.size().width, y: 0, duration: 0 )
		
		//Repeat the animation forver of previous 2 SKActions
		let groundMovingLeftForever = SKAction.repeatActionForever( SKAction.sequence( [groundMovingLeft, resetGround] ))
		
		//Loop to create the animation / appreance the ground is moving
		for( var i: CGFloat = 0; i < self.frame.size.width / ( groundTexture.size().width ); ++i )
		{
			let ground = SKSpriteNode( texture: groundTexture )
			ground.position = CGPoint( x: i * ground.size.width, y: ground.size.height / 2 )
			
			//Set animation of ground movement
			ground.runAction( groundMovingLeftForever )
			
			//Setting the ZPosition
			ground.zPosition = 100
			
			//Adding ground child to scene
			self.movingParts.addChild( ground )
		}
		
		
		//**************************
		// MARK - Bird Attributes
		//Bird textures
        let birdTexture1 = SKTexture( imageNamed: "tucan1" )
		let birdTexture2 = SKTexture( imageNamed: "tucan2" )
		let birdTexture3 = SKTexture( imageNamed: "tucan3" )
		
		//Adding an initial texture to Sprite Node
		self.bird = SKSpriteNode( texture: birdTexture1 )
		
		//Creating an SKAction for animation that repeats forever
		let flapAnimation: SKAction = SKAction.animateWithTextures( [birdTexture1, birdTexture2, birdTexture3], timePerFrame: 0.18 )
		let flapForever = SKAction.repeatActionForever( flapAnimation )
		
		//Set animation to Sprite Node
		self.bird.runAction( flapForever )
		
		//Birds position on screen
		self.bird.position = CGPoint( x: self.frame.size.width / 2, y: self.frame.size.height / 2 )
		
		//Setting the ZPosition of the Bird
		self.bird.zPosition = 100
		
		//Adding a physicsbody properties
		self.bird.physicsBody = SKPhysicsBody( circleOfRadius: self.bird.size.height / 2 )
		self.bird.physicsBody?.dynamic = true
		self.bird.physicsBody?.categoryBitMask = self.birdCategory
		self.bird.physicsBody?.contactTestBitMask = self.groundCategory | self.polesCategory
		
		//Adding child to scene
		self.addChild( self.bird )
		
		
		//**************************
		// MARK - Physics Body Ground Attributes
		//Creating invisible ground
		let physicsBodyGround = SKNode()
		
		//Give the invisible ground a physics body
		physicsBodyGround.physicsBody = SKPhysicsBody( rectangleOfSize: CGSizeMake( self.frame.size.width, groundTexture.size().height ))
		
		//Set the position of invisible ground
		physicsBodyGround.position = CGPointMake( 0, groundTexture.size().height / 2 )
		
		//Dynamic is false therefore it's not interactable w/ gravity
		physicsBodyGround.physicsBody?.dynamic = false
		physicsBodyGround.physicsBody?.categoryBitMask = self.groundCategory
		
		//Adding physics body for ground to scene
		self.addChild( physicsBodyGround )
    }
    
	
	
	/*******************************************************
	* FUNC: touchesBegan | PARAM: Set<UITouch>, UIEvent | 
	* RETURN: Void
	* PURPOSE: Tells the receiver when one or more fingers 
	*		touch down in a view or window.
	*******************************************************/
    override func touchesBegan( touches: Set<UITouch>, withEvent event: UIEvent? ) 
	{
		if self.movingParts.speed > 0
		{
			self.bird.physicsBody?.velocity = CGVectorMake( 0, 0 )

			self.bird.physicsBody?.applyImpulse(CGVectorMake( 0, 25 ))
		}
		else
		{
			self.resetGame()
		}
    }
   
	
	
	/*******************************************************
	* FUNC: update | PARAM: CFTimeInterval | RETURN: Void
	* PURPOSE: Performs any scene-specific updates that 
	*		need to occur before scene actions are evaluated.
	*******************************************************/
    override func update( currentTime: CFTimeInterval ) 
	{

	}
	
	
	
	// MARK - Standard Functions
	/*******************************************************
	* FUNC: createPoleBarriers | PARAM: None | RETURN: Void
	* PURPOSE: Creates the barriers that the tucan bird must
	*		avoid. 
	*******************************************************/
	func createPoleBarriers()
	{
		let twinPoles = SKNode()
		var randomForY = CGFloat(arc4random_uniform(15)+1)
		
		//Change y to move both poles up / down
		twinPoles.position = CGPoint( x: self.frame.size.width, y: (( randomForY * 20 ) - 100 ))
		
		
		//**************************
		// MARK - Top Pole Attributes
		//SKSpritenode for the top pole barrier
		let topPole = SKSpriteNode( imageNamed: "tikiTop" )
		topPole.position = CGPoint( x: 0, y: self.frame.size.height )
		
		//Adding PhysicsBody to Top Pole
		topPole.physicsBody = SKPhysicsBody( rectangleOfSize: topPole.size )
		topPole.physicsBody?.dynamic = false
		topPole.physicsBody?.categoryBitMask = self.polesCategory
		
		//Add Top Pole to scene
		twinPoles.addChild( topPole )
		
		
		//**************************
		// MARK - Bottom Pole Attributes
		//SKSpritenode for the bottom pole barrier
		let bottomPole = SKSpriteNode( imageNamed: "tikiBottom" )
		bottomPole.position = CGPoint( x: 0, y: 0 )
		
		//Adding PhysicsBody to Bottom Pole
		bottomPole.physicsBody = SKPhysicsBody( rectangleOfSize: bottomPole.size )
		bottomPole.physicsBody?.dynamic = false
		
		//Add Bottom Pole to scene
		twinPoles.addChild( bottomPole )
		
		
		//**************************
		// MOVE - Animate Poles Attributes
		//Animate the poles: Perform paralax 
		let movingDistance = CGFloat( self.frame.size.width + 2 * topPole.size.width )
		let movePoles = SKAction.moveByX( -movingDistance, y: 0, duration: NSTimeInterval( movingDistance * 0.015 ))
		
		let removePoles = SKAction.removeFromParent()
		let moveAndRemove = SKAction.sequence( [movePoles, removePoles] )
		
		twinPoles.runAction( movePoles )
		
		self.poles.zPosition = 90
		
		self.poles.addChild( twinPoles )
	}
	
	
	
	func didBeginContact( contact: SKPhysicsContact ) 
	{
		self.endGame()
	}
	
	
	func resetGame()
	{
		//Reset the position of the bird
		self.bird.position = CGPoint( x: self.frame.size.width / 2, y: self.frame.size.height / 2 )
		
		//Remove all the pipes
		self.poles.removeAllChildren()
		
		//Set the speed again for the
		self.movingParts.speed = 1
	}
	
	
	
	func endGame()
	{
		if self.movingParts.speed > 0
		{
			self.movingParts.speed = 0
			
			self.bird.physicsBody?.collisionBitMask = self.groundCategory
			
			let hideSky = SKAction.runBlock({()
				in self.sky.hidden = true 
			})
			
			let showSky = SKAction.runBlock({()
				in self.sky.hidden = false 
			})
			
			let whiteBackground = SKAction.runBlock({() 
				in self.backgroundColor = UIColor.whiteColor()
			})
			
			let orangeBackground = SKAction.runBlock({()
				in self.backgroundColor = UIColor.orangeColor()
			})
			
			let wait = SKAction.waitForDuration( 0.06 )
			
			let gameOver = SKAction.sequence( [hideSky, whiteBackground, wait, orangeBackground, wait, whiteBackground, showSky] )
			
			self.runAction( gameOver )
		}
	}
}