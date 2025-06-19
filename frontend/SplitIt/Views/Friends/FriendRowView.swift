import SwiftUI

struct FriendRowView: View {
    let friend: Friend

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(friend.name)
                    .font(.headline)
                Text("Nickname: \(friend.nickname)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing) {
                if friend.amountOwed > 0 {
                    Text("You owe: $\(friend.amountOwed, specifier: "%.2f")")
                        .foregroundColor(.red)
                }
                if friend.amountToReceive > 0 {
                    Text("Owes you: $\(friend.amountToReceive, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

