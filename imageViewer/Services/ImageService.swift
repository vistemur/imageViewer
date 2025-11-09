import Alamofire
import Foundation

protocol ImageServiceSubscriber: AnyObject {
    func didLoadLinks(links: [String])
}

protocol ImageServiceProtocol: AnyObject {
    func subscribe(_ subscriber: ImageServiceSubscriber)
    func unsubscribe(_ subscriber: ImageServiceSubscriber)
}

class ImageServiceImpl {
    
    
    private let adress = "https://it-link.ru/test/images.txt"
    private var links: [String] = [] {
        didSet {
            subscribers.forEach { $0.didLoadLinks(links: links) }
        }
    }
    
    private var subscribers: [ImageServiceSubscriber] = []
    private var didLoadLinks: Bool
    
    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.waitsForConnectivity = true
        return Session(configuration: configuration)
    }()
    
    init() {
        didLoadLinks = false
        requestImages()
    }
    
    private func requestImages() {
        sessionManager.request(adress)
            .response { [weak self] response in
                switch response.result {
                case .success(let data):
                    if let data,
                       let stringData = String(data: data, encoding: .utf8) {
                        self?.didLoadLinks = true
                        self?.links = stringData.split(separator: "\n").map { String($0) }
                    }
                case .failure(_):
                    break
                }
            }
    }
    
    
}

extension ImageServiceImpl: ImageServiceProtocol {
    
    func subscribe(_ subscriber: ImageServiceSubscriber) {
        subscribers.append(subscriber)
        if didLoadLinks {
            subscriber.didLoadLinks(links: links)
        }
    }
    
    func unsubscribe(_ subscriber: ImageServiceSubscriber) {
        subscribers.removeAll { $0 === subscriber }
    }
}
