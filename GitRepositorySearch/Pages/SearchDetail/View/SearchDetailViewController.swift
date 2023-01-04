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
        $0.backgroundColor = .systemPink
        $0.dataSource = self
        $0.register(SearchDetailTableViewCell.self, forCellReuseIdentifier: SearchDetailTableViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
        self.reactor.action.onNext(.fetchRepository)
    }
    
    override func configureLayout() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bindAction(_ reactor: SearchDetailReactor) {
        tableView.rx.contentOffset
            .filter { [weak self] point in
                guard let self = self,
                      !self.state.isFetching,
                      !self.state.endPaging
                else { return false }

                let offset = point.y
                let collectionViewContentSizeY = self.tableView.contentSize.height
                let paginationY = collectionViewContentSizeY * 0.3
                return offset > collectionViewContentSizeY - paginationY
            }
            .map { _ in SearchDetailReactor.Action.fetchRepository }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: SearchDetailReactor) {
        reactor.state
            .filter{ $0.shouldReload }
            .observe(on: MainScheduler.instance)
            .bind(onNext: {[weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$pagingRows)
            .filter{ !$0.isEmpty }
            .asDriver { _ in .never() }
            .drive(onNext: { [weak self] rows in
                let insertIndexPaths: [IndexPath] = rows.map {IndexPath(row: $0, section: 0)}
                self?.tableView.insertRows(at: insertIndexPaths, with: .fade)
            })
            .disposed(by: disposeBag)
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
