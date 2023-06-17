//
//  User.swift
//  fanfinctionapp
//
//  Created by mac on 17.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import Foundation

struct User {
    var uid: String
    var nickname: String
    var email: String
    var aboutMe: String
    var dateOfBirth: TimeInterval
    var avatarURL: String
    
    init(uid: String, nickname: String, email: String, aboutMe: String, dateOfBirth: TimeInterval, avatarURL: String) {
        self.uid = uid
        self.nickname = nickname
        self.email = email
        self.aboutMe = aboutMe
        self.dateOfBirth = dateOfBirth
        self.avatarURL = avatarURL
    }
}
