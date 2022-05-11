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
let service = RestApi<Resource>(baseUrl: "https://url.com/resources")

```

#### Complete usage

```swift
let service = RestApi<Resource>(
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
let resources = try await service.get()
let resource = try await service.get(resourceId: "id")
let newDummy = try await service.post(resource: anObject)
let updatedDummy = try await service.put(resourceId: "id", resource: anObject)
let updatedDummy = try await service.patch(payload: ["key": "value"])
try await service.delete(resourceId: "id")
```

## Example

#### SwiftUI View Example:

```javascript
import SwiftUI
import RestApi

struct Dummy: Codable {
    let id: String
}

private class DummyViewModel: ObservableObject {
    private let service = RestApi<Dummy>(baseUrl: "https://url.com", path: "dummies")
    @Published private(set) var dummies = [Dummy]()
    @MainActor func getDummies() async {
        do {
            let dummies = try await service.get()
            self.dummies = dummies
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

struct DummyView: View {
    @ObservedObject private var viewModel = DummyViewModel()
    var body: some View {
        Text("Dummies count: \(viewModel.dummies.count)")
    }
}
```

## Running Tests

To run tests, go to Product -> Test, or run the following shortcut
```
  cmd + U
```
