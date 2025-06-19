import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAddExpense = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                FriendsView()
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Friends")
                    }
                    .tag(0)

                GroupsView()
                    .tabItem {
                        Image(systemName: "person.3")
                        Text("Groups")
                    }
                    .tag(1)

                Text("Dashboard")
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Dashboard")
                    }
                    .tag(2)

                Text("Activity")
                    .tabItem {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Activity")
                    }
                    .tag(3)

                Text("Profile")
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                    .tag(4)
            }

            if selectedTab == 0 || selectedTab == 1 {
                Button(action: {
                    showAddExpense = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding(22)
                        .background(Color.purple)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 65)
                .sheet(isPresented: $showAddExpense) {
                    AddExpenseView()
                }
            }
        }
    }
}
