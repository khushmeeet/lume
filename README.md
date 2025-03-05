# WikiScroll: A Step-by-Step Guide to Your First iOS App

Welcome to iOS development with SwiftUI! This guide will walk you through each file in your TikTok-style Wikipedia app, explain how they work together, and break down the key SwiftUI and Combine concepts along the way.

## 1. Files Overview

Here's a comprehensive list of the files we've created and their purposes:

| File Name                  | Purpose                                          |
| -------------------------- | ------------------------------------------------ |
| **WikiScrollApp.swift**    | The main entry point for your app                |
| **WikiArticle.swift**      | The data model representing a Wikipedia article  |
| **WikipediaService.swift** | Handles API communication with Wikipedia         |
| **ArticleViewModel.swift** | Manages the app's data and business logic        |
| **ContentView.swift**      | The main screen with vertical scrolling articles |
| **ArticleCardView.swift**  | Individual article card displayed in the scroll  |
| **FavoritesManager.swift** | Manages saved favorite articles                  |
| **FavoritesView.swift**    | Screen to display saved favorite articles        |
| **AlertItem.swift**        | Structure for displaying error alerts            |

## 2. Flow of Control

Let me explain how data and user interactions flow through your app:

1. **App Startup**:

    - `WikiScrollApp.swift` initializes and creates the tab structure
    - It creates a shared `FavoritesManager` that's passed to all views
    - The `ContentView` is displayed in the first tab

2. **Loading Articles**:

    - When `ContentView` appears, it calls `viewModel.loadRandomArticles()`
    - `ArticleViewModel` uses `WikipediaService` to fetch data
    - `WikipediaService` communicates with the Wikipedia API
    - Data flows back through this chain: API → `WikipediaService` → `ArticleViewModel` → `ContentView`

3. **User Interaction**:

    - User swipes vertically to browse articles
    - User can tap to expand article content or swipe horizontally for actions
    - When user favorites an article, `ContentView` tells `FavoritesManager` to save it
    - When user taps the Favorites tab, `FavoritesView` displays saved articles from `FavoritesManager`

4. **Error Handling**:
    - If an API error occurs, `WikipediaService` returns an error
    - `ArticleViewModel` captures this error and updates its `error` property
    - `ContentView` displays an alert to the user

This flow follows the MVVM (Model-View-ViewModel) architecture pattern, providing clean separation between data, logic, and UI.

## 3. File-by-File Explanation

### WikiScrollApp.swift

```swift
import SwiftUI

@main
struct WikiScrollApp: App {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Discover", systemImage: "safari")
                    }

                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
            }
            .environmentObject(favoritesManager)
        }
    }
}
```

**Key Concepts:**

- **@main**: Designates this struct as the app's entry point
- **App protocol**: The SwiftUI way of defining an application
- **@StateObject**: Creates and manages an object that will persist throughout the app's lifetime
- **WindowGroup**: A container for your primary content views
- **TabView**: A view that organizes content into tabs
- **.environmentObject()**: Makes an object available to all child views in the hierarchy

**Why We Use It:**
The App struct replaces the old AppDelegate system with a more declarative approach. It defines the structure of your app and sets up shared resources like the FavoritesManager. Using `@StateObject` ensures this manager persists throughout the app's lifetime, while `.environmentObject()` makes it accessible to any view that needs it.

### WikiArticle.swift

```swift
import Foundation

struct WikiArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let extract: String
    let thumbnail: URL?

    // Coding keys to match Wikipedia API response
    enum CodingKeys: String, CodingKey {
        case title
        case extract
        case thumbnail
    }
}
```

**Key Concepts:**

- **struct**: A lightweight value type for modeling data
- **Identifiable protocol**: Requires an `id` property to uniquely identify instances
- **Codable protocol**: Enables conversion between Swift objects and external data formats (JSON)
- **CodingKeys**: Maps between your properties and JSON keys from the API

**Why We Use It:**
The model layer defines what an article is in your app. Making it `Identifiable` allows SwiftUI to efficiently track and update articles in lists. Making it `Codable` lets you easily convert JSON from the Wikipedia API into Swift objects you can work with. The `CodingKeys` enum gives you precise control over how this conversion happens.

### WikipediaService.swift

