//
//  Category.swift
//  Liiist
//
//  Created by 滕施男 on 23/2/19.
//  Copyright © 2019 BetterTeng. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    
    let items = List<Item>()
}
