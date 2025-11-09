import Foundation

protocol ImageViewerViewControllerOutput {
    func viewDidLoad()
}

protocol ImageViewerModelOutput {
}

class ImageViewerViewModel {
    
    var model: ImageViewerModelInput?
    weak var view: (ImageViewerViewControllerInput & AnyObject)?
}

// MARK: - ImageViewerViewControllerOutput
extension ImageViewerViewModel: ImageViewerViewControllerOutput {
    
    func viewDidLoad() {
    }
}

// MARK: - ImageViewerModelOutput
extension ImageViewerViewModel: ImageViewerModelOutput {
}
