import UIKit
import WebKit

final class QiitaItemDetailViewController: UIViewController, View {

    typealias Command = QiitaItemDetailPresenterCommand
    typealias Event = QiitaItemDetailViewEvent
    
    func handle(command: QiitaItemDetailPresenterCommand) {
        switch command {
        case .reload(let url):
            showWebView(url: url)
        case .showError( _, let message):
            showErrorAlert(message: message)
        }
    }
    
    var eventListener: AnyEventListener<QiitaItemDetailViewEvent>?
    
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        showLoading()
        eventListener?.handle(event: .viewDidLoad)
    }
}

// MARK: - Extensions -

extension QiitaItemDetailViewController {
    private func showWebView(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension QiitaItemDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoading()
    }
}
extension QiitaItemDetailViewController: StoryboardInstantiable {
    static var storyboardName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

