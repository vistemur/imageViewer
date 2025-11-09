import UIKit

protocol ImageSelectViewControllerInput {
    func reloadCollectionView()
    func showImageViewer(imageLink: String, index: Int, frame: CGRect, delegate: ImageViewerDelegate)
    func reloadItem(at index: Int)
}

class ImageSelectViewController: UIViewController {
    
    // MARK: - UI properties

    var viewModel: ImageSelectViewControllerOutput?
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    // MARK: - UI elements
    
    private lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.id)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        setup()
        super.viewDidLoad()
    }
    
    // MARK: - setup
    private func setup() {
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    deinit {
        viewModel?.clearSubscribtions()
    }
}

// MARK: - ImageSelectViewControllerInput
extension ImageSelectViewController: ImageSelectViewControllerInput {
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    func reloadItem(at index: Int) {
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func showImageViewer(imageLink: String, index: Int, frame: CGRect, delegate: ImageViewerDelegate) {
        guard let url = URL(string: imageLink) else {
            return
        }
        
        let ImageViewerVC = ImageViewerViewController.assemble(data: .init(imageUrl: url,
                                                                           imageIndex: index,
                                                                           imageFrame: frame,
                                                                           delegate: delegate))
        navigationController?.pushViewController(ImageViewerVC, animated: false)
    }
}

// MARK: - UICollectionViewDelegate
extension ImageSelectViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let frame: CGRect
        if #available(iOS 17.0, *) {
            frame = collectionView.cellForItem(at: indexPath)?.frame(in: view) ?? .zero
        } else {
            frame = collectionView.cellForItem(at: indexPath)?.frame(forAlignmentRect: view.bounds) ?? .zero
        }
        viewModel?.select(at: indexPath.item, frame: frame)
    }
    
}

// MARK: - UICollectionViewDataSource
extension ImageSelectViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfCells() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.id, for: indexPath)
        if let cell = cell as? ImageViewCell,
           let cellData = viewModel?.cellData(number: indexPath.item) {
            cell.setData(data: cellData)
        }
        return cell
    }
}

// MARK: - Assemble
extension ImageSelectViewController {
    
    static func assemble(imageService: ImageServiceProtocol) -> UIViewController {
        let view = ImageSelectViewController()
        let viewModel = ImageSelectViewModel(imageService: imageService)
        let model = ImageSelectModel(viewModel: viewModel)
        
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.model = model
        return view
    }
}
