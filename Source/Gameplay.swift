import Foundation;

// determines which side of the river the rock will be visible (and steppable);
enum Side {
    case Left, Right, Both;
}

class Gameplay:CCNode {
    /* linked objects */
    
    // container of Rock instances,will actually display them.
    weak var rocksContainerNode:CCNode!;
    // left foot sprite
    weak var leftFoot:Foot!;
    // right foot sprite
    weak var rightFoot:Foot!;
    // sprite for initial platform both feet are standing on
    weak var initialPlatform:CCSprite!;
    // sprite for splash, invisible by default, to be triggered in gameOver.
    weak var splash:CCSprite!;
    // left hand pointing to next steppable platform
    weak var leftSideHand:CCSprite!;
    //right hand pointing to next steppable platform
    weak var rightSideHand:CCSprite!;
    // label to present score.
    weak var bmfScore:CCLabelBMFont!;
    // sprite frame for background
    weak var backgroundSprite:CCSprite!;
    // nodes which contains backgrounds.
    weak var backgroundsNode:CCNode!;
    // second background sprite
    weak var bg1:CCSprite!;
    // third background sprite
    weak var bg2:CCSprite!;
    // indicates time left until player slips.
    weak var lifeBar:CCSprite!;
    // borders this time left.
    weak var lifeBarBorder:CCSprite!;
    // motivational label popping up
    //weak var motivationalLabel:CCLabelBMFont!;
    // goes back to main scene
    weak var backButton:CCButton!;
    // indicates that either the left or the right rock can be tapped (not both).
    weak var orIndicator:CCSprite!;
    
    /*** custom variables ***/
    
    /* arrays, strings, enums & bools */
    
    // array of Rock instances; will act as a queue, removing an instance that has gone under the bottom of the screen, processing it to rearrange rock's position (and waves too) and then placing it on the queue's last position to be displayed again, saving processing power.
    var rocks:[Rock] = [];
    // array for selecting background sprite. Once game starts, index is utilized to dynamically set background positions.
    var backgrounds:[CCSprite] = [];
    // adds random sentences popping up
    //var motivational:[String] = ["OMFGGG", "WOPS!", "Did you just lose?", "ALMOST!"];
    // foot that is currently walking
    var activeSide:Side!;
    
    /* number values */
    
    // keeps track of current score.
    var currentScore:CGFloat = 0;
    // keeps track of current score, used to update label value.
    var currentIntScore:Int = 0;
    // slip ratio to divide current score and make slipping faster. The bigger this value, the slower the slipping.
    let slippingRatio:CGFloat = 30;
    // keeps track of total distance slipped to be compensated for on next step AND track game over.
    var distSlippedY:CGFloat = 0;
    // keeps track of total distance slipped horizontally
    var distSlippedX:CGFloat = 0;
    // records the point which marks the middle of the screen's width
    let halfScreen:CGFloat = CCDirector.sharedDirector().viewSize().width / 2;
    // sets value of a rock height;
    var rockHeight:CGFloat!;
    // stores value for background height (must be bigger than or equal to screen height)
    var minusBackgroundHeight:CGFloat!;
    // distance that background moves at every step.
    var bgDist:CGFloat!;
    // calculates rocksContainerNode total height, places instance at the top.
    var yDiff:CGFloat!;
    // indicates time until player slips
    var timeLeft: Float = 10 {
        didSet {
            self.timeLeft = max(min(self.timeLeft, 10), 0);
            self.lifeBar.scaleX = self.timeLeft / Float(10);
        }
    }
    
    /* indexes */
    
    // current bg index.
    var backgroundIndex:Int = 0;
    // keeps track of the index of current Rock instance at the bottom of rocksContainerNode inside rocks array.
    var currentRockIndex:Int = 0;
    
    /*  closures */
    
    // will be substitued by leftSideStart and then by leftStep.
    var tapLeft:(() -> Void)!;
    // will be substitued by rightSideStart and then by rightStep.
    var tapRight:(() -> Void)!;
    
