//
//  User.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-31.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation

class User {
    static var username: String = "";
    static var isAuthenticated: Bool = false;
    static var hasSeenTutorial: Bool = false;
    
    static func login(_ user: String) {
        username = user;
        isAuthenticated = true;
    }
    
    static func loginOffline() {
        self.username = "";
        self.isAuthenticated = false;
    }
    
    static func logout() {
        username = "";
        isAuthenticated = false;
    }
    
    static func setUsername(_ user: String) {
        username = user;
    }
    
    //MARK: getters
    
    static func getUsername() -> String {
        return self.username;
    }
}