```swift
import Foundation
import Combine

class WikipediaService {
    private let baseURL = "https://en.wikipedia.org/api/rest_v1"

    // Structure to match Wikipedia's API response
    struct WikiResponse: Codable {
        let title: String
        let extract: String
        let thumbnail: ThumbnailInfo?

        struct ThumbnailInfo: Codable {
            let source: URL
        }
    }

    func fetchRandomArticles(count: Int = 10) -> AnyPublisher<[WikiArticle], Error> {
        let endpoint = "/page/random/summary"
        let url = URL(string: baseURL + endpoint)!

        func createSingleArticlePublisher() -> AnyPublisher<WikiArticle, Error> {
            return URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: WikiResponse.self, decoder: JSONDecoder())
                .tryMap { response -> WikiArticle in
                    return WikiArticle(
                        title: response.title,
                        extract: response.extract,
                        thumbnail: response.thumbnail?.source
                    )
                }
                .eraseToAnyPublisher()
        }

        let publishers = (0..<count).map { _ in createSingleArticlePublisher() }

        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }
}
```

**Key Concepts:**

- **Combine framework**: Apple's reactive programming framework for handling asynchronous events
- **Publisher**: An object that delivers a sequence of values over time
- **AnyPublisher**: A type-erased publisher that hides implementation details
- **URLSession.dataTaskPublisher**: Creates a publisher for network requests
- **map/tryMap**: Transforms values from one type to another
- **decode**: Converts JSON data to Swift objects
- **eraseToAnyPublisher**: Simplifies the publisher's type for cleaner APIs

**Why We Use It:**
The service layer handles communication with external systems like APIs. Using Combine provides a declarative way to express the flow of data: request → response → parsing → transformation. This is much cleaner than traditional callback-based approaches. The `AnyPublisher` return type creates a clear contract: "I will eventually give you articles or an error."

### ArticleViewModel.swift

```swift
import Foundation
import Combine

class ArticleViewModel: ObservableObject {
    @Published var articles: [WikiArticle] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var alertItem: AlertItem? = nil

    private let wikipediaService = WikipediaService()
    private var cancellables = Set<AnyCancellable>()

    func loadRandomArticles() {
        isLoading = true

        wikipediaService.fetchRandomArticles()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false

                if case .failure(let error) = completion {
                    self?.alertItem = AlertItem(
                        title: "Error",
                        message: error.localizedDescription
                    )
                }
            }, receiveValue: { [weak self] articles in
                self?.articles = articles
            })
            .store(in: &cancellables)
    }
}
```

**Key Concepts:**

- **ObservableObject protocol**: Makes a class observable by SwiftUI views
- **@Published**: Marks properties that will notify observers when changed
- **Set<AnyCancellable>**: Stores subscriptions to prevent them from being canceled
- **sink**: Attaches a subscriber with closure-based handling
- **[weak self]**: Prevents memory leaks by avoiding strong reference cycles
- **store(in: &cancellables)**: Saves the subscription to keep it alive

**Why We Use It:**
The ViewModel sits between your data (model) and your interface (view). Making it an `ObservableObject` with `@Published` properties allows SwiftUI to automatically update the UI when data changes. The Combine functionality handles the asynchronous nature of API requests, providing clear success and error paths. Using `[weak self]` prevents memory leaks, while `store(in: &cancellables)` keeps subscriptions alive until you're done with them.

### ContentView.swift

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ArticleViewModel()
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.articles.isEmpty {
                LoadingView()
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                        ArticleCardView(article: article)
                            .tag(index)
                            .gesture(
                                DragGesture(minimumDistance: 20)
                                    .onEnded { value in
                                        if abs(value.translation.width) > abs(value.translation.height) {
                                            if value.translation.width > 0 {
                                                // Swipe right - share
                                                shareArticle(article)
                                            } else {
                                                // Swipe left - favorite
                                                favoritesManager.addFavorite(article)
                                            }
                                        }
                                    }
                            )
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.loadRandomArticles()
        }
    }

    private func shareArticle(_ article: WikiArticle) {
        // Share functionality
    }
}
```

**Key Concepts:**

- **View protocol**: The fundamental building block of SwiftUI UIs
- **@StateObject**: Creates and owns an observable object inside a view
- **@EnvironmentObject**: Accesses an object that was passed through the environment
- **@State**: Manages simple state that belongs to a view
- **ZStack**: Overlays views on top of each other
- **TabView**: Creates a swipeable interface (we're repurposing it for our vertical scroll)
- **ForEach**: Creates views dynamically from collection data
- **gesture**: Attaches gesture recognizers to views
- **.alert(item:)**: Shows an alert when the specified item is non-nil

**Why We Use It:**
The ContentView is the main user interface for your app. It uses `@StateObject` to create and manage the ViewModel and `@EnvironmentObject` to access the shared FavoritesManager. SwiftUI's declarative syntax lets you describe what your interface should look like—a loading view or a scrollable list of articles—and SwiftUI handles the updates when data changes. Gesture recognizers add interactive elements like swipe-to-favorite.

### ArticleCardView.swift

```swift
import SwiftUI

