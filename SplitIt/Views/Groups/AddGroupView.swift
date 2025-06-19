import SwiftUI

struct AddGroupView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var groups: [Group]

    @State private var groupName = ""
    @State private var memberCount = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Info")) {
                    TextField("Group Name", text: $groupName)
                    TextField("Member Count", text: $memberCount)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button("Create Group") {
                        let newGroup = Group(
                            name: groupName,
                            members: Int(memberCount) ?? 1,
                            totalOwed: 0,
                            totalToReceive: 0
                        )
                        groups.append(newGroup)
                        dismiss()
                    }
                    .disabled(groupName.isEmpty || memberCount.isEmpty)
                }
            }
            .navigationTitle("Add Group")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}

