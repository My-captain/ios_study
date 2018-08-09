//
//  FriendBoatLayout.swift
//  hscy
//
//  Created by dingjianxin on 2017/12/18.
//  Copyright © 2017年 marinfo. All rights reserved.
//function：地图nearView好友船舶collectionView的布局

import Foundation
class FriendBoatLayout: UICollectionViewFlowLayout {
     fileprivate var attributesArr: [UICollectionViewLayoutAttributes] = []
    override func prepare(){
        super.prepare()
        let col:CGFloat=3
        let row: CGFloat=2
        let w=(collectionView!.bounds.width-(col+1)*10)/col
        let h=(collectionView!.bounds.height-(row+1)*10)/row
        let margin=CGFloat((collectionView!.bounds.height-row*w)*0.5)
        itemSize=CGSize(width: w, height:h )
         minimumInteritemSpacing=10
         minimumLineSpacing=10
//        collectionView?.contentInset = UIEdgeInsetsMake(margin, 0, margin, 0)
        sectionInset=UIEdgeInsets(top: 10, left: 10, bottom:10, right: 10)
        
        scrollDirection = .vertical
        collectionView?.isPagingEnabled=true
//        collectionView?.bounces=false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = true
        collectionView?.alwaysBounceVertical=true
        
        
    }
       
    override var collectionViewContentSize: CGSize {
        let size: CGSize = super.collectionViewContentSize
        let collectionViewWidth: CGFloat = self.collectionView!.frame.size.width
        let nbOfScreen: Int = Int(ceil(size.width / collectionViewWidth))
        let newSize: CGSize = CGSize(width: collectionViewWidth * CGFloat(nbOfScreen), height: size.height)
        return newSize
    }
    
    
}


