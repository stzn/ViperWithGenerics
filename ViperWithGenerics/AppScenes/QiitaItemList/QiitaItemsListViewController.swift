import UIKit

protocol QiitaItemsListViewControllerDelegate: class {
    func showDetail(_ controller: QiitaItemsListViewController, item: QiitaItem)
}

final class QiitaItemsListViewController: UIViewController, View {
    
    typealias Event = QiitaItemListViewEvent
    typealias Command = QiitaItemListPresenterCommand
    
    var eventListener: AnyEventListener<QiitaItemListViewEvent>?
    
    func handle(command: QiitaItemListPresenterCommand) {
        switch command {
        case .reload(let list):
            self.reload(list: list)
        case .scrollTop:
            self.scrolltoTop()
        case .showError(let title, let message):
            showAlert(title: title, message: message)
        case .showNoContent:
            showNoContentScreen()
        }
    }
    
    
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private properties -
    private var items: [QiitaItem] = []
    private var reachedBottom : Bool = false
    private var cellHeightList: [IndexPath: CGFloat] = [:]
    private var imageLoadQueue = OperationQueue()
    private var imageLoadOperations = [IndexPath: ImageLoadOperation]()
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchText: String = ""
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoading()
        _setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventListener?.handle(event: .viewDidLoad)
    }
    
    private func _setupUI() {
        
        navigationItem.title = "List"
        
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.delegate = self
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        setTableView()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    private func setTableView() {
        
        tableView.register(QiitaItemTableViewCell.self)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for:.valueChanged)
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
    }
}

// MARK: - Extensions -

extension QiitaItemsListViewController {
    
    @objc func refresh(sender: UIRefreshControl) {
        
        let text = searchController.searchBar.text ?? ""
        eventListener?.handle(event: .refresh(text: text))
    }
}

extension QiitaItemsListViewController {
    
    func reload(list: [QiitaItem]) {
        items = list
        
        DispatchQueue.main.async { [weak self] in
            guard let s = self else {
                return
            }
            s.noResultLabel.isHidden = true
            s.tableView.isHidden = false
            s.hideLoading()
            s.refreshControl.endRefreshing()
            s.tableView.reloadData()
        }
    }
    
    func showNoContentScreen() {
        self.noResultLabel.text = "データが存在しません。"
        self.noResultLabel.isHidden = false
        self.tableView.isHidden = true
        hideLoading()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func scrolltoTop() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        guard items.count > indexPath.row else {
            return
        }
        
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
}

extension QiitaItemsListViewController: StoryboardInstantiable {
    static var storyboardName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

extension QiitaItemsListViewController: ScenePresenter {
    func present(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension QiitaItemsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: QiitaItemTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        guard items.count > indexPath.row else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configure(item: item)
        
        if let imageLoadOperation = imageLoadOperations[indexPath],
            let image = imageLoadOperation.image {
            cell.profileImageView.setRoundedImage(image)
        } else {
            guard let url = item.user?.profile_image_url else {
                return cell
            }
            let imageLoadOperation = ImageLoadOperation(url: url)
            imageLoadOperation.completionHandler = { [weak self] image in
                guard let strongSelf = self else {
                    return
                }
                cell.profileImageView.setRoundedImage(image)
                strongSelf.imageLoadOperations.removeValue(forKey: indexPath)
            }
            imageLoadQueue.addOperation(imageLoadOperation)
            imageLoadOperations[indexPath] = imageLoadOperation
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let imageLoadOperation = imageLoadOperations[indexPath] else {
            return
        }
        imageLoadOperation.cancel()
        imageLoadOperations.removeValue(forKey: indexPath)
    }
}

extension QiitaItemsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let item = items[indexPath.row]
        eventListener?.handle(event: .didSelect(item: item))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !cellHeightList.keys.contains(indexPath) {
            cellHeightList[indexPath] = cell.frame.size.height
        }
        
        let isLastCell = (items.count - 1 == indexPath.row)
        
        if isLastCell {
            let text = searchController.searchBar.text ?? ""
            eventListener?.handle(event: .loadMore(text: text))
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = cellHeightList[indexPath] {
            return height
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
}

extension QiitaItemsListViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        eventListener?.handle(event: .searchBarTextDidChange(text: ""))
    }
}

extension QiitaItemsListViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            if let _ = imageLoadOperations[indexPath] {
                return
            }
            
            guard items.count > indexPath.row else {
                return
            }
            
            let item = items[indexPath.row]
            guard let url = item.user?.profile_image_url else {
                return
            }
            let imageLoadOperation = ImageLoadOperation(url: url)
            imageLoadOperations[indexPath] = imageLoadOperation
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            guard let imageLoadOperation = imageLoadOperations[indexPath] else {
                return
            }
            imageLoadOperation.cancel()
            imageLoadOperations.removeValue(forKey: indexPath)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension QiitaItemsListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchBarTextDidChange(_:)), object: searchController.searchBar)
        
        perform(#selector(self.searchBarTextDidChange(_:)), with: searchController.searchBar, afterDelay: 0.75)
    }
    
    
    @objc func searchBarTextDidChange(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text,
            !text.isEmpty, searchText != text else { return }
        
        searchText = text
        eventListener?.handle(event: .searchBarTextDidChange(text: text))
    }
}



