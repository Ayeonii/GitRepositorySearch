//
//  SearchOptionsViewController.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/04.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxCocoa
import RxSwift

class SearchOptionsViewController: BaseViewController<SearchOptionsReactor> {
    
    let tableView = UITableView().then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigation()
    }
    
    override func configureLayout() {
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bindAction(_ reactor: SearchOptionsReactor) {
        tableView.rx.modelSelected(String.self)
            .map { optionStr in SearchOptionsReactor.Action.selectOption(optionStr) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: SearchOptionsReactor) {
        reactor.pulse(\.$optionList)
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "DefaultCell", cellType: UITableViewCell.self)) { index, item, cell in
                cell.textLabel?.text = item
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.shouldCloseView }
            .asDriver { _ in .never() }
            .drive(onNext: { [weak self] _ in
                self?.close(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension SearchOptionsViewController {
    func setNavigation() {
        navigationItem.title = reactor.viewType.rawValue
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: nil
        )
        
        navigationItem.leftBarButtonItem?.rx.tap
            .map{ SearchOptionsReactor.Action.closeView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