    // will be substitued by either moveBackgrounds or moveBackgroundsWithStepSound.
    var moveBg:(() -> Void)!;
    
    var isGameOver:(() -> Bool)!;
    
    
    
    /* cocos2d methods */
    
    // loads objects and applies logic for Gameplay, executed automatically when Gameplay is just to be rendered.
    func didLoadFromCCB() {
        let settings = Settings.sharedInstance.getSettings();
        
        tapLeft = initGame;
        tapRight = initGame;
        isGameOver = checkForGameOverInFirstStep;
        iAdHandler.sharedInstance.adBannerView.hidden = true;
        
        self.rightFoot.dynamicSpriteLoad("right", sprite: settings.footSprite);
        self.leftFoot.dynamicSpriteLoad("left", sprite: settings.footSprite);
        
        if (Settings.sharedInstance.soundIsOn()) {
            moveBg = moveBackgroundsWithStepSound;
        } else {
            moveBg = moveBackgrounds;
        }
        
        // adds side for each foot
        self.rightFoot.side = .Right;
        self.leftFoot.side = .Left;
        
        var rock:Rock!;
        
        var yPosition:CGFloat;
        for i in 0..<6 {
            rock = CCBReader.load("Rock") as! Rock; // loads 'Rock.ccb' as a Rock class instance
            yPosition = rock.contentSizeInPoints.height * CGFloat(i); // position element's bottom-left point according to its parent node's position. First will be 0, second will be rock's height, etc
            rock.position = CGPoint(x:0, y: yPosition); // updates 'rock' position attribute
            self.rocksContainerNode.addChild(rock); // sets rock to have its position relative to self.rocksContainerNode
            self.rocks.append(rock);
            self.rocks[i].setRockSide(); // makes a steppable rock at left, right or both sides.
            self.rocks[i].setDynamicRockSprite(settings.backgroundSprite);
        }
        // appends background sprites to backgrounds array
        self.backgrounds.append(self.backgroundSprite);
        self.backgrounds.append(self.bg1);
        self.backgrounds.append(self.bg2);
        self.minusBackgroundHeight = -self.backgroundSprite.contentSize.height;
        self.rockHeight = rock.contentSizeInPoints.height;
        self.yDiff = self.rocks[0].contentSize.height * CGFloat(self.rocks.count);
        
        self.dynamicBackgroundLoad(settings.backgroundSprite);
        
        /***   relative positioning for different screen sizes:   ***/
        
        self.setUpRelativePositions();
        
        // sets up visibility of initial hands.
        if (self.rocks[0].side != .Both) {
            if (self.rocks[0].side == .Left) {
                self.leftSideHand.visible = true;
            } else {
                self.rightSideHand.visible = true;
            }
        } else {
            self.rightSideHand.visible = true;
            self.leftSideHand.visible = true;
            self.orIndicator.visible = true;
        }
        
        //self.userInteractionEnabled = true;
        
        self.animationManager.runAnimationsForSequenceNamed("hands");
    }
    
    override func onEnter() {
        super.onEnter();
        self.userInteractionEnabled = true;
    }
    
    /* future-assign methods */
    
    func initGame() {
        self.startGame();
        tapLeft = leftStep;
        tapRight = rightStep;
        self.rightSideHand.visible = false;
        self.leftSideHand.visible = false;
        self.orIndicator.visible = false;
        self.backButton.visible = false;
        self.backButton.userInteractionEnabled = false;
    }
    
    func leftStep() {
        if (self.rightFoot.position.y > 0) {
            self.rightFoot.runAction(CCActionMoveBy(duration: 0.05, position: CGPoint(x: -self.distSlippedX, y: -2 * self.rockHeight + self.distSlippedY)));
            self.leftFoot.runAction(CCActionMoveBy(duration: 0.05, position: CGPoint(x: 0, y: 2 * self.rockHeight)));
        } else {
            self.leftFoot.runAction(CCActionMoveBy(duration: 0.01, position: CGPoint(x: self.distSlippedX, y: self.distSlippedY)));
        }
    }
    
