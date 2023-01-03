//
//  SearchDetailTableViewCell.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import UIKit
import SnapKit
import Then

class SearchDetailTableViewCell: UITableViewCell {
    static let identifier = "SearchDetailTableViewCell"

    var cellModel: SearchDetailCellModel? {
        didSet {
            guard let model = cellModel else { return }
            
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
    }
    
    func configureLayout() {
       
    }
}
