import Foundation
import Alamofire

protocol ImageSelectViewControllerOutput {
    func clearSubscribtions()
    func numberOfCells() -> Int
    func cellData(number: Int) -> ImageViewCellData?
    func select(at number: Int, frame: CGRect)
}

protocol ImageSelectModelOutput {
}

class ImageSelectViewModel {
    
    var model: ImageSelectModelInput?
    weak var view: (ImageSelectViewControllerInput & AnyObject)?
    weak private var imageService: ImageServiceProtocol?
    
    init(imageService: ImageServiceProtocol) {
        self.imageService = imageService
        imageService.subscribe(self)
    }
}

// MARK: - ImageSelectViewControllerOutput
extension ImageSelectViewModel: ImageSelectViewControllerOutput {
    
    func clearSubscribtions() {
        imageService?.unsubscribe(self)
    }
    
    func numberOfCells() -> Int {
        model?.linksCount() ?? 0
    }
    
    func cellData(number: Int) -> ImageViewCellData? {
        model?.cellData(number: number)
    }
    
    func select(at number: Int, frame: CGRect) {
        if let cellData = model?.cellData(number: number) {
            if cellData.didLoad {
                view?.showImageViewer(imageLink: cellData.link, index: number, frame: frame, delegate: self)
            } else {
                cellData.failedLoading = false
                view?.reloadItem(at: number)
            }
        }
    }
}

// MARK: - ImageSelectModelOutput
extension ImageSelectViewModel: ImageSelectModelOutput {
}

// MARK: - ImageServiceSubscriber
extension ImageSelectViewModel: ImageServiceSubscriber {
    
    func didLoadLinks(links: [String]) {
        model?.setLinks(links: links)
        view?.reloadCollectionView()
    }
}

// MARK: - ImageViewerDelegate
extension ImageSelectViewModel: ImageViewerDelegate {
    
    func getNextImageLink(currentImageIndex: Int) -> (index: Int, url: URL)? {
        guard let count = model?.linksCount() else {
            return nil
        }
        
        var counter = currentImageIndex + 1
        while counter < count {
            if let cellData = model?.cellData(number: counter),
               cellData.didLoad,
               let url = URL(string: cellData.link) {
                return (counter, url)
            }
            counter += 1
        }
        return nil
    }
    
    func getPreviousImageLink(currentImageIndex: Int) -> (index: Int, url: URL)? {
        var counter = currentImageIndex - 1
        while counter >= 0 {
            if let cellData = model?.cellData(number: counter),
               cellData.didLoad,
               let url = URL(string: cellData.link) {
                return (counter, url)
            }
            counter -= 1
        }
        return nil
    }
}
