//
//  SettingViewController.swift
//  Uber Clone
//
//  Created by S M H  on 28/10/2024.
//

import UIKit

private let reuseIdentifier = "LocationTableViewCell"

protocol SettingControllerDelegate: AnyObject {
    func didUpdateUserData(_ controller: SettingViewController)
}

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home: "Home"
        case .work: "Work"
        }
    }
    
    var subTitle: String {
        switch self {
        case .home: "Add Home"
        case .work: "Add Work"
        }
    }
}

class SettingViewController: UITableViewController {
      
    //MARK: - Properties
    
    var user: User
    
    var delegate: SettingControllerDelegate?
    
    var userInfoUpdated = false
    
    private let locationManager = LocationHandler.shared.locationManager
    
    private lazy var infoHeaderView: UserInfoHeaderView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100 )
        let info = UserInfoHeaderView(user: user, frame: frame)
        return info
    }()
    
    //MARK: - Lifecycle 
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureTableView()
        configureNavigationBar()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Function
    
    func configureTableView() {
        tableView.rowHeight = 60
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeaderView
        tableView.sectionHeaderTopPadding = 0
        tableView.tableFooterView = UIView()
    }
    
    func configureNavigationBar() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barTintColor = .backgroundColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: FileNames.crossButton), style: .plain, target: self, action: #selector(handleDismissal))
    }
    
    /*
        -   switch on locationType and return it's related string if exit
     */
    func saveLocationText(forType type: LocationType) -> String {
        switch type {
        case .home:
            return user.homeLocation ?? type.subTitle
        case .work:
            return user.workLocation ?? type.subTitle
        }
    }
    
    //MARK: - Selector
    
    @objc func handleDismissal() {
        if userInfoUpdated {
            delegate?.didUpdateUserData(self)
        }
        
        self.dismiss(animated: true)
    }
}

//MARK: - UITableViewDelegate and Datasource

extension SettingViewController {
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        
        let title = UILabel()
        title.text = "Favourites"
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        
        view.addSubview(title)
        title.centerY(inView: view, left: view.leftAnchor, paddingLeft: 16)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationTableViewCell
        
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        
        let content = cell.defaultContentConfiguration()
        cell.contentConfiguration = content
        cell.titleLabel.text = type.description
        cell.addressLabel.text = saveLocationText(forType: type)
        
//        cell.locationType = type
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        
        guard let location = locationManager?.location else { return }
        
        let controller = SaveLocationController(location: location, locationType: type)
        controller.delegate = self
        
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
}

//MARK: - SaveLocationController Delegate

extension SettingViewController: SaveLocationControllerDelegate {
    
    func updateSaveLocation(locationString: String, type: LocationType) {
        
        PassengerService.shared.saveLocation(locationString: locationString, locationType: type) { err, ref in
            
            self.dismiss(animated: true, completion: nil)
            self.userInfoUpdated = true
            
            switch type {
            case.home:
                self.user.homeLocation = locationString
            case.work:
                self.user.workLocation = locationString
            }
            
            self.tableView.reloadData()
        }
    }
    
}

/// Explaination for user save location procedure
/*
 -  after save location -> set user location in class -> reloadData
 -  get saveLocationString base on locationType -> configure in saveLocationString Func
 -  update at cellForRowAt -> set cell titleLable and addressLable from saveLocationString
 */

/// Explaination for update user info in containerViewController
/*
 -  create delegate for containerViewController -> update in container user object
 -  create userInfoUpdate Bool status for to call delegate
 */
