//
//  RecentSearchTableViewCell.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture

class SearchFilterTableViewCell: UITableViewCell {
    static let identifier = "RecentSearchTableViewCell"
    
    var disposeBag = DisposeBag()
    
    var coverView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    lazy var deleteBtn = UIButton().then {
        $0.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.titleLabel.text = nil
    }
    
    func configureLayout() {
        contentView.addSubview(coverView)
        coverView.addSubview(titleLabel)
        coverView.addSubview(deleteBtn)
        
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
        }
        
        deleteBtn.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
        }
    }
}