    func rightStep() {
        if (self.leftFoot.position.y > 0) {
            self.leftFoot.runAction(CCActionMoveBy(duration: 0.05, position: CGPoint(x: self.distSlippedX, y: -2 * self.rockHeight + self.distSlippedY)));
            self.rightFoot.runAction(CCActionMoveBy(duration: 0.05, position: CGPoint(x: 0, y: 2 * self.rockHeight)));
        } else {
            self.rightFoot.runAction(CCActionMoveBy(duration: 0.01, position: CGPoint(x: -self.distSlippedX, y: self.distSlippedY)));
        }
    }
    
    // moves and checks current background position and changes their positions if necessary.
    func moveBackgrounds() {
        self.backgroundsNode.runAction(CCActionMoveBy(duration: 0.1, position: CGPoint(x: 0, y: self.bgDist)));
        
        if (self.convertToNodeSpace(self.backgroundsNode.convertToWorldSpace(self.backgrounds[self.backgroundIndex].position)).y <= self.minusBackgroundHeight) {
            self.changeBackgrounds();
        }
    }
    
    // moves and checks current background position and changes their positions if necessary.
    func moveBackgroundsWithStepSound() {
        self.backgroundsNode.runAction(CCActionMoveBy(duration: 0.1, position: CGPoint(x: 0, y: self.bgDist)));
        OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/walk.wav");
        
        if (self.convertToNodeSpace(self.backgroundsNode.convertToWorldSpace(self.backgrounds[self.backgroundIndex].position)).y <= self.minusBackgroundHeight) {
            self.changeBackgrounds();
        }
    }
    
    func checkForGameOver() -> Bool {
        var rock = self.rocks[self.currentRockIndex];
        // moves node down by the rock height
        var moveRocksContainerDown = CCActionMoveBy(duration: 0.1, position: CGPoint(x: 0, y: -self.rockHeight));
        self.rocksContainerNode.runAction(moveRocksContainerDown);
        rock.position = ccpAdd(rock.position, CGPoint(x:0, y: self.yDiff)); // moves to top of tower
        rock.setRockSide();
        self.currentRockIndex = (self.currentRockIndex + 1) % self.rocks.count;
        if (self.activeSide != self.rocks[self.currentRockIndex].side) {
            if (self.rocks[self.currentRockIndex].side != .Both) {
                return true;
            }
        }
        return false;
    }
    
    func checkForGameOverInFirstStep() -> Bool {
        isGameOver = checkForGameOver;
        if !(self.activeSide == self.rocks[0].side || self.rocks[0].side == .Both) {
            return true;
        } else {
            return false;
        }
    }
    
    /* button methods */
    
    func returnToMainScene() {
        OALSimpleAudio.sharedInstance().stopAllEffects();
        if (Settings.sharedInstance.isSoundOn) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        
        let mainScene = CCBReader.loadAsScene("MainScene");
        let transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(mainScene, withTransition: transition);
    }
    
    /* custom methods */
    
    func startGame() {
        self.schedule("slip", interval: 1.0 / 60.0);
        self.lifeBarBorder.visible = true;
        self.lifeBar.visible = true;
        self.lifeBar.zOrder = -1;
        if (Settings.sharedInstance.hasBgFarFromPlayer()) {
            self.bgDist = -CCDirector.sharedDirector().viewSize().height / 20;
        } else {
            // initial step only, actual first movement will be of 0.35 * screenHeight when counted distance dellocated with moveBackgrounds method.
            self.backgroundsNode.runAction(CCActionMoveBy(duration: 0.1, position: CGPoint(x: 0, y: -CCDirector.sharedDirector().viewSize().height * 0.35 + self.rockHeight)));
            // after initial step:
            self.bgDist = -self.rockHeight;
        }
        self.initialPlatform.visible = false;
        
        // moves down screen to place the first-step on the first rock.
        self.rocksContainerNode.runAction(CCActionMoveBy(duration: 0.1, position: CGPoint(x: 0, y: -CCDirector.sharedDirector().viewSize().height * 0.35)));
        
        // moves first either left or right food depending on which side of the screen was touched initially.
        if (self.activeSide == .Right) {
            self.leftFoot.runAction(CCActionMoveBy(duration: 0.05, position: CGPoint(x: 0, y: -2 * self.rockHeight)));
        } else {
            self.rightFoot.runAction(CCActionMoveBy(duration: 0.05, position: CGPoint(x: 0, y: -2 * self.rockHeight)));
        }
        
        // makes score label visible.
        self.bmfScore.visible = true;
        
        // 'play' sequence has no background movements, which could help to slightly improve performance.
        animationManager.runAnimationsForSequenceNamed("play");
    }
    
