//
//  FlickImageOperation.swift
//  Weather
//
//  Created by Majkl on 04/12/15.
//  Copyright © 2015 Majkl. All rights reserved.
//

import Foundation
import FlickrKit

class FlickrImageOperation: NSOperation {
    var location : String?
    
    var completionHandler : ((UIImage?) -> Void)?
    
    override func main() {
        
        var args : [String : String]? = nil
        
        if let location = location {
            args = [ "text" : location, "per_page" : "20", "content_type" : "1", "privacy_filter" : "1" ]
        }
        
        if let args = args {
            FlickrKit.sharedFlickrKit().call("flickr.photos.search", args: args) {
                response, error in
                
                // Take photos
                let photos = response["photos"]!["photo"]! as! [[String: AnyObject]]
                
                // Take the first photo ID, create URL and load image
                
                var image : UIImage? = nil
                
                if let photo = self.findPublicPhoto(photos) {
                    
                    let URL = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeLarge1600,fromPhotoDictionary: photo)
                    
                    let data = NSData(contentsOfURL: URL)
                    
                    image = UIImage(data: data!)
                }
                
                if let completionHandler = self.completionHandler {
                    completionHandler(image)
                }
            }
        }
    }
    
    private func findPublicPhoto(photos: [[String: AnyObject]]) -> [String: AnyObject]? {
        let photos = photos.shuffle()
        
        for photo in photos {
            if (photo["ispublic"] as! NSNumber).integerValue == 1 {
                return photo
            }
        }
        
        return nil
    }
}