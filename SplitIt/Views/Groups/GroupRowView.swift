import SwiftUI

struct GroupRowView: View {
    let group: Group

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.name)
                    .font(.headline)
                Text("\(group.members) members")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing) {
                if group.totalOwed > 0 {
                    Text("You owe: $\(group.totalOwed, specifier: "%.2f")")
                        .foregroundColor(.red)
                }
                if group.totalToReceive > 0 {
                    Text("Owes you: $\(group.totalToReceive, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

