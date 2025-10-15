import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: NewsCategory

    var body: some View {
        ForEach(NewsCategory.allCases) { category in
            Button {
                selectedCategory = category
            } label: {
                Label(category.title, systemImage: category.iconName)
                if selectedCategory == category {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    CategoryPickerView(selectedCategory: .constant(.technology))
}
