//
//  AppScene.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import UIKit

enum AppScene: Scene {

    case qiitaItemList
    case qiitaItemDetail(item: QiitaItem)
    
    var viewController: UIViewController {
        switch self {
        case .qiitaItemList:
            return configureQiiteItemsList()
        case .qiitaItemDetail(let item):
            return configureQiiteItemDetail(item: item)
        }
    }
    
    private func configureQiiteItemsList() -> UIViewController {
        
        let viewController = QiitaItemsListViewController.storyboardInstance
        let presenter = QiitaItemsListPresenter()
        let interactor = QiitaItemsListInteractor(baseApiClient: BaseAPIClient.shared)
        
        self.build(view: viewController,
                   presenter: presenter,
                   interactor: interactor,
                   scenePresenter: viewController)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    private func configureQiiteItemDetail(item: QiitaItem) -> UIViewController {
        
        let viewController = QiitaItemDetailViewController.storyboardInstance
        let presenter = QiitaItemDetailPresenter(item: item)
        let interactor = QiitaItemDetailInteractor()
        
        self.build(view: viewController,
                   presenter: presenter,
                   interactor: interactor,
                   scenePresenter: nil)
        return viewController
    }

}
