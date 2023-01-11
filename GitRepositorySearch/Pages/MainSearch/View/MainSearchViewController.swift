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
import RxGesture
import Then

class MainSearchViewController: BaseViewController<MainSearchReactor> {
    private var resultVC = SearchFilterResultViewController()
    
    lazy var searchController = UISearchController(searchResultsController: resultVC).then {
        $0.searchBar.placeholder = "Search Repositories"
        $0.hidesNavigationBarDuringPresentation = true
        $0.obscuresBackgroundDuringPresentation = false
        $0.showsSearchResultsController = true
        $0.searchBar.setValue("Cancel", forKey: "cancelButtonText")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultVC.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }
    
    func bindAction(_ reactor: MainSearchReactor) {
        searchController.searchBar.rx.text
            .debounce(RxTimeInterval.microseconds(300), scheduler: MainScheduler.instance)
            .map { text in MainSearchReactor.Action.filterRecentList(text) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.searchButtonClicked
            .compactMap { [weak self] in self?.searchController.searchBar.text }
            .map { MainSearchReactor.Action.goToResult($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: MainSearchReactor) {
        reactor.pulse(\.$filteredList)
            .bind(to: resultVC.tableView.rx.items(cellIdentifier: SearchFilterTableViewCell.identifier, cellType: SearchFilterTableViewCell.self)) { index, item, cell in
                
                cell.cellModel = item
                
                cell.coverView.rx.tapGesture()
                    .when(.recognized)
                    .map { _ in MainSearchReactor.Action.goToResult(cell.cellModel?.title) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                
                cell.deleteBtn.rx.tap
                    .map { MainSearchReactor.Action.deleteRecent(cell.cellModel) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.moveToDetailText }
            .asDriver { _ in .never() }
            .drive(onNext: { [weak self] text in
                self?.moveToSearchDetail(text: text)
            })
            .disposed(by: disposeBag)
    }
}

extension MainSearchViewController {
    func setupNavigation() {
        navigationItem.title = "GitHub"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
    }
    
    func moveToSearchDetail(text: String) {
        let reactor = SearchDetailReactor(searchText: text)
        self.transition(to: .searchDetailView(reactor), using: .push, animated: true) {
            self.reactor.action.onNext(.saveRecentText(text))
        }
    }
}

extension MainSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView().then {
            $0.backgroundColor = .clear
        }
        
        let label = UILabel().then {
            $0.textAlignment = .left
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.text = "Recent searches"
        }
        
        let clearBtn = UIButton().then {
            $0.setTitle("Clear", for: .normal)
            $0.setTitleColor(.link, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14)
        }
        
        header.addSubview(label)
        header.addSubview(clearBtn)
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.centerY.equalToSuperview()
        }
        
        clearBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
        
        clearBtn.rx.tap
            .map { MainSearchReactor.Action.clearRecentList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
