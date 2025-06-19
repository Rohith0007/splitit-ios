import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = "Food"
    @State private var date = Date()
    @State private var splitType = "Equal"
    @State private var selectedSplitTargetType = "Individual"
    @State private var selectedGroup = "Road Trip"
    @State private var friendSearchText = ""
    @State private var includeYou = true

    let mockGroups = ["Road Trip", "Office Lunch", "Movie Night"]

    @State private var selectedFriends: [Friend] = []
    @State private var unequalSplits: [UUID: String] = [:]
    @State private var percentageSplits: [UUID: String] = [:]
    @State private var showingSplitConfirmation = false
    @State private var percentageInputs: [UUID: String] = [:]
    @State private var shareInputs: [UUID: String] = [:]
    @State private var paidBy: Friend? = nil
    @State private var enabledGroupMembers: Set<UUID> = []

    let youFriend = Friend(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, name: "You")
    
    enum UnequalMode: String, CaseIterable {
        case custom = "Custom"
        case percentage = "Percentage"
        case shares = "Shares"
    }

    @State private var unequalMode: UnequalMode = .custom


    let mockFriends: [Friend] = [
        Friend(id: UUID(), name: "Ian"),
        Friend(id: UUID(), name: "Nina"),
        Friend(id: UUID(), name: "Sam"),
        Friend(id: UUID(), name: "Alex"),
        Friend(id: UUID(), name: "Teju")
    ]
    
    let groupMembers: [String: [Friend]] = [
        "Road Trip": [Friend(id: UUID(), name: "Ian"), Friend(id: UUID(), name: "Nina"), Friend(id: UUID(), name: "You")],
        "Office Lunch": [Friend(id: UUID(), name: "Sam"), Friend(id: UUID(), name: "Alex"), Friend(id: UUID(), name: "You")],
        "Movie Night": [Friend(id: UUID(), name: "Teju"), Friend(id: UUID(), name: "Ian"), Friend(id: UUID(), name: "You")]
    ]
    
    var currentGroupMembers: [Friend] {
        groupMembers[selectedGroup] ?? []
    }


    var filteredFriends: [Friend] {
        if friendSearchText.isEmpty {
            return []
        } else {
            return mockFriends.filter {
                $0.name.lowercased().contains(friendSearchText.lowercased())
            }
        }
    }

    struct Friend: Identifiable, Hashable, Equatable {
        let id: UUID
        let name: String

        static func == (lhs: Friend, rhs: Friend) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    let categories = ["Food", "Transport", "Gas", "Tickets", "Others"]
    let splitOptions = ["Equal", "Unequal"]

    var body: some View {
        let participants = selectedSplitTargetType == "Group" ?
            currentGroupMembers.filter { enabledGroupMembers.contains($0.id) } :
            selectedFriends

        NavigationView {
            Form {
                Section(header: Text("Split With")) {
                    Picker("Split Type", selection: $selectedSplitTargetType) {
                        Text("Individual").tag("Individual")
                        Text("Group").tag("Group")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedSplitTargetType) { newValue in
                        // Reset split mode when switching
                        splitType = "Equal"
                        unequalMode = .custom

                        // If switching to group, ensure group members are enabled
                        if newValue == "Group" {
                            enabledGroupMembers = Set(currentGroupMembers.map(\.id))
                            if currentGroupMembers.contains(youFriend) {
                                paidBy = youFriend
                            }
                        } else {
                            if includeYou && !selectedFriends.contains(youFriend) {
                                selectedFriends.append(youFriend)
                            }
                            if selectedFriends.contains(youFriend) {
                                paidBy = youFriend
                            }
                        }
                    }

                    if selectedSplitTargetType == "Group" {
                        VStack(alignment: .leading, spacing: 8) {
                            // Group selection menu
                            Menu {
                                ForEach(mockGroups, id: \.self) { group in
                                    Button(action: {
                                        selectedGroup = group
                                        let members = groupMembers[group, default: []]
                                        enabledGroupMembers = Set(members.map(\.id))

                                        // If You is among the members, set as default payer
                                        if members.contains(youFriend) {
                                            paidBy = youFriend
                                        }
                                    }) {
                                        Text(group)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Selected Group: \(selectedGroup)")
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }

                            Text("Group Members")
                                .font(.subheadline)
                                .padding(.top, 6)

                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                ForEach(currentGroupMembers) { member in
                                    HStack(spacing: 4) {
                                        Text(member.name)
                                            .lineLimit(1)
                                            .font(.caption)

                                        Image(systemName: enabledGroupMembers.contains(member.id) ? "checkmark.circle.fill" : "circle")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(enabledGroupMembers.contains(member.id) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                                    .contentShape(Rectangle()) // ✅ restrict tap area
                                    .onTapGesture {
                                        if enabledGroupMembers.contains(member.id) {
                                            enabledGroupMembers.remove(member.id)
                                        } else {
                                            enabledGroupMembers.insert(member.id)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            TextField("Search Friends", text: $friendSearchText)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            Toggle(isOn: $includeYou) {
                                Text("Include Yourself")
                                    .font(.subheadline)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .onChange(of: includeYou) { newValue in
                                if newValue {
                                    if !selectedFriends.contains(youFriend) {
                                        selectedFriends.append(youFriend)
                                    }
                                } else {
                                    selectedFriends.removeAll { $0.id == youFriend.id }
                                }
                            }
                            .onAppear {
                                if includeYou && !selectedFriends.contains(youFriend) {
                                    selectedFriends.append(youFriend)
                                }
                            }

                            if !friendSearchText.isEmpty {
                                ScrollView {
                                    VStack(spacing: 8) {
                                        ForEach(filteredFriends.prefix(5)) { friend in
                                            HStack {
                                                Text(friend.name)
                                                Spacer()
                                                if !selectedFriends.contains(friend) && selectedFriends.count < 15 {
                                                    Button {
                                                        selectedFriends.append(friend)
                                                    } label: {
                                                        Image(systemName: "plus.circle")
                                                            .foregroundColor(.blue)
                                                    }
                                                } else {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                .frame(maxHeight: 200)
                            }

                            if !selectedFriends.isEmpty {
                                Text("Selected Friends (\(selectedFriends.count)/15)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                    ForEach(selectedFriends) { friend in
                                        HStack(spacing: 4) {
                                            Text(friend.name)
                                                .lineLimit(1)
                                                .font(.caption)

                                            if friend.name != "You" {
                                                Button {
                                                    if let index = selectedFriends.firstIndex(of: friend) {
                                                        selectedFriends.remove(at: index)
                                                        unequalSplits[friend.id] = nil
                                                        percentageSplits[friend.id] = nil
                                                    }
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.caption2)
                                                        .foregroundColor(.red)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 4)
                                        .background(friend.name == "You" ? Color.green.opacity(0.15) : Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Picker("Paid By", selection: $paidBy) {
                        ForEach(participants) { friend in
                            Text(friend.name).tag(friend as Friend?)
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section(header: Text("Split")) {
                    Picker("Split Type", selection: $splitType) {
                        ForEach(splitOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: splitType) { newValue in
                        unequalSplits = [:]
                        percentageSplits = [:]
                    }

                    if splitType == "Equal" && !participants.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            let totalPeople = participants.count
                            let perPerson = (Double(amount) ?? 0) / Double(totalPeople)

                            Text("Each owes: $\(String(format: "%.2f", perPerson))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            VStack(spacing: 6) {
                                ForEach(participants) { friend in
                                    HStack {
                                        Text(friend.name)
                                        Spacer()
                                        Text("$\(String(format: "%.2f", perPerson))")
                                            .foregroundColor(friend.name == "You" ? .green : .blue)
                                    }
                                }
                            }

                            Button("Confirm Split") {
                                showingSplitConfirmation = true
                            }
                            .disabled(Double(amount) ?? 0 == 0 || selectedFriends.isEmpty)
                        }
                    }
                    
                    if splitType == "Unequal" && !participants.isEmpty {
                            Picker("Split Mode", selection: $unequalMode) {
                                ForEach(UnequalMode.allCases, id: \.self) {
                                    Text($0.rawValue)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: unequalMode) { newValue in
                                unequalSplits = [:]
                                percentageSplits = [:]
                            }

                            switch unequalMode {
                            case .custom:
                                VStack(alignment: .leading, spacing: 12) {
                                    let totalEntered = participants.reduce(0.0) {
                                        $0 + (Double(unequalSplits[$1.id] ?? "") ?? 0)
                                    }

                                    ForEach(participants) { friend in
                                        HStack {
                                            Text(friend.name)
                                                .foregroundColor(friend.name == "You" ? .green : .primary)
                                            Spacer()
                                            TextField("0.0", text: Binding(
                                                get: { unequalSplits[friend.id] ?? "" },
                                                set: { unequalSplits[friend.id] = $0 }
                                            ))
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .frame(width: 80)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                    }

                                    Text("Total entered: $\(String(format: "%.2f", totalEntered))")
                                        .font(.subheadline)
                                        .foregroundColor(
                                            totalEntered == (Double(amount) ?? 0) ? .green : .red
                                        )

                                    Button("Confirm Split") {
                                        showingSplitConfirmation = true
                                    }
                                    .disabled(totalEntered != (Double(amount) ?? 0))
                                }
                                .padding(.vertical)

                            case .percentage:
                                VStack(alignment: .leading, spacing: 12) {
                                    let totalPercentage = participants.reduce(0.0) {
                                        $0 + (Double(percentageInputs[$1.id] ?? "") ?? 0)
                                    }

                                    ForEach(participants) { friend in
                                        HStack {
                                            Text(friend.name)
                                            Spacer()
                                            TextField("%", text: Binding(
                                                get: { percentageInputs[friend.id] ?? "" },
                                                set: { percentageInputs[friend.id] = $0 }
                                            ))
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .frame(width: 60)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                    }

                                    Text("Total: \(String(format: "%.0f", totalPercentage))%")
                                        .font(.subheadline)
                                        .foregroundColor(totalPercentage == 100 ? .green : .red)

                                    Button("Confirm Split") {
                                        showingSplitConfirmation = true
                                    }
                                    .disabled(totalPercentage != 100)
                                }
                                .padding(.vertical)


                            case .shares:
                                VStack(alignment: .leading, spacing: 12) {
                                    let totalShares = participants.reduce(0) {
                                        $0 + (Int(shareInputs[$1.id] ?? "") ?? 0)
                                    }

                                    ForEach(participants) { friend in
                                        HStack {
                                            Text(friend.name)
                                            Spacer()
                                            TextField("", text: Binding(
                                                get: { shareInputs[friend.id] ?? "" },
                                                set: { shareInputs[friend.id] = $0 }
                                            ))
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.trailing)
                                            .frame(width: 60)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                    }

                                    Text("Total Shares: \(totalShares)")
                                        .font(.subheadline)
                                        .foregroundColor(totalShares > 0 ? .green : .red)

                                    Button("Confirm Split") {
                                        showingSplitConfirmation = true
                                    }
                                    .disabled(totalShares == 0 || participants.contains { shareInputs[$0.id]?.isEmpty ?? true })
                                }
                                .padding(.vertical)

                            }
                        }

                }

                Section {
                    Button("Add Expense") {
                        dismiss()
                    }
                    .disabled(title.isEmpty || amount.isEmpty || paidBy == nil || selectedFriends.isEmpty)
                }
            }
            
            .alert(isPresented: $showingSplitConfirmation) {
                            var message = ""
                            let totalAmount = Double(amount) ?? 0
                            guard let payer = paidBy else {
                                return Alert(title: Text("Missing Payer"), message: Text("Please select who paid."), dismissButton: .default(Text("OK")))
                            }

                            if splitType == "Equal" {
                                let totalPeople = selectedFriends.count
                                let perPerson = totalAmount / Double(totalPeople)
                                let others = selectedFriends.filter { $0.id != payer.id }

                                message = others.map { "\($0.name): owes $\(String(format: "%.2f", perPerson))" }
                                    .joined(separator: "\n")
                                message += "\n\(payer.name): gets back $\(String(format: "%.2f", perPerson * Double(others.count)))"

                            } else if splitType == "Unequal" {
                                switch unequalMode {
                                case .custom:
                                    let shares = participants.map { friend -> (name: String, value: Double) in
                                        let val = Double(unequalSplits[friend.id] ?? "") ?? 0
                                        return (friend.name, val)
                                    }
                                    let payerShare = shares.first(where: { $0.name == payer.name })?.value ?? 0
                                    let getsBack = totalAmount - payerShare

                                    message = shares.filter { $0.name != payer.name }
                                        .map { "\($0.name): owes $\(String(format: "%.2f", $0.value))" }
                                        .joined(separator: "\n")

                                    message += "\n\(payer.name): gets back $\(String(format: "%.2f", getsBack))"

                                case .percentage:
                                    let splits = participants.map { friend -> (name: String, share: Double) in
                                        let percent = Double(percentageInputs[friend.id] ?? "") ?? 0
                                        return (friend.name, (totalAmount * percent / 100))
                                    }
                                    let payerShare = splits.first(where: { $0.name == payer.name })?.share ?? 0
                                    let getsBack = totalAmount - payerShare

                                    message = splits.filter { $0.name != payer.name }
                                        .map { "\($0.name): owes $\(String(format: "%.2f", $0.share))" }
                                        .joined(separator: "\n")

                                    message += "\n\(payer.name): gets back $\(String(format: "%.2f", getsBack))"

                                case .shares:
                                    let totalShares = participants.reduce(0) {
                                        $0 + (Int(shareInputs[$1.id] ?? "") ?? 0)
                                    }
                                    let splits = selectedFriends.map { friend -> (name: String, value: Double) in
                                        let share = Int(shareInputs[friend.id] ?? "") ?? 0
                                        let owed = totalShares > 0 ? (Double(share) / Double(totalShares)) * totalAmount : 0
                                        return (friend.name, owed)
                                    }
                                    let payerShare = splits.first(where: { $0.name == payer.name })?.value ?? 0
                                    let getsBack = totalAmount - payerShare

                                    message = splits.filter { $0.name != payer.name }
                                        .map { "\($0.name): owes $\(String(format: "%.2f", $0.value))" }
                                        .joined(separator: "\n")

                                    message += "\n\(payer.name): gets back $\(String(format: "%.2f", getsBack))"
                                }
                            }

                            return Alert(
                                title: Text("Split Summary"),
                                message: Text(message),
                                dismissButton: .default(Text("OK"))
                            )
                        }
            
            .navigationTitle("Add Expense")
            .onAppear {
                if paidBy == nil && includeYou {
                    paidBy = youFriend
                }
            }
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .onAppear {
                if selectedSplitTargetType == "Group" {
                    // Ensure members are enabled initially
                    if enabledGroupMembers.isEmpty {
                        enabledGroupMembers = Set(currentGroupMembers.map(\.id))
                    }

                    // Set "You" as default payer if included
                    if paidBy == nil && enabledGroupMembers.contains(youFriend.id) {
                        paidBy = youFriend
                    }
                } else {
                    // For individual mode
                    if includeYou && !selectedFriends.contains(youFriend) {
                        selectedFriends.append(youFriend)
                    }

                    if paidBy == nil && selectedFriends.contains(youFriend) {
                        paidBy = youFriend
                    }
                }
            }
        }
    }
}

