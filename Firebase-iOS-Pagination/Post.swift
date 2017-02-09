//
//  Post.swift
//  Firebase-iOS-Pagination
//
//  Created by BURAK GÜNDÜZ on 09/02/2017.
//  Copyright © 2017 Burak Gunduz. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    fileprivate var _postKey: String?
    fileprivate var _title: String?
    fileprivate var _content: String?
    
    fileprivate var _imageName: String?
    fileprivate var _imageUrl: String?
    fileprivate var _ownerID: String?
    fileprivate var _reverseTimestamp: Double?
    fileprivate var _timestamp: String?
    fileprivate var _timeUTC: String?
    
    fileprivate var _userClass: User?
    
    var postKey: String? {
        return _postKey
    }
    
    var title: String? {
        return _title
    }
    
    var content: String? {
        return _content
    }
    
    var imageName: String? {
        return _imageName
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var ownerID: String? {
        return _ownerID
    }
    
    var reverseTimestamp: Double? {
        return _reverseTimestamp
    }
    
    var timestamp: String? {
        return _timestamp
    }
    
    var timeUTC: String? {
        return _timeUTC
    }
    
    var userClass: User? {
        return _userClass
    }
    
    init(key: String, postDict: [String: AnyObject]) {
        
        self._postKey = key
        
        if let title = postDict["title"] as? String {
            self._title = title
        }
        
        if let content = postDict["content"] as? String {
            self._content = content
        }
        
        if let imageName = postDict["imageName"] as? String {
            self._imageName = imageName
        }
        
        if let imageUrl = postDict["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let ownerID = postDict["ownerID"] as? String {
            self._ownerID = ownerID
            
            // Implement your own referance service path.
            DataService.ds.REF_USERS.child(ownerID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let userDict = snapshot.value as? [String: AnyObject] {
                    
                    
                    self._userClass = User(userKey: snapshot.key as String, userDict: userDict)
                }
            })
        }
        
        if let reverseTimestamp = postDict["reverseTimestamp"] as? Double {
            
            
            self._reverseTimestamp = reverseTimestamp
        }
        
        if let timestamp = postDict["timestamp"] as? String {
            self._timestamp = timestamp
        }
        
        if let timeUTC = postDict["timeUTC"] as? String {
            self._timeUTC = timeUTC
        }
        
    }
    
}
