//
//  GameEnd.swift
//  CrossIt
//
//  Created by Otavio Monteagudo on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;
import GameKit;

class GameEnd:CCNode, GKGameCenterControllerDelegate {
    
    /* connected objects */
    
    weak var restartButton:CCButton!;
    weak var twitterButton:CCButton!;
    weak var facebookButton:CCButton!;
    weak var gameCenterButton:CCButton!;
    
    weak var totalScore:CCLabelBMFont!;
    weak var highScore:CCLabelBMFont!;
    
    weak var newBest:CCSprite!;
    
    weak var soundLabel:CCLabelBMFont!;
    
    weak var soundButton:CCButton!;
    /* custom variables */
    
    var currentScore:Int = 0;
    var currentBest:Int = 0;
    
    var soundIsOn:Bool!; // holds value for current sound on.
    var wasSoundOn:Bool!; // holds initial value for sound.
    
    /* cocos2d methods */
    
    func didLoadFromCCB() {
        iAdHandler.sharedInstance.setBannerPosition(bannerPosition: .Top);
        iAdHandler.sharedInstance.adBannerView.hidden = false;
        iAdHandler.sharedInstance.displayBannerAd();
        
        self.soundIsOn = Settings.sharedInstance.soundIsOn();
        self.isSoundOn();
    }
    
    
    /* custom methods */
    
    func isHighscore(score: Int) {
        self.currentScore = score;
        let defaults = NSUserDefaults.standardUserDefaults();
        let highscore:Int? = defaults.integerForKey("highscore");
        if (highscore != nil) {
            self.currentBest = highscore!;
        }
        if (self.currentScore > self.currentBest) {
            self.updateHighscore();
            if (self.soundIsOn == true) {
                OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/congrats.wav");
            }
        }
        self.updateLabels();
    }
    
    func updateHighscore() {
        NSUserDefaults.standardUserDefaults().setInteger(self.currentScore, forKey: "highscore");
        self.currentBest = self.currentScore;
        self.newBest.visible = true;
    }
    
    func updateLabels() {
        self.totalScore.setString("\(self.currentScore)");
        self.highScore.setString("\(self.currentBest)");
    }
    
    func setUpGameCenter() {
        let gameCenterInteractor = GameCenterInteractor.sharedInstance;
        gameCenterInteractor.authenticationCheck();
    }
    
    func isSoundOn() {
        self.wasSoundOn = self.soundIsOn;
        self.soundButton.selected = !self.soundIsOn;
        self.setSoundLabel();
    }
    
    func setSoundLabel() {
        if (self.soundIsOn == true) {
            self.soundLabel.setString("ON");
        } else {
            OALSimpleAudio.sharedInstance().stopAllEffects();
            self.soundLabel.setString("OFF");
        }
    }
    
    func soundChanged() {
        if !(self.soundIsOn == self.wasSoundOn) {
            if (self.soundIsOn == true) {
                Settings.sharedInstance.saveSound(2);
            } else {
                Settings.sharedInstance.saveSound(1);
            }
        }
    }
    
    /* button methods */
    func restart() {
        iAdHandler.sharedInstance.adBannerView.hidden = true;
        self.soundChanged();
        OALSimpleAudio.sharedInstance().stopAllEffects();
        if (self.soundIsOn == true) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        let gameplay = CCBReader.loadAsScene("Gameplay");
        let transition = CCTransition(fadeWithDuration: 0.3);
        CCDirector.sharedDirector().presentScene(gameplay, withTransition: transition);
    }
    
    func gameCenter() {
        if (self.soundIsOn == true) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        self.setUpGameCenter();
        self.reportHighScoreToGameCenter();
        self.showLeaderboard();
    }
    
    func facebook() {
        if (self.soundIsOn == true) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        SharingHandler.sharedInstance.postToFacebook(postWithScreenshot: true);
    }
    
    func twitter() {
        if (self.soundIsOn == true) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        SharingHandler.sharedInstance.postToTwitter(stringToPost: "I've just achieved \(self.currentScore) in WayWalk. Congratulate me or I'll block you.", postWithScreenshot: true);
    }
    
    func sound() {
        self.soundButton.selected = self.soundIsOn;
        self.soundIsOn = !self.soundIsOn;
        if (self.soundIsOn == true) {
            OALSimpleAudio.sharedInstance().playEffect("CrossIt_Sounds/ciStudiosButton.wav");
        }
        self.setSoundLabel();
    }
    
    /* GameKit methods */
    
    func showLeaderboard() {
        var viewController = CCDirector.sharedDirector().parentViewController!;
        var gameCenterViewController = GKGameCenterViewController();
        gameCenterViewController.gameCenterDelegate = self;
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil);
    }
    
    // Delegate methods
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reportHighScoreToGameCenter() {
        var scoreReporter = GKScore(leaderboardIdentifier: "CrossItWayWalk");
        scoreReporter.value = Int64(self.currentBest);// = Int64(GameCenterInteractor.sharedInstance.score);
        var scoreArray: [GKScore] = [scoreReporter];
        
        GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
            if error != nil {
                println("Game Center: Score Submission Error");
            }
        });
    }
}