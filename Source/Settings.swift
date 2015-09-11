//
//  Settings.swift
//  CrossIt
//
//  Created by Otavio Monteagudo on 8/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Settings {
    
    // singleton instance to get settings.
    class var sharedInstance:Settings {
        struct Static {
            static let instance : Settings = Settings();
        }
        return Static.instance;
    }
    
    // default settings.
    var isSoundOn:Bool;
    
    var footSpriteIndex:Int;
    
    var backgroundSpriteIndex:Int;
    
    var backgroundSprites:[String] = ["River", "Canyon", "Galaxy"]; // , "Farmfield"];
    
    var footSprites:[String] = ["Tennis", "BlueJeans", "Dragon", "Chicken"];
    
    // returns information about the background being too far away from the player's feet, determining the relative distance moved on each step.
    var bgIsFar:Bool = true;
    // returns information about the two feet sprites being equal or not.
    var identicalFeet:Bool = true;
    // indicates whether or not it is the game's first load. Set to 'false' once ads are loaded.
    var isFirstLoad:Bool = true;
    
    // initializer; loads settings. If settings are not defined, load defaults.
    init() {
        let defaults = NSUserDefaults.standardUserDefaults();
        
        self.backgroundSpriteIndex = defaults.integerForKey("backgroundSpriteIndex");
        
        self.footSpriteIndex = defaults.integerForKey("footSpriteIndex");
        
        let soundOn = defaults.integerForKey("isSoundOn");
        
        if (soundOn == 1) {
            self.isSoundOn = false;
        } else {
            self.isSoundOn = true;
        }
    }
    
    // returns settings.
    
    func getSettings() -> (footSprite: String, backgroundSprite: String) {
        let footSprite = self.footSprites[self.footSpriteIndex];
        // gets background index minus 1, since background index set to 0 will be used to indicate the game's first load.
        let backgroundSprite = self.backgroundSprites[(self.backgroundSpriteIndex + self.backgroundSprites.count - 1) % self.backgroundSprites.count];
        return (footSprite, backgroundSprite);
    }
    
    func getBgsFeetIndexes() -> (backgrounds: [String], feet: [String], bgIndexes: Int, ftIndexes: Int) {
        return (self.backgroundSprites, self.footSprites, (self.backgroundSpriteIndex + self.backgroundSprites.count - 1) % self.backgroundSprites.count, self.footSpriteIndex);
    }
    
    func soundIsOn() -> Bool {
        return self.isSoundOn;
    }
    
    func getBgName() -> String {
        return self.backgroundSprites[(self.backgroundSpriteIndex + self.backgroundSprites.count - 1) % self.backgroundSprites.count];
    }
    
    // saves settings.
    
    func saveBackgroundIndex(bgIndex: Int) {
        self.backgroundSpriteIndex = (bgIndex + 1);
        NSUserDefaults.standardUserDefaults().setInteger(self.backgroundSpriteIndex, forKey: "backgroundSpriteIndex");
        self.hasBgFarFromPlayer();
    }
    
    func saveFootIndex(ftIndex: Int) {
        self.footSpriteIndex = ftIndex;
        NSUserDefaults.standardUserDefaults().setInteger(self.footSpriteIndex, forKey: "footSpriteIndex");
        self.hasTwoIdenticalFeetSprites();
    }
    
    func saveSound(soundOn: Int) {
        if (soundOn == 1) {
            self.isSoundOn = false;
        } else {
            self.isSoundOn = true;
        }
        NSUserDefaults.standardUserDefaults().setInteger(soundOn, forKey: "isSoundOn");
    }
    
    // updates settings.
    
    func hasTwoIdenticalFeetSprites() -> Bool {
        if (self.footSpriteIndex == 1) { // 'BlueJeans'
            return false;
        } else {
            return true;
        }
    }
    
    func hasBgFarFromPlayer() -> Bool {
        // index should never be set to 0 after first play. Index is equivalent to the element's distance from the first element plus one.
        if (self.backgroundSpriteIndex == 1) { // 'River'
            return false;
        } else {
            return true;
        }
    }
    
}