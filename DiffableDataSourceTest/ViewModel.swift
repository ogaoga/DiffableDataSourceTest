//
//  ViewModel.swift
//  DiffableDataSourceTest
//
//  Created by ogaoga on 2021/01/10.
//

import Combine
import Foundation

struct Row: Hashable, Comparable {
 
    let id: UUID
    var name: String
    var count: Int
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.count = 0
    }
    
    static func < (lhs: Row, rhs: Row) -> Bool {
        return lhs.count > rhs.count
    }
}

enum Section {
    case main
}

class ViewModel: ObservableObject {
    @Published var rows: [Row] = []
    @Published var updatedRow: Row? = nil
    
    init() {
        rows += [
            Row(name: "apple"),
            Row(name: "banana"),
            Row(name: "grape"),
            Row(name: "lemon"),
            Row(name: "melon"),
        ]
    }
    
    func increment(row: Row) {
        rows = rows.map {
            var temp = $0
            if $0 == row {
                temp.count += 1
            }
            return temp
        }.sorted()
        
        // for debug
        rows.forEach {
            print($0.id, $0.name, $0.count)
        }
        print("-")
    }
    
    func delete(row: Row) {
        rows = rows.filter { $0 != row }

        // for debug
        rows.forEach {
            print($0.id, $0.name, $0.count)
        }
        print("-")
    }
}
