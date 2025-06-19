enum FriendFilter: String, CaseIterable {
    case all = "All"
    case oweMe = "Owe Me"
    case iOwe = "I Owe"
    case settled = "Settled"

    var description: String {
        switch self {
        case .all:
            return "Shows all friends regardless of balance"
        case .oweMe:
            return "Friends who owe you money"
        case .iOwe:
            return "Friends you owe money to"
        case .settled:
            return "No outstanding balances"
        }
    }
}
