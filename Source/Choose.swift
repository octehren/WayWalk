//  Choose.swift
//  CrossIt
//
//  Created by Otavio Monteagudo on 8/19/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Choose:CCNode {
    
    /* linked objects */
    
    // return to main scene with sprite or background selected
    weak var returnButton:CCButton!;
    // select sprite then return to Gameplay
    weak var selectButton:CCButton!;
    // nodes which contains backgrounds.
    weak var backgroundsNode:CCNode!;
    // second background sprite
    weak var bg1:CCSprite!;
    // third background sprite
    weak var bg2:CCSprite!;
    // sprite frame for background
    weak var backgroundSprite:CCSprite!;
    // left foot sprite
    weak var leftFoot:Foot!;
    // right foot sprite
    weak var rightFoot:Foot!;
    // sprite frame for initial platform
    weak var initialPlatform:CCSprite!;
    // contains rocks
    weak var rocksContainerNode:CCNode!;
    
    /*** custom variables ***/
    
    /* number values */
    
    // records the point which marks the middle of the screen's width
    var halfScreen:CGFloat!;
    // gets number of foot sprites
    var footSpritesNum:Int!;
    // gets number of background sprites
    var bgSpritesNum:Int!;
    
    /* bools */
    
    // adds sound on or off state.
    var soundOn:Bool = true;
    // checks if player is currently looking at different feet sprites
    var isChoosingFeet:Bool!;
    // checks if player is currently looking at different background sprites
    var isChoosingBackground:Bool!;
    
    /* indexes */
    
    // holds indexes for background pictures, allowing randomness when they are loaded.
    var bgIndexes:[Int] = [];
    // index for foot sprite
    var footIndex:Int = 0;
    // index for background sprite
    var backgroundIndex:Int = 0;
    // index for current sprite.
    var spriteIndex:Int!;
    
    /* sprite collections */
    
    // bgs
    var backgroundSprites:[String] = [];
    // feet
    var footSprites:[String] = [];
    // rocks
    var rocks:[Rock] = [];
    // actual foot/bg images.
    var spriteFrames:[[CCSpriteFrame]] = [];
    
    /* methods */
    
    // will be substitued by either leftChooseFeet or leftChooseBg
    var tapLeft:(() -> Void)!;
    
    // will be substitued by either rightChooseFeet or rightChooseBg
    var tapRight:(() -> Void)!;
    
    /* cocos2d methods */
    
    func didLoadFromCCB() {
        var settings = Settings.sharedInstance.getBgsFeetIndexes();
        self.backgroundSprites = settings.backgrounds;
        self.footSprites = settings.feet;
        self.backgroundIndex = settings.bgIndexes;
        self.footIndex = settings.ftIndexes;
        
        self.soundOn = Settings.sharedInstance.soundIsOn();
        
        var rock:Rock!;
        var yPosition:CGFloat;
        
        for i in 0..<2 {
            rock = CCBReader.load("Rock") as! Rock; // loads 'Rock.ccb' as a Rock class instance
            //rock.setRockSide(); // makes a steppable rock at left, right or both sides.
            yPosition = rock.contentSizeInPoints.height * CGFloat(i); // position element's bottom-left point according to its parent node's position. First will be 0, second will be rock's height, etc
            rock.position = CGPoint(x:0, y: yPosition); // updates 'rock' position attribute
            rock.setRockSide();
            self.rocksContainerNode.addChild(rock); // sets rock to have its position relative to self.rocksContainerNode
            self.rocks.append(rock);
        }
        
        self.randomizeBgPics();
        self.setUpRelativePositions();
        
        /*self.leftFoot.dynamicSpriteLoad("left", sprite: self.footSprites[self.footIndex]);
        self.rightFoot.dynamicSpriteLoad("right", sprite: self.footSprites[self.footIndex]);*/
        
        self.leftFoot.dynamicSpriteLoad("left", sprite: self.footSprites[self.footIndex]);
        self.rightFoot.dynamicSpriteLoad("right", sprite: self.footSprites[self.footIndex]);
        self.dynamicBackgroundLoad();
    }
    
    override func onEnter() {
        super.onEnter();
        if (self.isChoosingFeet == true) {
            tapLeft = leftChooseFeet;
            tapRight = rightChooseFeet;
            var ft1:CCSpriteFrame;
            var ft2:CCSpriteFrame;
            for i in 0..<self.footSprites.count {
                //ft1 = CCSpriteFrame();
                //ft2 = CCSpriteFrame();
                ft1 = CCSpriteFrame(imageNamed: "ipad/feet/" + self.footSprites[i] + "/left" + self.footSprites[i] + "4.png");
                ft2 = CCSpriteFrame(imageNamed: "ipad/feet/" + self.footSprites[i] + "/right" + self.footSprites[i] + "4.png");
                self.spriteFrames.append([ft1, ft2]);
            }
        } else if (self.isChoosingBackground == true) {
            tapLeft = leftChooseBg;
            tapRight = rightChooseBg;
            var bg1:CCSpriteFrame;
            var bg2:CCSpriteFrame;
            for i in 0..<self.backgroundSprites.count {
                bg1 = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + self.backgroundSprites[i] + "/bg" + self.backgroundSprites[i] + "Background4_\(self.bgIndexes[0]).png");
                bg2 = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + self.backgroundSprites[i] + "/bg" + self.backgroundSprites[i] + "Background4_\(self.bgIndexes[1]).png");
                self.spriteFrames.append([bg1, bg2]);
            }
        }
        self.userInteractionEnabled = true;
        self.selectButton.userInteractionEnabled = true;
        self.returnButton.userInteractionEnabled = true;
    }
    
    // triggered once a touch is detected on the screen.
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (touch.locationInWorld().y <= CCDirector.sharedDirector().viewSize().height * 0.8) {
            if (touch.locationInWorld().x <= self.halfScreen) {
                self.tapLeft();
            } else {
                self.tapRight();
            }
        }
        if (self.soundOn) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/walk.wav");
        }
    }
    
    /* button methods */
    
    // return button
    func goBack() {
        if (self.soundOn) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        self.returnToMainScene();
    }
    
    // select button
    func selectSprites() {
        if (self.soundOn) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        if (self.isChoosingBackground == true) {
            Settings.sharedInstance.saveBackgroundIndex(self.backgroundIndex);
        } else {
            Settings.sharedInstance.saveFootIndex(self.footIndex);
        }
        self.returnToMainScene();
    }
    
    /* custom methods */
    
    
    func leftChooseFeet() -> Void {
        let footIndex = (self.footIndex + (self.footSprites.count - 1)) % self.footSprites.count;
        self.footIndex = footIndex;
        /*self.leftFoot.dynamicSpriteLoad("left", sprite: self.footSprites[self.footIndex]);
        self.rightFoot.dynamicSpriteLoad("right", sprite: self.footSprites[self.footIndex]);*/
        self.leftFoot.spriteFrame = self.spriteFrames[footIndex][0];
        self.rightFoot.spriteFrame = self.spriteFrames[footIndex][1];
    }
    
    func leftChooseBg() -> Void {
        self.backgroundIndex = (self.backgroundIndex + (self.backgroundSprites.count - 1)) % self.backgroundSprites.count;
        self.backgroundSprite.spriteFrame = self.spriteFrames[self.backgroundIndex][0];
        self.bg1.spriteFrame = self.spriteFrames[self.backgroundIndex][1];
        
        self.initialPlatform.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/platforms/" + self.backgroundSprites[self.backgroundIndex] + "/bg" + self.backgroundSprites[self.backgroundIndex] + "Platform4.png");
        for i in 0..<self.rocks.count {
            self.rocks[i].setDynamicRockSprite(self.backgroundSprites[self.backgroundIndex]);
        }
    }
    
    func rightChooseFeet() -> Void {
        self.footIndex = (self.footIndex + 1) % self.footSprites.count;
        /*self.leftFoot.dynamicSpriteLoad("left", sprite: self.footSprites[self.footIndex]);
        self.rightFoot.dynamicSpriteLoad("right", sprite: self.footSprites[self.footIndex]);*/
        self.leftFoot.spriteFrame = self.spriteFrames[footIndex][0];
        self.rightFoot.spriteFrame = self.spriteFrames[footIndex][1];
    }
    
    func rightChooseBg() -> Void {
        self.backgroundIndex = (self.backgroundIndex + 1) % self.backgroundSprites.count;
        self.backgroundSprite.spriteFrame = self.spriteFrames[self.backgroundIndex][0];
        self.bg1.spriteFrame = self.spriteFrames[self.backgroundIndex][1];
        
        self.initialPlatform.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/platforms/" + self.backgroundSprites[self.backgroundIndex] + "/bg" + self.backgroundSprites[self.backgroundIndex] + "Platform4.png");
        for i in 0..<self.rocks.count {
            self.rocks[i].setDynamicRockSprite(self.backgroundSprites[self.backgroundIndex]);
        }
    }
    
    // loads background details such as rock, rock details, initial platform and background sprite.
    func dynamicBackgroundLoad() {
        let background = self.backgroundSprites[self.backgroundIndex];
        self.initialPlatform.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/platforms/" + background + "/bg" + background + "Platform4.png");
        
        self.backgroundSprite.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + background + "/bg" + background + "Background4_" + "\(self.bgIndexes[0])" + ".png");
        //self.backgroundSprite.spriteFrame = self.spriteFrames[self.backgroundIndex][0];
        /* commented part was moved to furtherLoadBackgrounds() method. */
        self.bg1.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + background + "/bg" + background + "Background4_" + "\(self.bgIndexes[1])" + ".png");
        //self.bg1.spriteFrame = self.spriteFrames[self.backgroundIndex][1];
        self.backgroundSprite.position.y = 0;
        
        self.bg1.position.y = self.backgroundSprite.contentSize.height - 1;
        for i in 0..<self.rocks.count {
            self.rocks[i].setDynamicRockSprite(background);
        }
        //self.checkBgDistance(background);
    }
    
    func randomizeBgPics() {
        var indexes = [0,1,2];
        var rand:Int;
        rand = Int(arc4random_uniform(UInt32(3))); // generates a random int between 0 and 2.
        self.bgIndexes.append(indexes[rand]);
        indexes.removeAtIndex(rand);
        
        rand = Int(arc4random_uniform(UInt32(2)));
        self.bgIndexes.append(indexes[rand]);
    }
    
    func setUpRelativePositions() {
        // feet positions
        self.rightFoot.position.x = CCDirector.sharedDirector().viewSize().width * 0.55;
        self.leftFoot.position.x = CCDirector.sharedDirector().viewSize().width * 0.45;
        
        // rock positions
        self.rocksContainerNode.position.x = CCDirector.sharedDirector().viewSize().width * 0.5;
        
        // background positions
        self.backgroundSprite.position.y = 0;
        self.bg1.position.y = self.backgroundSprite.contentSize.height - 1;
        //self.bg2.position.y = (self.backgroundSprite.contentSize.height * 2) - 2;
        self.initialPlatform.position.x = CCDirector.sharedDirector().viewSize().width * 0.5;
        
        /*self.bmfScore.position = CGPoint(x: CCDirector.sharedDirector().viewSize().width * 0.5, y: CCDirector.sharedDirector().viewSize().height * 0.5);
        self.bmfScore.visible = true;
        // button positions
        self.chooseFeetButton.position.y = CCDirector.sharedDirector().viewSize().height; // * 0.05;
        self.returnButton.position.y = CCDirector.sharedDirector().viewSize().height; //.width * 0.05;
        self.chooseBackgroundButton.position.y = CCDirector.sharedDirector().viewSize().height;
        self.selectButton.position.y = CCDirector.sharedDirector().viewSize().height;
        self.optionsButton.position.y = CCDirector.sharedDirector().viewSize().height;*/
        
    }
    
    func returnToMainScene() {
        let mainScene = CCBReader.loadAsScene("MainScene");
        let transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(mainScene, withTransition: transition);
    }
    
    func chooseFt() {
        self.isChoosingFeet = true;
        self.isChoosingBackground = false;
    }
    
    func chooseBg() {
        self.isChoosingFeet = false;
        self.isChoosingBackground = true;
    }
}