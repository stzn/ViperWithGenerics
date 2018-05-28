import Foundation

final class QiitaItemsListInteractor: Interactor {
    
    typealias Response = QiitaItemListInteractorResponse
    typealias Request = QiitaItemListInteractorRequest
    
    var responseListener: AnyResponseListener<QiitaItemListInteractorResponse>?
    
    
    private let baseApiClient: BaseAPIClient
    
    init (baseApiClient: BaseAPIClient) {
        self.baseApiClient = baseApiClient
    }
    
    func handle(request: QiitaItemListInteractorRequest) {
        switch request {
        case .fetchList(let query, let page):
            fetchList(query: query, page: page)
        }
    }
    
    private func fetchList(query: String, page: Int) {
        let resource = Resource<[QiitaItem]>(requestRouter: RequestRouter.fetchList(query: query, page: page))
        
        do {
            
            try baseApiClient.request(resource) { [weak responseListener] result in
                
                switch result {
                case .success(let value):
                    responseListener?.handle(
                        response: .listReceived(result: ServiceResult.success(value)))
                case .failure(let error):
                    responseListener?.handle(
                        response: .listReceived(result: ServiceResult.failure(error)))
                }
            }
            
        } catch {
            responseListener?.handle(
                response: .listReceived(result: ServiceResult.failure(error as! ApplicationError)))
        }
    }
}