    // moves rocksContainerNode down on screen, puts past rock at the top of the container node, animates feet
    func walkOnLake() {
        /* rock-moving code transferred to 'checkForGameOver' method. */
        if (self.isGameOver()) {
            self.triggerGameOver();
        } else {
            self.currentScore += 1;
            self.currentIntScore += 1;
        }
        self.bmfScore.setString("\(self.currentIntScore)");
        
        // sets time to slip to maximum.
        self.timeLeft = 10;
        
        /*if (Int(arc4random_uniform(UInt32(10))) < 7) {
        self.popMotivational();
        }*/
    }
    
    // pauses the game state, breaking current play. Adds a splash to the location of last step taken. Spawns restart button.
    func triggerGameOver() {
        self.unschedule("slip");
        self.userInteractionEnabled = false;
        self.leftFoot.visible = false;
        self.rightFoot.visible = false;
        self.lifeBar.visible = false;
        self.lifeBarBorder.visible = false;
        
        if (Settings.sharedInstance.soundIsOn()) {
            let sounds = OALSimpleAudio.sharedInstance();
            sounds.playEffect("CrossIt_Sounds/scream.wav");
            sounds.playEffect("CrossIt_Sounds/splash" + Settings.sharedInstance.getBgName() + ".wav");
        }
        if (self.activeSide == .Right) {
            // checks if right foot was the one currently on the screen. If it wasn't, y position of splash is assigned to left foot.
            if (self.rightFoot.position.y > 0) {
                self.splash.position.y = self.rightFoot.position.y - self.rockHeight;
            } else {
                self.splash.position.y = self.leftFoot.position.y - self.rockHeight;
            }
            self.splash.position.x = self.rightFoot.position.x + CCDirector.sharedDirector().viewSize().width * 0.25;
        } else {
            // same as above, for left foot.
            if (self.leftFoot.position.y > 0) {
                self.splash.position.y = self.leftFoot.position.y - self.rockHeight;
            } else {
                self.splash.position.y = self.rightFoot.position.y - self.rockHeight;
            }
            self.splash.position.x = self.leftFoot.position.x - CCDirector.sharedDirector().viewSize().width * 0.25;
        }
        self.splash.visible = true;
        
        // slipping (which increments different variables and etc) has its execution cycle interrupted.
        self.schedule("displayGameOver", interval: 30.0 / 60.0);
    }
    
    func slip() {
        if (self.distSlippedY > 90) {
            self.triggerGameOver();
        }
        let slip = 1 + (self.currentScore/self.slippingRatio);
        
        if (self.activeSide == .Left) {
            self.leftFoot.runAction(CCActionMoveBy(duration: 0.1, position: CGPoint(x: -0.3, y: -(slip))));
        } else {
            self.rightFoot.runAction(CCActionMoveBy(duration: 0.1, position: CGPoint(x: 0.3, y: -(slip))));
        }
        self.distSlippedY = self.distSlippedY + slip;
        self.distSlippedX = self.distSlippedX + 0.3;
        
        self.timeLeft = Float((90 - self.distSlippedY) / 90) * 10;
    }
    
