//
//  Foot.swift
//  CrossIt
//
//  Created by Otavio Monteagudo on 7/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Foot:CCSprite {
    /* custom variables */
    
    // foot's side
    var side:Side!;
    
    // loads using a string for the side
    func dynamicSpriteLoad(side: String, sprite: String) {
        self.spriteFrame = CCSpriteFrame(imageNamed: "ipad/feet/" + sprite + "/" + side + sprite + "4.png");
    }
    
}