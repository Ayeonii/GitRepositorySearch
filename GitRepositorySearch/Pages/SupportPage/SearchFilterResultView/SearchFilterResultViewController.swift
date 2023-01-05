//
//  SearchResultViewController.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import UIKit
import SnapKit
import Then

class SearchFilterResultViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.register(SearchFilterTableViewCell.self, forCellReuseIdentifier: SearchFilterTableViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    func configureLayout() {
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
