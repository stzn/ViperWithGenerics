import Foundation

final class QiitaItemDetailInteractor: Interactor {
    
    typealias Response = QiitaItemDetailInteractorResponse
    typealias Request = QiitaItemDetailInteractorRequest

    var responseListener: AnyResponseListener<QiitaItemDetailInteractorResponse>?
    
    func handle(request: QiitaItemDetailInteractorRequest) {
    }
}
