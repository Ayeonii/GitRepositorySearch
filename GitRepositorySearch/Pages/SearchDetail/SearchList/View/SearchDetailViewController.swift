//
//  SearchDetailViewController.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import UIKit
import ReactorKit
import RxCocoa
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
            .asDriver{ _ in .never() }
            .drive(onNext: {[weak self] _ in
                guard let self = self else { return }
                UIView.transition(with: self.tableView,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData()})
                
                guard self.tableView.numberOfRows(inSection: 0) > 0 else { return }
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .filter{ $0.shouldShowMenu }
            .asDriver{ _ in .never() }
            .drive(onNext: {[weak self] _ in
                self?.showMenuAction()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$pagingRows)
            .filter{ !$0.isEmpty }
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] rows in
                let insertIndexPaths: [IndexPath] = rows.map {IndexPath(row: $0, section: 0)}
                self?.tableView.insertRows(at: insertIndexPaths, with: .fade)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.moveLink }
            .asDriver{ _ in .never() }
            .drive(onNext: { link in
                if let url = URL(string: link) {
                    UIApplication.shared.open(url, options: [:])
                }
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
            action: #selector(menuAction)
        )
    }
    
    @objc private func menuAction() {
        reactor.action.onNext(.showMenu)
    }
    
    func showMenuAction() {
        let alertController = UIAlertController(title: "Search options", message: nil, preferredStyle: .actionSheet)
        
        let sortAction = UIAlertAction(title: SearchOptionsType.sort.rawValue, style: .default) { _ in
            self.showOptionPage(optionType: .sort)
        }
        
        let orderAction = UIAlertAction(title: SearchOptionsType.order.rawValue, style: .default) { _ in
            self.showOptionPage(optionType: .order)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(sortAction)
        alertController.addAction(orderAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    func showOptionPage(optionType: SearchOptionsType) {
        let optionReactor = SearchOptionsReactor(viewType: optionType)
        self.transition(to: .searchOptionsView(optionReactor), using: .naviPresent, animated: true)
        
        optionReactor.state
            .compactMap{ $0.selectedSortOption }
            .map{ option in SearchDetailReactor.Action.sortOption(option)}
            .bind(to: reactor.action)
            .disposed(by: optionReactor.disposeBag)
        
        optionReactor.state
            .compactMap{ $0.selectedOrderOption }
            .map{ option in SearchDetailReactor.Action.orderOption(option)}
            .bind(to: reactor.action)
            .disposed(by: optionReactor.disposeBag)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let link = state.repositories?[indexPath.row].linkUrl else { return }
        reactor.action.onNext(.moveToLink(link))
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
