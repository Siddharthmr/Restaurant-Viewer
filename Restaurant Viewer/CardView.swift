import SwiftUI

struct CardView: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: restaurant.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 200)
            .clipped()
            
            Text(restaurant.name)
                .font(.headline)
                .padding(.top, 8)
            
            Text("Rating: \(String(format: "%.1f", restaurant.rating))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .padding()
    }
}
