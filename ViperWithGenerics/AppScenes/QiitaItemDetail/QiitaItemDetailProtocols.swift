//
//  QiitaItemDetailProtocols.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import Foundation

enum QiitaItemDetailPresenterCommand: PresenterCommand {
    case reload(url: URL)
    case showError(title: String, message: String)
}

enum QiitaItemDetailViewEvent: ViewEvent {
    case viewDidLoad
}

enum QiitaItemDetailInteractorRequest: InteractorRequest {
}

enum QiitaItemDetailInteractorResponse: InteractorResponse {
}
