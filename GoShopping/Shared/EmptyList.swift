//
//  EmptyList.swift
//  GoShopping
//
//  Created by Juntao Qiu on 13/9/20.
//  Copyright © 2020 Juntao Qiu. All rights reserved.
//

import UIKit

class EmptyList: UIView {
    
    private var label: String!
    private var image: String!
    
    init(frame: CGRect, label: String, image: String) {
        super.init(frame: frame)
        
        self.label = label
        self.image = image
        
        
        self.layer.opacity = 0.5
        let label = UILabel()
        label.textColor = UIColor(named: "FontColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.label
        label.textAlignment = .center
        
        let imageView = UIImageView(frame: .zero)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.backgroundColor = UIColor(named: "blue")
        imageView.image = UIImage(named: self.image)
        
        self.addSubview(imageView)
        self.addSubview(label)
        
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
