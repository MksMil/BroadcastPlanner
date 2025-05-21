
struct DividerWithText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.black.opacity(0.4))
            .padding(.horizontal,5)
            .background{
                Rectangle().fill(Color.mainBackground)
            }
            .frame(maxWidth: .infinity)
            .background{
                Divider()
            }
    }
}
