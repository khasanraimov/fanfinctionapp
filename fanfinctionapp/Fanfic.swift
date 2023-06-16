//
//  Fanfic.swift
//  fanfinctionapp
//
//  Created by mac on 15.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import Foundation
import Firebase

struct Fanfic: Decodable {
    
    var key: String?
    var title: String?
    var description: String?
    var imageURL: String?
    var author: String?
    var text: String?
    var category: String?
    var likesCount: Int
    var commentsCount: Int
    var repostCount: Int
    var rating: Double
    var authorName: String?
    var likedBy: [String]
    let publicationDate: Date
    
    init?(data: [String:Any]?) {
        guard let data = data else { return nil }
        key = data["key"] as? String
        title = data["title"] as? String
        description = data["description"] as? String
        imageURL = data["imageURL"] as? String
        author = data["author"] as? String
        text = data["text"] as? String
        category = data["category"] as? String
        likesCount = data["likes_count"] as? Int ?? 0
        commentsCount = data["comments_count"] as? Int ?? 0
        repostCount = data["repost_count"] as? Int ?? 0
        rating = data["rating"] as? Double ?? 0.0
        authorName = data["authorName"] as? String
        likedBy = data["likedBy"] as? [String] ?? []
        if let dateString = data["publicationDate"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            publicationDate = formatter.date(from: dateString) ?? Date()
        } else {
            publicationDate = Date()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case description
        case imageURL = "image_url"
        case author
        case text
        case category
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case repostCount = "repost_count"
        case rating
        case authorName
        case likedBy
        case publicationDate
    }
    
    init(dict: [String: Any]) {
        key = dict["key"] as? String
        title = dict["title"] as? String
        description = dict["description"] as? String
        imageURL = dict["image_url"] as? String
        author = dict["author"] as? String
        text = dict["text"] as? String
        category = dict["category"] as? String
        likesCount = dict["likes_count"] as? Int ?? 0
        commentsCount = dict["comments_count"] as? Int ?? 0
        repostCount = dict["repost_count"] as? Int ?? 0
        rating = dict["rating"] as? Double ?? 0.0
        authorName = dict["author_name"] as? String
        likedBy = dict["liked_by"] as? [String] ?? []
        if let dateString = dict["publicationDate"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            publicationDate = formatter.date(from: dateString) ?? Date()
        } else {
            publicationDate = Date()
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        commentsCount = try container.decode(Int.self, forKey: .commentsCount)
        repostCount = try container.decode(Int.self, forKey: .repostCount)
        rating = try container.decode(Double.self, forKey: .rating)
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        likedBy = try container.decodeIfPresent([String].self, forKey: .likedBy) ?? []
        publicationDate = try container.decode(Date.self, forKey: .publicationDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(key, forKey: .key)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(author, forKey: .author)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(likesCount, forKey: .likesCount)
        try container.encode(commentsCount, forKey: .commentsCount)
        try container.encode(repostCount, forKey: .repostCount)
        try container.encode(rating, forKey: .rating)
        try container.encodeIfPresent(key, forKey: .authorName)
        try container.encode(likedBy, forKey: .likedBy)
    }
    
    init?(snapshot: DataSnapshot) {
        guard let fanficDict = snapshot.value as? [String: Any] else {
            return nil
        }
        key = fanficDict["key"] as? String
        title = fanficDict["title"] as? String
        description = fanficDict["description"] as? String
        imageURL = fanficDict["imageURL"] as? String
        author = fanficDict["author"] as? String
        text = fanficDict["text"] as? String
        category = fanficDict["category"] as? String
        likesCount = fanficDict["likes_count"] as? Int ?? 0
        commentsCount = fanficDict["comments_count"] as? Int ?? 0
        repostCount = fanficDict["repost_count"] as? Int ?? 0
        rating = fanficDict["rating"] as? Double ?? 0.0
        authorName = fanficDict["authorName"] as? String
        likedBy = fanficDict["likedBy"] as? [String] ?? []
        if let dateString = fanficDict["publicationDate"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            publicationDate = formatter.date(from: dateString) ?? Date()
        } else {
            publicationDate = Date()
        }
        
    }
    
    mutating func like(byUser userID: String) {
        if !likedBy.contains(userID) {
            likedBy.append(userID)
            likesCount += 1
        }
    }
    
    mutating func unlike(byUser userID: String) {
        if let index = likedBy.firstIndex(of: userID) {
            likedBy.remove(at: index)
            likesCount -= 1
        }
    }
}
extension Fanfic: Equatable {
    
    static func == (lhs: Fanfic, rhs: Fanfic) -> Bool {
        return lhs.title == rhs.title && lhs.description == rhs.description && lhs.imageURL == rhs.imageURL && lhs.author == rhs.author && lhs.text == rhs.text && lhs.category == rhs.category && lhs.likesCount == rhs.likesCount && lhs.commentsCount == rhs.commentsCount && lhs.repostCount == rhs.repostCount && lhs.rating == rhs.rating && lhs.authorName == rhs.authorName
    }
}
