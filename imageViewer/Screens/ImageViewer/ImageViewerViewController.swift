import UIKit
import Kingfisher

protocol ImageViewerViewControllerInput {
}

class ImageViewerViewController: UIViewController {
    
    // MARK: - UI properties

    var viewModel: ImageViewerViewControllerOutput?
    private var data: ImageViewerData
    
    private lazy var swipeLeftGestureRecognizer: UISwipeGestureRecognizer = {
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeftGestureRecognizer.direction = .left
        return swipeLeftGestureRecognizer
    }()
    
    private lazy var swipeRightGestureRecognizer: UISwipeGestureRecognizer = {
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRightGestureRecognizer.direction = .right
        return swipeRightGestureRecognizer
    }()
    
    private lazy var tapGestureRecognoser: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        return tapGestureRecognizer
    }()
    
    // MARK: - UI elements
    
    private lazy var shareBarItem: UIBarButtonItem = {
        let barItem = UIBarButtonItem()
        barItem.image = UIImage(systemName: "square.and.arrow.up")
        barItem.action = #selector(didTapShare)
        barItem.target = self
        return barItem
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        return scrollView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: data.imageUrl)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Constraints
    
    private lazy var imageViewTopConstraint: NSLayoutConstraint = {
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: data.imageFrame.origin.y)
    }()
    
    private lazy var imageViewLeadingConstraint: NSLayoutConstraint = {
        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: data.imageFrame.origin.x)
    }()
    
    private lazy var imageViewWidthConstraint: NSLayoutConstraint = {
        imageView.widthAnchor.constraint(equalToConstant: data.imageFrame.width)
    }()
    
    private lazy var imageViewHeightConstraint: NSLayoutConstraint = {
        imageView.heightAnchor.constraint(equalToConstant: data.imageFrame.height)
    }()

    
    // MARK: - life cycle
    init(data: ImageViewerData) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setup()
        viewModel?.viewDidLoad()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            
            self.imageViewTopConstraint.constant = 0
            self.imageViewLeadingConstraint.constant = 0
            self.imageViewWidthConstraint.constant = self.view.safeAreaLayoutGuide.layoutFrame.width
            self.imageViewHeightConstraint.constant = self.view.safeAreaLayoutGuide.layoutFrame.height
            self.view.layoutIfNeeded()
        }
        super.viewDidAppear(animated)
    }
    
    // MARK: - setup
    private func setup() {
        addGestureRecognizers()
        setupShareBarItem()
        setupScrollView()
        setupImageView()
    }
    
    private func addGestureRecognizers() {
        view.addGestureRecognizer(tapGestureRecognoser)
        view.addGestureRecognizer(swipeLeftGestureRecognizer)
        view.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    private func setupShareBarItem() {
        navigationItem.rightBarButtonItem = shareBarItem
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupImageView() {
        scrollView.addSubview(imageView)
        imageView.frame = data.imageFrame
        
        NSLayoutConstraint.activate([
            imageViewTopConstraint,
            imageViewLeadingConstraint,
            imageViewWidthConstraint,
            imageViewHeightConstraint,
        ])
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @objc private func didTapShare() {
        let activityViewController = UIActivityViewController(activityItems: [data.imageUrl], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func didTap() {
        navigationController?.navigationBar.isHidden.toggle()
    }
    
    @objc private func swipeLeft() {
        if let newData = data.delegate?.getNextImageLink(currentImageIndex: data.imageIndex) {
            data.imageIndex = newData.index
            data.imageUrl = newData.url
            imageView.kf.setImage(with: data.imageUrl)
        }
    }
    
    @objc private func swipeRight() {
        if let newData = data.delegate?.getPreviousImageLink(currentImageIndex: data.imageIndex) {
            data.imageIndex = newData.index
            data.imageUrl = newData.url
            imageView.kf.setImage(with: data.imageUrl)
        }
    }
}

// MARK: - ImageViewerViewControllerInput
extension ImageViewerViewController: ImageViewerViewControllerInput {
}

// MARK: - Assemble
extension ImageViewerViewController {
    
    static func assemble(data: ImageViewerData) -> UIViewController {
        let view = ImageViewerViewController(data: data)
        let viewModel = ImageViewerViewModel()
        let model = ImageViewerModel(viewModel: viewModel)
        
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.model = model
        return view
    }
}

// MARK: - UIScrollViewDelegate
extension ImageViewerViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}


// MARK: - Data

struct ImageViewerData {
    var imageUrl: URL
    var imageIndex: Int
    let imageFrame: CGRect
    weak var delegate: ImageViewerDelegate?
}

protocol ImageViewerDelegate: AnyObject {
    func getNextImageLink(currentImageIndex: Int) -> (index: Int, url: URL)?
    func getPreviousImageLink(currentImageIndex: Int) -> (index: Int, url: URL)?
}
