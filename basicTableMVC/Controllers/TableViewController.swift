//
//  TableViewController.swift
//  basicTableMVC
//
//  Created by Marty Hernandez Avedon on 11/17/17.
//  Copyright © 2017 Marty Hernandez Avedon. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var networkManager: APIRequestManager!
    var deck: [TarotCard]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // You learned to set up the APIManager as a singleton, then called a class function on it to make the actual API request. Below is an alternate way, called dependency injection. With a singleton, the manager always exists as soon as the app loads -- we just have to use it. Here, we make an instance of APIRequestManager when we create the view we are using it with, then hand the view controller the manager so it can make the API request.
        
        //  Using a singleton ensures we never have multiple APIRequestManagers running & causing weird bugs. However, the dependency injection approach makes it easier to debug the view controller -- if there's a problem, we can just plug in another instance of the APIRequestManager class and see how it runs
        
        // See https://medium.com/ios-os-x-development/dependency-injection-in-swift-a959c6eee0ab
        
        self.networkManager = APIRequestManager()
        self.deck = [TarotCard]()
        
        self.grabThisMany(cards: 23)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deck.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
        let card = deck[indexPath.row]
        
        cell.textLabel?.text = card.title
        cell.detailTextLabel?.text = card.description
        cell.imageView?.image = card.makeCardFace()
        
        return cell
    }
    
    // We don't strictly need this function -- it's only purpose is so all the cells will be the same height
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
}

extension TableViewController {
    
    // This is a big closure that goes to a website, checks the JSON available there, and either tells us about any errors it encountered, or makes us some nice objects for our tableview.
    
    func grabThisMany(cards deckSize: Int) {
        
        for index in 0..<deckSize {
            let cardURL = "\(Endpoint.get)=\(index)"
            
            self.networkManager.getData(endPoint: cardURL) { (data: Data?) in
                if let validData = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: validData, options: [])
                        
                        guard let results = json as? [String: Any] else {
                            throw APIError.jsonCastFailed
                        }
                        
                        guard let response = results["response"] as? [String: Any] else {
                            throw APIError.noCardKeys
                        }
                        
                        if let card = TarotCard(jsonDict: response) {
                            self.deck.append(card)
                            print("We made \(card.title)")
                            print("Our deck has \(self.deck.count) cards")
                        } else {
                            throw APIError.couldNotMakeCard(number: index)
                        }
                    }
                        
                        // Note -- catches are like switch statements in that, we need to account for every possibility or the compiler will complain. That's why we have the three catch blocks for the three  APIError enums AND another catch block for any other kind of error we may encounter. We could set up our throwing functions with only one, very general catch, like the last one below, but then we'll have a harder time debugging because we won't get our custom messages about what went wrong.
                        
                    catch APIError.jsonCastFailed {
                        print("We could not cast the JSON to [String : Any]. This could be because we did not get any JSON. It could also be because the JSON is not a dictionary, or not formatted as a dictionary of type [String : Any].")
                    }
                        
                    catch APIError.noCardKeys {
                        print("We could not find the dictionary containing the card keys. We expected the cards to be inside a dictionary called 'response'. 'Response' should have been of type [String : Any]. If 'response' does not exist, or if 'response' is a dictionary of the wrong type, we cannot access the card keys.")
                    }
                        
                    catch APIError.couldNotMakeCard(let number) {
                        print("We could not make a card from the data at JSON 'response' index \(number), located at \(cardURL).")
                    }
                        
                    // This catch might trigger if wifi is down or not running very well
                        
                    catch {
                        print("Error of unknown type.")
                    }
                }
                
                // This updates the screen so the user can see the cards displayed in the tableview. We always update our UI from the main thread. See https://www.quora.com/Why-must-the-UI-always-be-updated-on-Main-Thread
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
                
            }
        }
    }
}
