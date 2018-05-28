//
//  QiitaItemListProtocols.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import Foundation

enum QiitaItemListPresenterCommand: PresenterCommand {
    case reload(list: [QiitaItem])
    case scrollTop
    case showError(title: String, message: String)
    case showNoContent
}

enum QiitaItemListViewEvent: ViewEvent {
    case viewDidLoad
    case didSelect(item: QiitaItem)
    case searchBarTextDidChange(text: String)
    case loadMore(text: String)
    case refresh(text: String)
}

enum QiitaItemListInteractorRequest: InteractorRequest {
    case fetchList(query: String, page: Int)
}

enum QiitaItemListInteractorResponse: InteractorResponse {
    case listReceived(result: ServiceResult<[QiitaItem]>)
}
