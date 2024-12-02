//
//  ContainerController.swift
//  Uber Clone
//
//  Created by S M H  on 05/10/2024.

import UIKit

private let identifier = "MenuCell"

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips: return "Yours trips"
        case .settings: return "Settings"
        case .logout: return "Logout"
        }
    }
}

protocol MenuControllerDelegate {
    func didSelectOption(option: MenuOptions)
}

class MenuController: UIViewController {
    
    //MARK: - Properties
    private var user: User
    
    var delegate: MenuControllerDelegate?
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        let view = MenuHeader(user: user, frame: frame)
        return view
    }()
    
    private var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        return tableView
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMenuTableView()
        
        view.backgroundColor = .backgroundColor
        view.addSubview(menuTableView)
    }

    //MARK: - Selector
    
    

    //MARK: - Helper Functions
    private func configureMenuTableView() {
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.tableHeaderView = menuHeader
        
        // FIXME: - Bug for top padding
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let topPadding = window?.safeAreaInsets.top
        
        menuTableView.frame = CGRect(x: 0, y: topPadding!, width: view.frame.width-80, height: view.frame.height)
    }
}

extension MenuController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let description = MenuOptions.allCases[indexPath.row].description
        guard let desp = MenuOptions(rawValue: indexPath.row)?.description else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = desp
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let option = MenuOptions(rawValue: indexPath.row) else { return }
        delegate?.didSelectOption(option: option)
        
    }
    
    
}
