//
//  CustomTabBarController2.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/6/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit

class CustomTabBarController2: UIViewController {

    let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var placesButton: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 0
        button.imageView?.image = UIImage(named: "map")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleTabButtonPress), for: .touchUpInside)
        return button
    }()
    
    lazy var middleButton: UIButton = {
        let mb = UIButton(type: .system)
        mb.imageView?.image = UIImage(named: "add")
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.addTarget(self, action: #selector(handleMiddleButtonClick), for: .touchUpInside)
        return mb
    }()
    
    var viewControllers: [UIViewController]!
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        let viewController = ViewController()
        viewControllers = [viewController]
        
        view.addSubview(tabBarView)
        tabBarView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tabBarView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tabBarView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func handleTabButtonPress() {
        
    }
    
    func handleMiddleButtonClick() {
        print(123)
    }
}
