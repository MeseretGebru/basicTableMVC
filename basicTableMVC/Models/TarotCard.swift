//
//  TarotCard.swift
//  basicTableMVC
//
//  Created by Marty Hernandez Avedon on 11/17/17.
//  Copyright © 2017 Marty Hernandez Avedon. All rights reserved.
//

import UIKit

class TarotCard: Codable {
    let title: String
    let imageAddress: URL
    let description: String
    
    init(title: String, imageAddress: URL, description: String) {
        self.title = title
        self.imageAddress = imageAddress
        self.description = description
    }
    
    convenience init?(jsonDict: [String : Any]) {
        guard let titleFromJSON = jsonDict["title"] as? String else {
            print("Title not found")
            return nil
        }
        guard let urlStringFromJSON = jsonDict["image"] as? String else {
            print("Image not found")
            return nil
        }
        
        guard let imageFromJSON = URL(string: urlStringFromJSON) else {
            print("Image string could not be converted to a URL")
            return nil
        }
        
        guard let descriptionFromJSON = jsonDict["description"] as? String else {
            print("Description not found")
            return nil
        }
            
        self.init(title: titleFromJSON, imageAddress: imageFromJSON, description: descriptionFromJSON)
    }
    
    func makeCardFace() -> UIImage? {
        
        var image: UIImage
        
        do {
            let data: Data? = try Data(contentsOf: self.imageAddress)
            
            if let validImage =  UIImage(data: data!) {
                image = validImage
                return image
            }
        }
        
        catch {
            print("error creating image from \(self.imageAddress)")
        }
        
        return nil
    }
}
