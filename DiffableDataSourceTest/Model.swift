//
//  Model.swift
//  DiffableDataSourceTest
//
//  Created by ogaoga on 2021/04/08.
//

import UIKit

enum Type: String, CaseIterable {
    case Vehicle = "Vehicle"
    case Weather = "Weather"
    case Person = "Person"
}

struct Icon: Hashable {
    let id: UUID
    var name: String
    var image: UIImage
    var value: Int
    var type: Type
    
    init(name: String, type: Type, value: Int = 0) {
        self.id = UUID()
        self.name = name
        self.image = UIImage(systemName: name)!
        self.value = value
        self.type = type
    }
}

class Model: ObservableObject {

    @Published var data = [
        Icon(name: "car", type: .Vehicle),
        Icon(name: "bus", type: .Vehicle),
        Icon(name: "bicycle", type: .Vehicle),
        Icon(name: "airplane", type: .Vehicle),
        Icon(name: "moon", type: .Weather),
        Icon(name: "cloud", type: .Weather),
        Icon(name: "tornado", type: .Weather),
        Icon(name: "person", type: .Person),
        Icon(name: "eyes", type: .Person),
    ]
    
    func increment(id: UUID) {
        data = data
            .map({
                if $0.id == id {
                    var icon = $0
                    icon.value += 1
                    return icon
                } else {
                    return $0
                }
            })
            .sorted(by: { (a, b) in
                return a.value > b.value
            })
    }
}
