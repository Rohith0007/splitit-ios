import SwiftUI

struct GroupsView: View {
    @State private var searchText = ""
    @State private var showAddGroupModal = false

    @State private var groups: [Group] = [
        Group(name: "Road Trip", members: 3, totalOwed: 50.0, totalToReceive: 20.0),
        Group(name: "Office Lunch", members: 4, totalOwed: 0.0, totalToReceive: 35.0)
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    TextField("Search Groups", text: $searchText)
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Button(action: {
                        showAddGroupModal = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 12)
                        .frame(minWidth: 70, idealWidth: 80, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                    .fixedSize() // Ensures it won’t compress inside the HStack
                }
                .padding(.horizontal)

                List {
                    ForEach(filteredGroups) { group in
                        GroupRowView(group: group)
                    }
                }
                .listStyle(PlainListStyle())
            }

            .sheet(isPresented: $showAddGroupModal) {
                AddGroupView(groups: $groups)
            }
        }
        .navigationTitle("Groups")
    }

    var filteredGroups: [Group] {
        if searchText.isEmpty {
            return groups
        } else {
            return groups.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

