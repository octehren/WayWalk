//
//  Rock.swift
//  CrossIt
//
//  Created by Otavio Monteagudo on 7/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Rock:CCNode {
    /* linked objects */
    
    // rock on the right side of Rock node
    weak var rightRock:CCSprite!;
    // rock on the left side of Rock node
    weak var leftRock:CCSprite!;
    
    /* custom variables */
    
    // when instance is loaded, 'side' will determine which side will be the one visible.
    var side:Side = .Both;
    
    /* custom methods */
    
    // will randomly assing a side for the rock. 45% each for left and right, 10% for both.
    func setRockSide() {
        var rand = Int(arc4random_uniform(UInt32(11))); // will generate a number between 0 and 10
        if rand < 5 {
            self.side = .Left;
            self.leftRock.visible = true;
            self.rightRock.visible = false;
        } else if rand < 10 {
            self.side = .Right;
            self.leftRock.visible = false;
            self.rightRock.visible = true;
        } else {
            self.side = .Both;
            self.leftRock.visible = true;
            self.rightRock.visible = true;
        }
    }
    
    func setDynamicRockSprite(background: String) {
        self.leftRock.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/rocks/" + background + "/bg" + background + "LeftRock4.png");
        self.rightRock.spriteFrame = CCSpriteFrame(imageNamed: "ipad/backgrounds/rocks/" + background + "/bg" + background + "RightRock4.png");
    }
}