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
        resultVC.tableView.delegate = self
        setupNavigation()
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
    }
    
    func bindState(_ reactor: MainSearchReactor) {
        reactor.pulse(\.$filteredList)
            .bind(to: resultVC.tableView.rx.items(cellIdentifier: RecentSearchTableViewCell.identifier, cellType: RecentSearchTableViewCell.self)) {[weak self] index, item, cell in
                guard let self = self else { return }

                cell.titleLabel.text = item
              
                cell.coverView.rx.tapGesture()
                    .when(.recognized)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] _ in
                        let clickedText = cell.titleLabel.text ?? ""
                        self?.reactor.action.onNext(.goToResult(clickedText))
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.deleteBtn.rx.tap
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        let text = cell.titleLabel.text ?? ""
                        self?.reactor.action.onNext(.deleteRecent(text))
                    })
                    .disposed(by: cell.disposeBag)
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
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.reactor.action.onNext(.clearRecentList)
            })
            .disposed(by: disposeBag)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}


