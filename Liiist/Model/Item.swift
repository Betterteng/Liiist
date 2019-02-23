//
//  Item.swift
//  Liiist
//
//  Created by 滕施男 on 23/2/19.
//  Copyright © 2019 BetterTeng. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
