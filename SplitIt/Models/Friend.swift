import Foundation

struct Friend: Identifiable {
    let id = UUID()
    var name: String
    var nickname: String
    var amountOwed: Double
    var amountToReceive: Double
}