    func displayGameOver() {
        self.unschedule("displayGameOver");
        iAdHandler.sharedInstance.displayInterstitialAd();
        var gameEndPopover = CCBReader.load("GameEnd") as! GameEnd;
        gameEndPopover.position = CGPoint(x: CCDirector.sharedDirector().viewSize().width * 0.5, y: CCDirector.sharedDirector().viewSize().height * 0.5)
        gameEndPopover.zOrder = 9999;
        gameEndPopover.isHighscore(self.currentIntScore);
        self.addChild(gameEndPopover);
        self.backButton.visible = true;
        self.backButton.userInteractionEnabled = true
        self.backButton.zOrder = 10000;
    }
    
    // loads background details such as rock, rock details, initial platform and background sprite.
    func dynamicBackgroundLoad(background: String) {
        var bgIndexes = self.randomizeBgPics();
        
        self.initialPlatform.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/platforms/" + background + "/bg" + background + "Platform4.png");
        
        // adds images to bg frames.
        self.backgroundSprite.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + background + "/bg" + background + "Background4_" + "\(bgIndexes.0)" + ".png");
        self.bg1.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + background + "/bg" + background + "Background4_" + "\(bgIndexes.1)" + ".png");
        self.bg2.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + background + "/bg" + background + "Background4_" + "\(bgIndexes.2)" + ".png");
        
        self.splash.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/details/" + background + "/bg" + background + "Splash4.png");
        
        self.lifeBar.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/details/" + background + "/lifeBar.png");
        self.lifeBarBorder.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/details/" + background + "/lifeBarBorder.png");
    }
    
    /* iOS methods */
    
    // triggered once a touch is detected on the screen.
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        // right foot moves
        if (touch.locationInWorld().x >= self.halfScreen) {
            self.activeSide = .Right;
            self.tapRight();
            // left foot moves
        } else {
            self.activeSide = .Left;
            self.tapLeft();
        }
        
        // resets distance that foot slipped from rock.
        self.distSlippedY = 0;
        self.distSlippedX = 0;
        self.moveBg();
        self.walkOnLake();
    }
    
    // switch background positions.
    func changeBackgrounds() {
        self.backgrounds[self.backgroundIndex].position.y += -3 * self.minusBackgroundHeight - 3;
        self.backgroundIndex = (self.backgroundIndex + 1) % self.backgrounds.count;
    }
    
    // sets up relative positioning for all moving sprites.
    func setUpRelativePositions() {
        // feet positions
        self.rightFoot.position.x = CCDirector.sharedDirector().viewSize().width * 0.55;
        self.leftFoot.position.x = CCDirector.sharedDirector().viewSize().width * 0.45;
        
        // rock positions
        self.rocksContainerNode.position.x = CCDirector.sharedDirector().viewSize().width * 0.5;
        
        // background positions
        self.backgroundSprite.position.y = 0;
        self.bg1.position.y = self.backgroundSprite.contentSize.height - 1;
        self.bg2.position.y = (self.backgroundSprite.contentSize.height * 2) - 2;
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
    
    func randomizeBgPics() -> (Int, Int, Int) {
        var indexes = [0,1,2];
        var bgIndexes:[Int] = [];
        var rand:Int;
        
        rand = Int(arc4random_uniform(UInt32(3))); // generates a random int between 0 and 2.
        bgIndexes.append(indexes[rand]);
        indexes.removeAtIndex(rand);
        
        rand = Int(arc4random_uniform(UInt32(2)));
        bgIndexes.append(indexes[rand]);
        indexes.removeAtIndex(rand);
        
        bgIndexes.append(indexes[0]);
        
        return (bgIndexes[0], bgIndexes[1], bgIndexes[2]);
    }
    
    /*func popMotivational() {
    var rand = Int(arc4random_uniform(UInt32(self.motivational.count)));
    self.motivationalLabel.setString(self.motivational[rand]);
    self.motivationalLabel.position.y = CCDirector.sharedDirector().viewSize().height;
    self.motivationalLabel.visible = true;
    //self.motivationalLabel.runAction(CCActionMoveBy(duration: 0.3, position: CGPoint(x: 0, y: 200)));
    //self.runAction(CCActionDelay(duration: 0.3));
    //self.motivationalLabel.visible = false;
    println("popped");
    }*/
}