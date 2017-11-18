//
//  NetworkingError.swift
//  basicTableMVC
//
//  Created by Marty Hernandez Avedon on 11/17/17.
//  Copyright © 2017 Marty Hernandez Avedon. All rights reserved.
//

import Foundation

enum APIError: Error {
    case jsonCastFailed
    case noCardKeys
    case couldNotMakeCard(number: Int)
}
