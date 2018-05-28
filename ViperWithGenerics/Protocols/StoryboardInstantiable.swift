//
//  StoryboardInstantiable.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable {
    static var storyboardId: String { get }
    static var storyboardName: String { get }
}

extension StoryboardInstantiable where Self: UIViewController {
    static var storyboardInstance: Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardId)
        return viewController as! Self
    }
    static var storyboardId: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
