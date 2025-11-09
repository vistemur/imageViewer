import Foundation

protocol ImageViewerModelInput {
}

class ImageViewerModel {
    
    private let viewModel: ImageViewerModelOutput
    
    init(viewModel: ImageViewerModelOutput) {
        self.viewModel = viewModel
    }
}

// MARK: - ImageViewerModelInput
extension ImageViewerModel: ImageViewerModelInput {
}
