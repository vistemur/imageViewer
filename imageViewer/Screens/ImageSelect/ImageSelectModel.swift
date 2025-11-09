import Foundation

protocol ImageSelectModelInput {
    func setLinks(links: [String])
    func linksCount() -> Int
    func cellData(number: Int) -> ImageViewCellData
}

class ImageSelectModel {
    
    private let viewModel: ImageSelectModelOutput
    private var cellsData: [ImageViewCellData] = []
    
    init(viewModel: ImageSelectModelOutput) {
        self.viewModel = viewModel
    }
}

// MARK: - ImageSelectModelInput
extension ImageSelectModel: ImageSelectModelInput {
    
    func setLinks(links: [String]) {
        cellsData = links.map { ImageViewCellData(link: $0) }
    }
    
    func linksCount() -> Int {
        cellsData.count
    }
    
    func cellData(number: Int) -> ImageViewCellData {
        cellsData[number]
    }
}
