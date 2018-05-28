import UIKit


final class QiitaItemsListPresenter: Presenter {
    
    typealias Command = QiitaItemListPresenterCommand
    typealias Request = QiitaItemListInteractorRequest
    typealias Event = QiitaItemListViewEvent
    typealias Response = QiitaItemListInteractorResponse
    
    var requestListener: AnyRequestListener<QiitaItemListInteractorRequest>?
    var commandListener: AnyCommandListener<QiitaItemListPresenterCommand>?
    var router: Router?
    var scenePresenter: ScenePresenter?
    
    func handle(event: QiitaItemListViewEvent) {
        switch event {
        case .viewDidLoad:
            self.requestListener?.handle(request: .fetchList(query: "", page: 1))
        case .didSelect(let item):
            self.didSelect(item)
        case .searchBarTextDidChange(let text):
            self.searchBarTextDidChange(text: text)
        case .loadMore(let text):
            self.loadMore(searchText: text)
        case .refresh(let text):
            self.refresh(text: text)
        }
    }
    
    func handle(response: QiitaItemListInteractorResponse) {
        switch response {
        case .listReceived(let result):
            self.listReceived(result: result)
        }
    }
    
    
    struct State: Equatable {
        
        let trigger: TriggerType
        let state: NetworkState
        let nextPage: Int
        let contents: [QiitaItem]
        
        init(trigger: TriggerType,
             state: NetworkState,
             nextPage: Int,
             contents: [QiitaItem]) {
            
            self.trigger = trigger
            self.state = state
            self.nextPage = nextPage
            self.contents = contents
        }
        
        var canLoad: Bool {
            let loadingState: [NetworkState] = [.requesting, .reachedBottom]
            return !loadingState.contains(state)
        }
        
        static func ==(lhs: QiitaItemsListPresenter.State, rhs: QiitaItemsListPresenter.State) -> Bool {
            
            return lhs.state == rhs.state
                && lhs.nextPage == rhs.nextPage
                && lhs.trigger == rhs.trigger
                && lhs.contents == rhs.contents
        }
        
        static let initial = State(trigger: .refresh,
                                   state: .nothing,
                                   nextPage: 1,
                                   contents: [])
    }
    
    
    // MARK: - Private properties -
    private var state: State = State.initial
}
// MARK: - Extensions -

extension QiitaItemsListPresenter {
    
    func viewDidLoad() {
        requestListener?.handle(request: .fetchList(query: "", page: 1))
        
    }
    
    func refresh(text: String) {
        
        if !state.canLoad { return }
        
        state = State(trigger: .refresh, state: .requesting, nextPage: 1, contents: [])
        
        requestListener?.handle(request: .fetchList(query: text, page: 1))
        
    }
    
    func searchBarTextDidChange(text: String) {
        
        if state.state == .requesting { return }
        
        state = State(trigger: .searchTextChange,
                      state: .requesting,
                      nextPage: 1,
                      contents: [])
        
        requestListener?.handle(request: .fetchList(query: text, page: 1))
    }
    
    func loadMore(searchText text: String) {
        
        if !state.canLoad { return }
        
        state = State(trigger: .loadMore,
                      state: .requesting,
                      nextPage: state.nextPage + 1,
                      contents: state.contents)
        
        requestListener?.handle(request: .fetchList(query: text, page: state.nextPage))
    }
    
    func didSelect(_ item: QiitaItem) {
        
        guard let presenter = scenePresenter else {
            return
        }
        router?.present(scene: AppScene.qiitaItemDetail(item: item), scenePresenter: presenter)
    }
}

extension QiitaItemsListPresenter {
    
    private func listReceived(result: ServiceResult<[QiitaItem]>) {
        
        switch result {
            
        case .success(let value):
            
            var networkState: NetworkState = .nothing
            var nextPage = state.nextPage
            
            if value.count == 0 {
                networkState = .reachedBottom
            } else {
                nextPage += 1
            }
            
            state = State(trigger: state.trigger,
                          state: networkState,
                          nextPage: nextPage,
                          contents: state.contents + value)
            
            if state.trigger == .searchTextChange {
                commandListener?.handle(command: .scrollTop)
            }
            
            commandListener?.handle(command: .reload(list: state.contents))
            
        case .failure(let error):
            state = State.initial
            commandListener?.handle(command: .showError(title: "", message: error.debugDescription))
        }
    }
}




