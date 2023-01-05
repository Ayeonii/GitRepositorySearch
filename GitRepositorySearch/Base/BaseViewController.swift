//
//  BaseViewController.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation
import RxSwift
import ReactorKit

//MARK: - TransitionType
enum TransitionType {
    case present
    case push
    case naviPresent
}

//MARK: - Bind Reactor Action And State
protocol BindReactorActionStateProtocol {
    associatedtype ReactorType
    
    func bindAction(_ reactor: ReactorType)
    func bindState(_ reactor: ReactorType)
}

extension BindReactorActionStateProtocol {
    func bind(reactor: ReactorType) {
        self.bindAction(reactor)
        self.bindState(reactor)
    }
}

//MARK: - Transition Protocol
protocol BaseTransitionProtocol {
    var transitionType: TransitionType? { get set }
}

//MARK: - View Protocol
protocol ConfigureViewProtocol {
    func configureLayout()
    func configureLayer()
}

// MARK: - SuperClass of ViewControllers In App
typealias BaseViewController<T: Reactor> = BaseViewControllerClass<T> & BindReactorActionStateProtocol

class BaseViewControllerClass<T: Reactor>: UIViewController, BaseTransitionProtocol, ConfigureViewProtocol {
    
    typealias ReactorType = T
    
    var disposeBag = DisposeBag()
    
    var reactor: T!
    
    var transitionType: TransitionType?
    
    var state: T.State {
        return self.reactor.currentState
    }
    
    deinit {
        log.deinitLog()
    }
    
    init(reactor: T) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.loadViewIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.configureLayer()
    }
    
    func configureLayout() { }
    
    func configureLayer() { }
}

extension BaseViewControllerClass {
    ///Move To Scene
    func transition(to scene: Scene, using style: TransitionType, animated: Bool, completion: (() -> Void)? = nil) {
        let target = scene.instantiate()
        self.moveToTarget(to: target, using: style, animated: animated, completion: completion)
    }
    
    ///Move To ViewController
    func transition(to vc: UIViewController, using style: TransitionType, animated: Bool, completion: (() -> Void)? = nil) {
        self.moveToTarget(to: vc, using: style, animated: animated, completion: completion)
    }
    
    ///Move Action
    private func moveToTarget(to vc: UIViewController, using style: TransitionType, animated: Bool, completion: (() -> Void)? = nil) {
        let target = vc
        
        if var baseVC = target as? BaseTransitionProtocol {
            baseVC.transitionType = style
        }
        
        switch style {
        case .push:
            guard let nav = self.navigationController else { return }
            nav.pushViewController(target, animated: animated, completion: completion)
            
        case .present:
            self.present(target, animated: animated, completion: completion)
            
        case .naviPresent:
            let navTarget = UINavigationController(rootViewController: target)
            self.present(navTarget, animated: animated, completion: completion)
        }
    }
    
    ///Close ViewController By TransitionType Type
    func close(animated: Bool, completion: (() -> Void)? = nil) {
        switch self.transitionType {
        case .push:
            self.navigationController?.popViewController(animated: animated, completion: completion)
            
        case .present, .naviPresent:
            self.dismiss(animated: animated, completion: completion)
            
        default:
            if let nav = self.navigationController {
                nav.popViewController(animated: animated)
            } else if let _ = self.presentingViewController {
                self.dismiss(animated: animated, completion: completion)
            }
        }
    }
}
