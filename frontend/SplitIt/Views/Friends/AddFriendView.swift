import SwiftUI

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var friends: [Friend]

    @State private var name = ""
    @State private var nickname = ""
    @State private var email = ""
    @State private var phone = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: $name)
                    TextField("Nickname", text: $nickname)
                }

                Section(header: Text("Contact")) {
                    TextField("Email (optional)", text: $email)
                    TextField("Phone (optional)", text: $phone)
                }

                Section {
                    Button("Add Friend") {
                        let newFriend = Friend(name: name, nickname: nickname, amountOwed: 0, amountToReceive: 0)
                        friends.append(newFriend)
                        dismiss()
                    }
                    .disabled(name.isEmpty || (email.isEmpty && phone.isEmpty))
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}

