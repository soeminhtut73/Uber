//
//  ContainerController.swift
//  Uber Clone
//
//  Created by S M H  on 05/10/2024.
//

import UIKit
import Firebase

class ContainerController: UIViewController {
    
    //MARK: - Properties
    
    private let homeViewController = HomeViewController()
    private var menuController: MenuController!
    private var isExpanded = false
    private let blackView = UIView()
                                
    private var user: User? {
        didSet{
            guard let user = user else { return }
            homeViewController.user = user
            configureMenuController(withUser: user)
        }
    }

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        
        fetchUserData()
        
        configureHomeViewController()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //MARK: - API
    
    private func fetchUserData() {
        guard let uID = Auth.auth().currentUser?.uid else { return }
        
        Service.shared.fetchUser(uID: uID) { user in
            DispatchQueue.main.async {
                self.user = user
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Signout success!")
            
            self.navigationController?.pushViewController(LoginViewController(), animated: false)
            
        } catch {
            print("DEBUG: Fail to Sign out \(error.localizedDescription)")
        }
    }

    //MARK: - Helper Functions
    
    private func configureHomeViewController() {
        homeViewController.delegate = self
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        view.addSubview(homeViewController.view)
        
        configureBlackView()
    }
    
    private func configureMenuController(withUser user: User) {
        menuController = MenuController(user: user )
        addChild(menuController)
        menuController.delegate = self
        
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view , at: 0)
    }
    
    // animate for side menu
    private func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        
        animateStatusBar()
        
        let xOrigin = view.frame.width - 80
        
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                
                self.homeViewController.view.frame.origin.x = xOrigin
                
                ///  Bug in blackView background
                self.blackView.alpha = 0.1
                self.blackView.frame = CGRect(x: xOrigin,
                                              y: 0,
                                              width: 80,
                                              height: self.view.frame.height)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                
                self.blackView.alpha = 0
                
                self.homeViewController.view.frame.origin.x = 0
                
            }, completion: completion)
        }
        
        
    }
    
    private func configureBlackView() {
        blackView.frame = view.bounds
        blackView.backgroundColor = .clear
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
        
    }
    
    private func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    //MARK: - Selector
    @objc func dismissMenu() {
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
}

//MARK: - SettingControllerDelegate

extension ContainerController: SettingControllerDelegate {
    
    func didUpdateUserData(_ controller: SettingViewController) {
        self.user = controller.user
    }
}


//MARK: - HomeViewControllerDelegate

extension ContainerController: HomeViewControllerDelegate {
    
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
    
}

//MARK: - MenuControllerDelegate

extension ContainerController: MenuControllerDelegate {
    
    func didSelectOption(option: MenuOptions) {
        
        isExpanded.toggle()
        
        animateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
                
            case .settings:
                guard let user = self.user else { return }
                
                // Initiate SettingViewController
                let controller = SettingViewController(user: user)
                controller.delegate = self
                
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
    
            case .logout:
                
                let alert = UIAlertController(title: nil,
                                              message: "Are you sure to logout?",
                                              preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                    self.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
    }
}


