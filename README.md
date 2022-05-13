# RestApi

Simple and lightweight swift async rest implementation.

## Installation

### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add https://github.com/RxDx/restapi
- Select "Branch" and type "main"

## Usage

- Instantiate your service
- Start making rest calls!

#### Simple usage

```swift
let service = RestApi(baseUrl: "https://url.com/resources")

```

#### Complete usage

```swift
let service = RestApi(
    baseUrl: "https://url.com",
    path: "resources",
    header: [
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json; charset=utf-8"
    ],
    debug: false,
    urlSession: URLSession.shared
)
```

#### Rest Calls

```swift
let resources: [Resource] = try await service.get()
let resource: Resource = try await service.get(resourceId: "id")
let newResource: Resource? = try await service.post(resource: Resource())
let updatedResource: Resource? = try await service.put(resourceId: "id", resource: Resource())
let updatedResource: Resource? = try await service.patch(resourceId: "id", payload: ["key": "value"])
try await service.delete(resourceId: "id")
```

## Example

#### SwiftUI View Example:

```swift
import SwiftUI
import RestApi

struct Post: Codable, Hashable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

class PostsViewModel: ObservableObject {
    private let service = RestApi(baseUrl: "https://jsonplaceholder.typicode.com", path: "posts")
    @Published private(set) var posts = [Post]()
    @MainActor func getPosts() async {
        do {
            self.posts = try await service.get()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

struct PostsView: View {
    @ObservedObject private var viewModel = PostsViewModel()
    var body: some View {
        List(viewModel.posts, id: \.id) { post in
            NavigationLink {
                PostView(postId: post.id)
            } label: {
                Text(post.title)
            }
        }
        .navigationTitle("Posts")
        .task {
            await viewModel.getPosts()
        }
    }
}
```

## Running Tests

To run tests, go to Product -> Test, or run the following shortcut
```
  cmd + U
```
