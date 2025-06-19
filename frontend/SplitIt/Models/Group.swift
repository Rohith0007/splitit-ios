import Foundation

struct Group: Identifiable {
    let id = UUID()
    var name: String
    var members: Int
    var totalOwed: Double
    var totalToReceive: Double
}

