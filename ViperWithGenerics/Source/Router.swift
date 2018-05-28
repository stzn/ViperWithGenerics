//
//  Router.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import UIKit

class Router {
    func launch(scene: Scene) {
        let window = UIApplication.shared.keyWindow
        let viewController = scene.viewController
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
    func present(scene: Scene, scenePresenter: ScenePresenter) {
        let viewController = scene.viewController
        scenePresenter.present(viewController: viewController)
    }
}

