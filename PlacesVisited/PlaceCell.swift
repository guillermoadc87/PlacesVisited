//
//  PlaceCell.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/11/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupLayout()
    }
    
    func setupLayout() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlaceCell: BaseCell {
    
    var place: Place? {
        didSet {
            label.text = place?.name
            let image = UIImage(data: place?.photoData as! Data)
            imageView.image = image
            favoriteView.isHidden = (place?.isFavorite)!
            
            if let title = label.text {
                let size = CGSize(width: frame.width, height: frame.height)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedRect = NSString(string: title).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil)
                
                if estimatedRect.size.width > frame.size.width {
                    print(frame.size.width)
                    label.frame.size.width = frame.size.width
                } else {
                    label.frame.size.width = estimatedRect.size.width
                }
                print(estimatedRect.size.width, frame.size.width, label.frame.size.width)
                
            }
        }
    }
    
    var imageView: UIImageView = {
        var iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    var favoriteView: UIImageView = {
        var iv = UIImageView()
        iv.image = UIImage(named: "heart")
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let checkMark: CheckMark = {
        let checkMark = CheckMark()
        checkMark.isHidden = true
        checkMark.backgroundColor = UIColor.clear
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        return checkMark
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    override var isSelected: Bool {
//        didSet {
//            checkMark.isHidden = !isSelected
//            imageView.alpha = isSelected ? 0.5 : 1
//        }
//    }
    
    override func setupLayout() {
        addSubview(imageView)
        addSubview(label)
        addSubview(favoriteView)
        addSubview(checkMark)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        favoriteView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        favoriteView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        favoriteView.widthAnchor.constraint(equalToConstant: frame.size.width / 6).isActive = true
        favoriteView.heightAnchor.constraint(equalToConstant: frame.size.height / 6).isActive = true
        
        checkMark.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        checkMark.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        checkMark.widthAnchor.constraint(equalToConstant: frame.size.width / 6).isActive = true
        checkMark.heightAnchor.constraint(equalToConstant: frame.size.height / 6).isActive = true
    }
    
    func selected(_ bool: Bool) {
        checkMark.isHidden = !bool
        imageView.alpha = bool ? 0.5 : 1
    }
    
}
