import SwiftUI

struct FriendsView: View {
    @State private var searchText = ""
    @State private var isAIToggleOn = false
    @State private var showAddFriendModal = false
    @State private var activeFilters: [FriendFilter] = [.all]

    // Mock friend data
    @State private var friends: [Friend] = [
        Friend(name: "Ian", nickname: "I", amountOwed: 20.0, amountToReceive: 10.0),
        Friend(name: "Nina", nickname: "N", amountOwed: 0.0, amountToReceive: 15.5),
        Friend(name: "Sam", nickname: "S", amountOwed: 8.5, amountToReceive: 0.0)
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    TextField("Search Friends", text: $searchText)
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Button(action: {
                        isAIToggleOn.toggle()
                    }) {
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    .frame(height: 40)

                    Button(action: {
                        showAddFriendModal = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)




                if isAIToggleOn {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Mode Enabled").bold()
                        Text("e.g. 'Show last month gas expenses with Ian where I received money'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("⚠️ AI responses may be inaccurate")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color(.systemYellow).opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // MARK: - Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FriendFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                toggleFilter(filter)
                            }) {
                                Text(filter.rawValue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(activeFilters.contains(filter) ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(activeFilters.contains(filter) ? .white : .primary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }


                List {
                    ForEach(filteredFriends) { friend in
                        FriendRowView(friend: friend)
                    }
                }
                .listStyle(PlainListStyle())
            }

            .sheet(isPresented: $showAddFriendModal) {
                AddFriendView(friends: $friends)
            }
        }
        .navigationTitle("Friends")
    }

    var filteredFriends: [Friend] {
        var list = friends

        if !searchText.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }

        if activeFilters.contains(.all) { return list }

        return list.filter { friend in
            var include = false
            if activeFilters.contains(.oweMe), friend.amountToReceive > 0 { include = true }
            if activeFilters.contains(.iOwe), friend.amountOwed > 0 { include = true }
            if activeFilters.contains(.settled),
               friend.amountOwed == 0 && friend.amountToReceive == 0 { include = true }
            return include
        }
    }
    
    func toggleFilter(_ filter: FriendFilter) {
        if filter == .all {
            activeFilters = [.all]
        } else {
            if activeFilters.contains(.all) {
                activeFilters = [filter]
            } else if activeFilters.contains(filter) {
                activeFilters.removeAll { $0 == filter }
                if activeFilters.isEmpty { activeFilters = [.all] }
            } else if activeFilters.count < 4 {
                activeFilters.append(filter)
            }
        }
    }

}

