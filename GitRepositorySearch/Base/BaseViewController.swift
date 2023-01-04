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
    static let defaultDimmColor = UIColor.black.withAlphaComponent(0.6)
    case dimmPresent(from: PresentationDirection = .bottom, dimmColor: UIColor = TransitionType.defaultDimmColor)
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

//MARK: - View Transition
protocol BaseTransitionProtocol {
    var transitionType : TransitionType? {get set}
}

//MARK: - View Protocol
protocol ConfigureViewProtocol {
    func configureLayout()
    func configureLayer()
}

// MARK: - SuperClass of Common ViewControllers
typealias BaseViewController<T: Reactor> = BaseViewControllerClass<T> & BindReactorActionStateProtocol

class BaseViewControllerClass<T: Reactor>: UIViewController, BaseTransitionProtocol, ConfigureViewProtocol {

    typealias ReactorType = T
    
    lazy var dimmTransitionDelegate = DimmPresentManager()
    
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
    
    func configureLayout() {}
    
    func configureLayer() {}
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
    func moveToTarget(to vc: UIViewController, using style: TransitionType, animated: Bool, completion: (() -> Void)? = nil) {
        let target = vc
        
        if var baseVC = target as? BaseTransitionProtocol {
            baseVC.transitionType = style
        }
        
        switch style {
        case .push:
            guard let nav = self.navigationController else { return }
            nav.pushViewController(target, animated: animated, completion: completion)
            
        case .dimmPresent(let from, let dimmColor):
            dimmTransitionDelegate.direction = from
            dimmTransitionDelegate.dimmColor = dimmColor
            target.modalPresentationStyle = .custom
            target.transitioningDelegate = dimmTransitionDelegate
            
            self.present(target, animated: animated, completion: completion)
            
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
        case .present, .dimmPresent, .naviPresent:
            self.dismiss(animated: animated, completion: completion)
        default:
            if let nav = self.navigationController {
                nav.popViewController(animated: animated)
            } else if let _ = self.presentingViewController {
                self.dismiss(animated: animated, completion: completion)
            }
        }
    }
    
    ///Close Presenting NavigationController
    func closePresentedNavigation(animated: Bool, completion: (() -> Void)? = nil) {
        self.navigationController?.dismiss(animated: animated, completion: completion)
    }
    
    ///Move To RootViweController
    func moveToRoot(animated: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let rootNav = UIApplication.shared.windows.first?.rootViewController?.navigationController {
                rootNav.dismiss(animated: animated) {
                    rootNav.popToRootViewController(animated: animated)
                    completion?()
                }
            }
        }
    }
}

