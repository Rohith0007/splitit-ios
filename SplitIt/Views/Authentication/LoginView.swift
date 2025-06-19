import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to SplitIt")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button("Login with Email") {
                // action later
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

