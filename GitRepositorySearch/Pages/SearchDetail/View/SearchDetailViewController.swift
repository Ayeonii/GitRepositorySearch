//
//  SearchDetailViewController.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import UIKit
import ReactorKit
import RxSwift
import SnapKit
import Then

class SearchDetailViewController: BaseViewController<SearchDetailReactor> {
    
    let tableView = UITableView().then {
        $0.register(SearchDetailTableViewCell.self, forCellReuseIdentifier: SearchDetailTableViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
    }
    
    func bindAction(_ reactor: SearchDetailReactor) {
        
    }
    
    func bindState(_ reactor: SearchDetailReactor) {
        
    }
}
