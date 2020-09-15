//
//  ItemPreviewViewController.swift
//  GoShopping
//
//  Created by Juntao Qiu on 11/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class ItemPreviewViewController: UIViewController {
    var imageView : UIImageView!
    var itemName: String!
    var image: Data!
    
    init(itemName: String, image: Data) {
        super.init(nibName: nil, bundle: nil)
        self.itemName = itemName
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let imageView = UIImageView(frame: .zero)
        imageView.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        self.preferredContentSize = imageView.frame.size
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 240),
            imageView.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        imageView.contentMode = .scaleAspectFill
        
        self.imageView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(data: image) // getImageOf(itemName: itemName, fallbackImageName: image)
    }
    
}
