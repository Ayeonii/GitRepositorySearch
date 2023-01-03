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
    
    lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.register(SearchDetailTableViewCell.self, forCellReuseIdentifier: SearchDetailTableViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
        self.reactor.action.onNext(.fetchRepository)
    }
    
    func bindAction(_ reactor: SearchDetailReactor) {
        
    }
    
    func bindState(_ reactor: SearchDetailReactor) {
        
    }
}

extension SearchDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchDetailTableViewCell.identifier, for: indexPath) as? SearchDetailTableViewCell else { return UITableViewCell() }
        
        cell.cellModel = state.repositories[indexPath.row]
        return cell
    }
}