struct ArticleCardView: View {
    let article: WikiArticle
    @State private var showFullContent = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundView(for: article, in: geometry)

                // Content
                VStack(alignment: .leading, spacing: 16) {
                    Text(article.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .padding()

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wikipedia")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))

                        Text(article.extract)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineLimit(showFullContent ? nil : 3)
                            .padding(.bottom)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            showFullContent.toggle()
                        }
                    }
                }
            }
        }
    }

    private func backgroundView(for article: WikiArticle, in geometry: GeometryProxy) -> some View {
        Group {
            if let thumbnailURL = article.thumbnail {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        defaultBackground
                    @unknown default:
                        defaultBackground
                    }
                }
            } else {
                defaultBackground
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .clipped()
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black]),
                startPoint: .center,
                endPoint: .bottom
            )
        )
    }

    private var defaultBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
```

**Key Concepts:**

- **GeometryReader**: Provides sizing information about its parent container
- **ZStack**: Overlays views on top of each other
- **AsyncImage**: Loads and displays remote images asynchronously
- **@State**: Manages simple view state (like whether to show full content)
- **withAnimation**: Wraps state changes in animations
- **some View**: An opaque return type that hides implementation details
- **Group**: A container that doesn't affect layout
- **overlay**: Adds a view on top of another view

**Why We Use It:**
The ArticleCardView handles the presentation of a single article. GeometryReader helps it adapt to different screen sizes, while ZStack allows layering the article text over a background image or gradient. AsyncImage handles loading remote images efficiently, and @State manages the interactive expanding/collapsing of content. Breaking the view into helper methods like `backgroundView` keeps the code organized and readable.

### FavoritesManager.swift

```swift
import Foundation
import Combine

class FavoritesManager: ObservableObject {
    @Published var favorites: [FavoriteArticle] = []

    private let favoritesKey = "SavedFavorites"

    init() {
        loadFavorites()
    }

    func addFavorite(_ article: WikiArticle) {
        let favorite = article.asFavorite
        if !favorites.contains(where: { $0.title == favorite.title }) {
            favorites.append(favorite)
            saveFavorites()
        }
    }

    func removeFavorite(_ favorite: FavoriteArticle) {
        favorites.removeAll { $0.id == favorite.id }
        saveFavorites()
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([FavoriteArticle].self, from: data) {
            favorites = decoded
        }
    }
}

// Helper model for storing favorites
struct FavoriteArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let extract: String
    let thumbnailURLString: String?

    var thumbnailURL: URL? {
        guard let string = thumbnailURLString else { return nil }
        return URL(string: string)
    }
}

// Extension to convert between types
extension WikiArticle {
    var asFavorite: FavoriteArticle {
        FavoriteArticle(
            title: title,
            extract: extract,
            thumbnailURLString: thumbnail?.absoluteString
        )
    }
}
```

**Key Concepts:**

- **ObservableObject**: Makes the class observable by SwiftUI views
- **@Published**: Marks properties that will notify observers when changed
- **UserDefaults**: A simple persistence system for storing small amounts of data
- **JSONEncoder/JSONDecoder**: Converts between Swift objects and JSON data
- **Extension**: Adds functionality to existing types

**Why We Use It:**
The FavoritesManager handles persistence of user preferences (favorite articles). Making it an `ObservableObject` with `@Published` properties ensures the UI updates when favorites change. UserDefaults provides simple storage for small data like favorites. The `FavoriteArticle` struct is designed for storage, while the extension to `WikiArticle` provides convenient conversion between the API model and the storage model.

### FavoritesView.swift

```swift
import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        NavigationView {
            if favoritesManager.favorites.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(favoritesManager.favorites) { favorite in
                        FavoriteRowView(favorite: favorite)
                    }
                    .onDelete(perform: deleteFavorites)
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Favorite Articles")
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 72))
                .foregroundColor(.gray)

            Text("No Favorites Yet")
                .font(.title)
                .fontWeight(.medium)

            Text("Articles you favorite will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("Favorites")
    }

    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favoritesManager.favorites[index]
            favoritesManager.removeFavorite(favorite)
        }
    }
}

