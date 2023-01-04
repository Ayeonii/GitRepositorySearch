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

    lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(SearchDetailTableViewCell.self, forCellReuseIdentifier: SearchDetailTableViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor.action.onNext(.fetchRepository)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
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

extension SearchDetailViewController {
    func setNavigationBar() {
        navigationItem.title = "Repositories"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: nil
        )
    }
}

extension SearchDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let label = UILabel().then {
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .systemGray
            $0.text = "검색결과가 없습니다."
        }
        
        header.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let repos = state.repositories, repos.isEmpty else { return 0 }
        return 60
    }
}

extension SearchDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.repositories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchDetailTableViewCell.identifier, for: indexPath) as? SearchDetailTableViewCell else { return UITableViewCell() }
        
        cell.cellModel = state.repositories?[indexPath.row]
        return cell
    }
}
