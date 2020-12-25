# Duct

## Installation
```swift
.package(name: "Duct", url: "https://github.com/tera-ny/Duct.git", from: "0.0.2"),
```

## Usage
```swift
struct ContentView: View {
    var body: some View {
        DownloadImage(url: URL(string: "https://images.unsplash.com/photo-1608830597604-619220679440?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=3034&q=80")!, builder: imageBuilder(image:))
    }
    
    @ViewBuilder func imageBuilder(image: Image) -> some View {
        image.resizable().scaledToFill()
    }
}
```