struct FavoriteRowView: View {
    let favorite: FavoriteArticle

    var body: some View {
        HStack(spacing: 12) {
            if let url = favorite.thumbnailURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.gray
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(favorite.extract)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
```

**Key Concepts:**

- **NavigationView**: Creates a navigable container with a title
- **List**: Creates a scrollable list of items
- **ForEach**: Creates views dynamically from collection data
- **if/else in SwiftUI**: Conditionally shows different views based on state
- **onDelete**: Adds swipe-to-delete functionality
- **computed properties for views**: Organizes complex view hierarchies
- **nested view structs**: Modularizes UI components

**Why We Use It:**
The FavoritesView displays saved favorite articles. It uses `@EnvironmentObject` to access the shared FavoritesManager. SwiftUI's declarative syntax lets you conditionally show either an empty state or a list of favorites based on the current data. The List and ForEach components efficiently render only the visible items, while onDelete provides built-in swipe-to-delete functionality. Breaking the UI into smaller components like FavoriteRowView keeps the code modular and maintainable.

### AlertItem.swift

```swift
import Foundation

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
```

**Key Concepts:**

- **Identifiable protocol**: Requires an `id` property to uniquely identify instances
- **UUID**: Generates universally unique identifiers

**Why We Use It:**
The AlertItem structure provides a reusable way to display alerts in your app. Making it `Identifiable` allows it to work with SwiftUI's `.alert(item:)` modifier, which shows an alert when the item is non-nil and dismisses it when it returns to nil. This creates a cleaner pattern for displaying alerts compared to managing boolean flags.

## Key SwiftUI Concepts

Now that we've examined each file, let's recap some fundamental SwiftUI concepts:

### Declarative UI

SwiftUI uses a declarative approach where you describe what your UI should look like, not how to create it. Rather than imperatively setting properties and adding subviews, you declare the structure, relationships, and dependencies. SwiftUI handles the how.

### View Protocol

The `View` protocol is the foundation of SwiftUI. Any struct conforming to View can be displayed on screen. The key requirement is a `body` property that returns another View.

### Property Wrappers

SwiftUI uses property wrappers to manage state and data flow:

- **@State**: Manages simple state that belongs to a view
- **@Binding**: Creates a two-way connection to a state property
- **@StateObject**: Creates and owns an observable object
- **@ObservedObject**: Observes an object owned elsewhere
- **@EnvironmentObject**: Accesses an object from the environment
- **@Published**: Marks properties that notify observers when changed

### Data Flow

SwiftUI has a unidirectional data flow:

1. State changes trigger view updates
2. Views describe their appearance based on current state
3. User interactions update state, starting the cycle again

## Key Combine Concepts

Combine is Apple's framework for handling asynchronous events:

### Publisher

A `Publisher` is a type that can deliver a sequence of values over time. Publishers can emit values, complete successfully, or terminate with an error.

### Subscriber

A `Subscriber` receives values from a publisher. The `.sink` method creates a subscriber with closure-based handling.

### Operator

Operators transform, filter, or combine publishers. Examples include:

- `map`: Transforms values
- `filter`: Selects only certain values
- `decode`: Converts data (like JSON) to objects
- `receive(on:)`: Specifies which queue to deliver values on

### Cancellable

A `Cancellable` represents a subscription that can be canceled. Storing these in a `Set<AnyCancellable>` prevents them from being automatically canceled.

## The MVVM Pattern

Your app follows the Model-View-ViewModel (MVVM) pattern:

- **Model**: Simple data structures like `WikiArticle`
- **View**: SwiftUI views like `ContentView` and `ArticleCardView`
- **ViewModel**: Classes like `ArticleViewModel` that manage business logic and data

MVVM creates a clean separation of concerns, making your code more maintainable, testable, and robust.

## Next Steps

Now that you understand the fundamentals, here are some ways to enhance your app:

1. **Add search functionality** to find specific Wikipedia articles
2. **Implement article categories** to group content by topic
3. **Add offline reading** by caching articles
4. **Enhance the UI** with animations and transitions
5. **Add unit tests** to ensure your code works correctly

Remember that learning iOS development is a journey. Start with small changes, experiment, and gradually build up your skills. The foundation you've established with this app will serve you well as you explore more advanced features of SwiftUI, Combine, and iOS development!
