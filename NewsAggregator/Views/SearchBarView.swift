import SwiftUI

struct SearchBarView: View {
    @Binding var query: String
    var onChange: (String) -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search headlines", text: $query)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .onChange(of: query, perform: onChange)
            if !query.isEmpty {
                Button {
                    query = ""
                    onChange("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

#Preview {
    SearchBarView(query: .constant("Swift"), onChange: { _ in })
        .padding()
}
