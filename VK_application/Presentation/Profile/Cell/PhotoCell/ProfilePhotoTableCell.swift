//
//  ProfilePhotoTableCell.swift
//  VK_application
//
//  Created by Сергей Чумовских  on 25.10.2021.
//

import UIKit

class ProfilePhotoTableCell: UITableViewCell {
    
    static let identifier = "ProfilePhotoTableCell"
    
    private let collectionView: UICollectionView
    private var models = [PhotoesItems]()
    
    private let photoesCount: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 130, height: 130)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(ProfilePhotoCollectionCell.self, forCellWithReuseIdentifier: ProfilePhotoCollectionCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        contentView.addSubview(collectionView)
        contentView.addSubview(photoesCount)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoesCount.frame = CGRect(
            x: 16,
            y: 8,
            width: contentView.frame.width,
            height: 16)
        collectionView.frame = CGRect(
            x: 0,
            y: 32,
            width: contentView.frame.width,
            height: contentView.frame.height-35)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with photoesCollection: [PhotoesItems]) {
        self.models = photoesCollection
        self.photoesCount.text = "Фотографии  \(models.count)"
        collectionView.reloadData()
    }
    
}



extension ProfilePhotoTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfilePhotoCollectionCell.identifier,
            for: indexPath) as! ProfilePhotoCollectionCell
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
