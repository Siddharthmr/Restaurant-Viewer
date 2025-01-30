import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var restaurants: [Restaurant] = []
    @State private var currentIndex: Int = 0
    let yelpService = YelpService()
    @State private var isLoading = false
    @State private var offset = 0
    @State private var query = "restaurants"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    TextField("Search...", text: $query, onCommit: {
                        Task {
                            await loadInitialRestaurants()
                        }
                    })
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if isLoading {
                        ProgressView("Loading nearby \(query)...")
                            .padding()
                    } else {
                        if currentIndex < restaurants.count && currentIndex >= 0 {
                            let currentRestaurant = restaurants[currentIndex]
                            
                            CardView(restaurant: currentRestaurant)
                                .transition(.move(edge: .trailing))
                                .id(currentRestaurant.id)
                        } else {
                            Text("No restaurants to show")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                        }
                        
                        HStack {
                            Button(action: { previousCard() }) {
                                Image(systemName: "arrow.left.circle")
                                    .font(.largeTitle)
                            }
                            .disabled(currentIndex <= 0)
                            
                            Spacer()
                            
                            Button(action: { nextCard() }) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.largeTitle)
                            }
                            .disabled(currentIndex >= restaurants.count - 1)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Restaurant Viewer")
            .onChange(of: locationManager.currentLocation) {
                if locationManager.currentLocation != nil {
                    Task {
                        await loadInitialRestaurants()
                    }
                }
            }
            
        }
        .task {
            await loadInitialRestaurants()
        }
    }
    
    private func loadInitialRestaurants() async {
        guard let location = locationManager.currentLocation else { return }
        
        isLoading = true
        offset = 0
        currentIndex = 0
        
        do {
            let fetched = try await yelpService.fetchBusinesses(location: location,
                                                                query: query,
                                                                offset: offset,
                                                                limit: 20)
            restaurants = fetched
            offset += fetched.count
        } catch {
            print("Failed to fetch: \(error)")
            restaurants = []
        }
        
        isLoading = false
    }
    
    private func loadMoreRestaurantsIfNeeded() async {
        guard let location = locationManager.currentLocation else { return }
        do {
            let fetched = try await yelpService.fetchBusinesses(location: location,
                                                                query: query,
                                                                offset: offset,
                                                                limit: 20)
            restaurants.append(contentsOf: fetched)
            offset += fetched.count
        } catch {
            print("Failed to load more: \(error)")
        }
    }
        
    private func nextCard() {
        withAnimation {
            currentIndex += 1
        }
        
        if currentIndex >= restaurants.count - 5 {
            Task {
                await loadMoreRestaurantsIfNeeded()
            }
        }
    }
    
    private func previousCard() {
        withAnimation {
            currentIndex -= 1
        }
    }
}

#Preview {
    ContentView()
}
