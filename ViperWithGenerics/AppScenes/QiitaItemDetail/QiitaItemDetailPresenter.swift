import UIKit

final class QiitaItemDetailPresenter: Presenter {
    
    typealias Command = QiitaItemDetailPresenterCommand
    typealias Request = QiitaItemDetailInteractorRequest
    typealias Event = QiitaItemDetailViewEvent
    typealias Response = QiitaItemDetailInteractorResponse
    
    var requestListener: AnyRequestListener<QiitaItemDetailInteractorRequest>?
    var commandListener: AnyCommandListener<QiitaItemDetailPresenterCommand>?
    var router: Router?
    var scenePresenter: ScenePresenter?
    
    
    private var item: QiitaItem
    init(item: QiitaItem) {
        self.item = item
    }
    
    func handle(event: QiitaItemDetailViewEvent) {
        switch event {
        case .viewDidLoad:
            self.viewDidLoad()
        }
    }
    
    func handle(response: QiitaItemDetailInteractorResponse) {
    }
}

// MARK: - Extensions -

extension QiitaItemDetailPresenter {
    func viewDidLoad() {
        commandListener?.handle(command: .reload(url: item.url))
    }
}
