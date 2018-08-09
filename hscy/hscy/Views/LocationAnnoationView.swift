//
//  LoacationAnnoation.swift
//  船员版
//
//  Created by dingjianxin on 2017/8/8.
//  Copyright © 2017年 丁建新. All rights reserved.
//
import UIKit
class LocationAnnotationView: MAAnnotationView {
    
    var contentImageView: UIImageView!
    
    var rotateDegree:CGFloat{
        set {
            self.contentImageView.transform = CGAffineTransform(rotationAngle: newValue * CGFloat(M_PI) / 180.0)
        }
        get {
            return self.rotateDegree
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.contentImageView = UIImageView()
        self.addSubview(self.contentImageView)
        self.rotateDegree = 0
    }
    
    func updateImage(image: UIImage!) {
        
        self.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        self.contentImageView.image = image
        self.contentImageView.sizeToFit()
    }
    
    
}
