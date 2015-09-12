//
//  MainScene.swift
//  CrossIt
//
//  Created by Otavio Monteagudo on 8/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class MainScene:CCNode {
    
    weak var background:CCSprite!;
    
    weak var background2:CCSprite!;
    
    weak var startGameButton:CCButton!;
    
    weak var chooseFeetButton:CCButton!;
    
    weak var chooseBgButton:CCButton!;
    
    weak var tutorialButton:CCButton!;
    
    var backgroundSprites:[String] = ["River", "Canyon", "Galaxy"];
    
    static var loadingPopover = CCBReader.loadAsScene("Loading");
    
    func didLoadFromCCB() {
        if (Settings.sharedInstance.isFirstLoad) {
            Settings.sharedInstance.isFirstLoad = false;
            
            iAdHandler.sharedInstance.loadAds(bannerPosition: .Top);
            iAdHandler.sharedInstance.loadInterstitialAd();
            
        }
        iAdHandler.sharedInstance.adBannerView.hidden = false;
        MainScene.loadingPopover.position = CGPoint(x: CCDirector.sharedDirector().viewSize().width * 0.5, y: CCDirector.sharedDirector().viewSize().height * 0.5);
        let bg = Int(arc4random_uniform(UInt32(self.backgroundSprites.count)));
        let bgName = self.backgroundSprites[bg];
        let bgIndex = Int(arc4random_uniform(UInt32(3)));
        
        self.background.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + bgName + "/bg" + bgName + "Background4_" + "\(bgIndex)" + ".png");
        self.background2.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/bgs/" + bgName + "/bg" + bgName + "Background4_" + "\((bgIndex + 1) % 3)" + ".png");
        self.background.position.y = 0;
        self.background2.position.y = self.background.contentSize.height - 1;
    }
    
    /* button methods */
    
    func startGame() {
        MainScene.popLoading();
        if (Settings.sharedInstance.isSoundOn) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        if (Settings.sharedInstance.backgroundSpriteIndex != 0) {
            let gameplay = CCBReader.loadAsScene("Gameplay");
            let transition = CCTransition(fadeWithDuration: 0.6);
            CCDirector.sharedDirector().presentScene(gameplay, withTransition: transition);
        } else {
            // saves index for background different than 0 so tutorial scene won't be loaded again at first play.
            Settings.sharedInstance.saveBackgroundIndex(1);
            let transition = CCTransition(fadeWithDuration: 0.3);
            let tutorial = CCBReader.loadAsScene("Tutorial");
            CCDirector.sharedDirector().presentScene(tutorial, withTransition: transition);
        }
    }
    
    func chooseFeet() {
        MainScene.popLoading();
        if (Settings.sharedInstance.isSoundOn) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        var choose = CCBReader.load("Choose") as! Choose;
        choose.chooseFt();
        var scene = CCScene();
        scene.addChild(choose);
        var transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition);
    }
    
    func chooseBg() {
        MainScene.popLoading();
        if (Settings.sharedInstance.isSoundOn) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        var choose = CCBReader.load("Choose") as! Choose;
        choose.chooseBg();
        var scene = CCScene();
        scene.addChild(choose);
        var transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition);
    }
    
    func tutorial() {
        MainScene.popLoading();
        if (Settings.sharedInstance.isSoundOn) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        if (Settings.sharedInstance.backgroundSpriteIndex == 0) {
            Settings.sharedInstance.saveBackgroundIndex(1);
        }
        var tutorial = CCBReader.load("Tutorial") as! Tutorial;
        var scene = CCScene();
        scene.addChild(tutorial);
        var transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition);
    }
    
    /* custom methods */
    
    static func popLoading() {
        CCDirector.sharedDirector().pushScene(MainScene.loadingPopover);
    }
}
