import UIKit
import Kingfisher

class ImageViewCell: UICollectionViewCell {
    
    static let id = "ImageViewCell"
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupImageView()
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func setData(data: ImageViewCellData) {
        if data.failedLoading {
            setErrorState()
        } else {
            if let url = URL(string: data.link) {
                imageView.tintColor = .lightGray
                imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "arrow.down.to.line.alt"), options: [
                    .cacheOriginalImage,
                    .transition(.fade(0.25))
                ]) { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.imageView.tintColor = .none
                        data.didLoad = true
                        data.failedLoading = false
                    case .failure(_):
                        self?.setErrorState()
                        data.failedLoading = true
                    }
                }
            } else {
                setErrorState()
                data.failedLoading = true
            }
        }
    }
        
    private func setErrorState() {
        let image = UIImage(systemName: "photo.trianglebadge.exclamationmark")
        imageView.image = image
        imageView.tintColor = .lightGray
    }
}

class ImageViewCellData {
    
    let link: String
    var failedLoading: Bool
    var didLoad: Bool
    
    init(link: String) {
        self.link = link
        self.failedLoading = false
        self.didLoad = false
    }
}
