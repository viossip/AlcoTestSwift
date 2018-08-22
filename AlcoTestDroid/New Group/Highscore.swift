//
//  Highscore.swift
//  AlcoTestDroid
//
//  Created by Vitaly on 8/22/18.
//  Copyright © 2018 AlcoTestDroid. All rights reserved.
//

import Foundation

class Highscore {
    var user: String!
    var type :String!
    var score: String!
    
    init(user : String, type : String, score: String) {
        self.user = user
        self.type = type
        self.score = score
    }
    
    public var description: String { return "+++HighScore: \(self.user)" }
}
