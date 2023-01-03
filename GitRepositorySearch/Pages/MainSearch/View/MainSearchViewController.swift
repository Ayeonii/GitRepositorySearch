//
//  MainSearchViewController.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import Then

class MainSearchViewController: BaseViewController<MainSearchReactor> {
    private var resultVC = SearchResultViewController()
    
    lazy var searchController = UISearchController(searchResultsController: resultVC).then {
        $0.searchBar.placeholder = "Search Repositories"
        $0.hidesNavigationBarDuringPresentation = true
        $0.obscuresBackgroundDuringPresentation = false
        $0.showsSearchResultsController = true
        $0.searchBar.setValue("Cancel", forKey: "cancelButtonText")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    func bindAction(_ reactor: MainSearchReactor) {
        searchController.searchBar.rx.text
            .debounce(RxTimeInterval.microseconds(200), scheduler: MainScheduler.instance)
            .map { text in MainSearchReactor.Action.filterRecentList(text) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.searchButtonClicked
            .compactMap { [weak self] in return self?.searchController.searchBar.text }
            .map { MainSearchReactor.Action.goToResult($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resultVC.tableView.rx.modelSelected(String.self)
            .map{ title in MainSearchReactor.Action.goToResult(title) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: MainSearchReactor) {
        reactor.pulse(\.$filteredList)
            .bind(to: resultVC.tableView.rx.items(cellIdentifier: RecentSearchTableViewCell.identifier, cellType: RecentSearchTableViewCell.self)) { index, item, cell in
                cell.titleLabel.text = item
            }
            .disposed(by: disposeBag)
    
        reactor.state
            .compactMap{ $0.moveToDetailText }
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] text in
                self?.moveToSearchDetail(text: text)
            })
            .disposed(by: disposeBag)
    }
    
    override func configureLayout() {
        
    }
}

extension MainSearchViewController {
    func setupNavigation() {
        navigationItem.title = "GitHub"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    func moveToSearchDetail(text: String) {
        let reactor = SearchDetailReactor(searchText: text)
        self.transition(to: .searchDetailView(reactor), using: .push, animated: true)
    }
}

