import Combine
import Foundation
import SwiftUI
#if os(macOS)
import Cocoa
public typealias ImageData = NSImage
#elseif os(iOS) || os(watchOS) || os(tvOS)
import UIKit
public typealias ImageData = UIImage
#endif

extension Image {
    init(imageData: ImageData) {
        #if os(macOS)
        self.init(nsImage: imageData)
        #elseif os(iOS) || os(watchOS) || os(tvOS)
        self.init(uiImage: imageData)
        #else
        fatalError("should apple device")
        #endif
    }
}

public struct DownloadImage<Content: View>: View {
    @State private var image: ImageData
    private let publisher: DownloadImagePublisher
    private let errorImage: ImageData
    private let builder: (Image)->Content
    public init(url: URL, builder: @escaping ((Image)->Content), placeholder: ImageData?, errorImage: ImageData?) {
        publisher = .init(url: url)
        self.errorImage = errorImage ?? ImageData()
        self._image = .init(initialValue: placeholder ?? ImageData())
        self.builder = builder
    }
    public var body: some View {
        builder(Image(imageData: image))
            .onReceive(publisher.receive(on: DispatchQueue.main).replaceError(with: errorImage))
            { image in
                self.image = image
            }
    }
}

public enum ImageError: Error {
    case cast
    case download(error: URLError)
}

public struct DownloadImagePublisher: Publisher {
    public typealias Output = ImageData
    public typealias Failure = ImageError
    let url: URL
    public func receive<S>(subscriber: S) where S : Subscriber, DownloadImagePublisher.Failure == S.Failure, DownloadImagePublisher.Output == S.Input {
        let subscription = DownloadImageSubscription(subscriber: subscriber, url: url)
        subscriber.receive(subscription: subscription)
    }
}

class DownloadImageSubscription<SubscriberType: Subscriber>: Subscription where SubscriberType.Input == ImageData, SubscriberType.Failure == ImageError {
    private var subscriber: SubscriberType?
    private let url: URL
    private let session: URLSession
    private var disposeBag: Set<AnyCancellable>
    private var cache: NSCache<NSURL, ImageData> {
        let cache: NSCache<NSURL, ImageData> = .init()
        cache.name = "duct_download_image"
        return cache
    }
    init(subscriber: SubscriberType, url: URL, session: URLSession = .shared) {
        self.subscriber = subscriber
        self.url = url
        self.session = session
        self.disposeBag = .init()
    }
    func request(_ demand: Subscribers.Demand) {
        if let image = cache.object(forKey: url.absoluteURL as NSURL) {
            _ = subscriber?.receive(image)
            self.subscriber?.receive(completion: .finished)
        } else {
            session.dataTaskPublisher(for: url)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        self.subscriber?.receive(completion: .finished)
                    case .failure(let error):
                        self.subscriber?.receive(completion: .failure(.download(error: error)))
                    }
                }, receiveValue: { [weak self] (data, result) in
                    guard let self = self else { return }
                    if let image = ImageData(data: data) {
                        self.cache.setObject(image, forKey: self.url.absoluteURL as NSURL)
                        _ = self.subscriber?.receive(image)
                        self.subscriber?.receive(completion: .finished)
                    } else {
                        self.subscriber?.receive(completion: .failure(.cast))
                    }
                })
                .store(in: &disposeBag)
        }
    }
    
    func cancel() {
        subscriber = nil
        self.disposeBag = .init()
    }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        DownloadImage(url: URL(string: "https://images.unsplash.com/photo-1608830597604-619220679440?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=934&q=80")!, builder: { $0.resizable()
        }, placeholder: nil, errorImage: nil)
    }
}
