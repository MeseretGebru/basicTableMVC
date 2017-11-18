//
//  APIRequestManager.swift
//  swiftEngineAdventure
//
//  Created by Marty Hernandez Avedon on 10/19/17.
//  Copyright © 2017 Marty's . All rights reserved.
//

import Foundation

fileprivate let cardAPIQueue = DispatchQueue(
    label: "ssp.tarot-deck.swiftengine.net.martyav.site",
    attributes: .concurrent)

class APIRequestManager {
    func getData(endPoint: String, callback: @escaping (Data?) -> Void) {
        guard let validURL = URL(string: endPoint) else { return }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: validURL) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error during session: \(String(describing: error))\n")
                return
            }
            
            guard let validData = data else {
                print("Invalid data")
                return
            }
            
            // This code prevents a strange bug called a race condition. The barrier ensures that once we get valid data for a card, another card can't do the same action at the same time and mess us up. Without the barrier, our code might try to do something silly, like append to the same array index all of the cards that have valid data returning at that time. We are deliberately blocking the thread in a limited way, to prevent bigger problems. See https://stackoverflow.com/a/34550
            
            cardAPIQueue.async(flags: .barrier) {
                callback(validData)
            }
            
            }.resume()
    }
}
