//
//  SearchDetailTableViewCell.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import UIKit
import SnapKit
import Then
import RxSwift

class SearchDetailTableViewCell: UITableViewCell {
    static let identifier = "SearchDetailTableViewCell"

    var disposeBag = DisposeBag()
    
    var imageTask: Disposable?
    
    let repoImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let userNameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .systemGray2
    }
    
    let repoNameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 12, weight: .bold)
    }
    
    let descLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 12)
        $0.numberOfLines = 0
    }
    
    let starButton = UIButton().then {
        $0.setImage(UIImage(systemName: "star"), for: .normal)
        $0.setImage(UIImage(systemName: "star.fill"), for: .selected)
        $0.tintColor = .systemGray
    }
    
    let starCountLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .systemGray
    }
    
    let languageLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .systemGray
    }
    
    var cellModel: SearchDetailCellModel? {
        didSet {
            guard let model = cellModel else { return }
            self.imageTask = repoImage.downloadImage(url: model.image)
            self.userNameLabel.text = model.ownerName
            self.repoNameLabel.text = model.repositoryName
            self.descLabel.text = model.description
            self.starCountLabel.text = model.starCount.toDecimal()
            self.languageLabel.text = model.language
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.dispose()
        repoImage.image = nil
    }
    
    func configureLayout() {
        self.contentView.addSubview(repoImage)
        self.contentView.addSubview(userNameLabel)
        self.contentView.addSubview(repoNameLabel)
        self.contentView.addSubview(descLabel)
        self.contentView.addSubview(starButton)
        self.contentView.addSubview(starCountLabel)
        self.contentView.addSubview(languageLabel)
        
        repoImage.snp.makeConstraints {
            $0.left.top.equalToSuperview().offset(10)
            $0.width.height.equalTo(20)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(repoImage)
            $0.leading.equalTo(repoImage.snp.trailing).offset(3)
        }
        
        repoNameLabel.snp.makeConstraints {
            $0.leading.equalTo(repoImage)
            $0.height.equalTo(15)
            $0.top.equalTo(repoImage.snp.bottom).offset(10)
        }
        
        descLabel.snp.makeConstraints {
            $0.leading.equalTo(repoImage)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.greaterThanOrEqualTo(15)
            $0.top.equalTo(repoNameLabel.snp.bottom).offset(10)
        }
        
        starButton.snp.makeConstraints {
            $0.left.equalTo(repoImage)
            $0.top.equalTo(descLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.width.height.equalTo(18)
        }
        
        starCountLabel.snp.makeConstraints {
            $0.leading.equalTo(starButton.snp.trailing).offset(5)
            $0.centerY.equalTo(starButton)
        }
        
        languageLabel.snp.makeConstraints {
            $0.leading.equalTo(starCountLabel.snp.trailing).offset(10)
            $0.centerY.equalTo(starButton)
        }
    }
}
