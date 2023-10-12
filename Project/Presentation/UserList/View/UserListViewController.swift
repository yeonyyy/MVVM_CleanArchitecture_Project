//
//  ViewController.swift
//  Project
//
//  Created by rayeon lee on 2023/04/02.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class UserListViewController: UIViewController {
    private var coordinator : UserListCoordinator?

    private let userListViewModel : UserListViewModel
    
    private var disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        return tableView
    }()
  
    private lazy var viewSpinner: UIView = {
        let view = UIView(frame: CGRect(
                            x: 0,
                            y: 0,
                            width: view.frame.size.width,
                            height: 100)
        )
        let spinner = UIActivityIndicatorView()
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        return view
    }()
    
    let refreshControl = UIRefreshControl()
    
    init(coordinator: UserListCoordinator?, viewModel : UserListViewModel) {
        self.userListViewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "home"
        navigationItem.largeTitleDisplayMode = .never
        setupViews()
        setConstraints()
        setupBindings()
    }
    
    private func setupViews(){
        view.backgroundColor = .white
        view.addSubview(tableView)
    
        refreshControl.endRefreshing()
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: DefaultTableViewCell.identifier)
      
    }
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel()
        toastLabel.font = font
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.alpha = 1.0
        let textSize = toastLabel.intrinsicContentSize
        let y = view.frame.height - ((self.tabBarController?.tabBar.frame.height ?? 0) + textSize.height + 40)
        toastLabel.frame = CGRect(x: 0, y: y, width: textSize.width + 20, height: textSize.height + 20)
        toastLabel.center.x = self.view.center.x
        toastLabel.layer.cornerRadius = 10
        toastLabel.layer.masksToBounds = true
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 1, delay: 0.3, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    private func setupBindings(){
        //MARK: - Inputs    
        Observable.of(rx.viewWillAppear, refreshControl.rx.controlEvent(.valueChanged))
            .merge()
            .bind(to: userListViewModel.inputs.refreshModels)
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll
            .subscribe(with: self) { owner, _  in
                let offSetY = owner.tableView.contentOffset.y
                let contentHeight = owner.tableView.contentSize.height
                
                let moreLoading = offSetY > (contentHeight - owner.tableView.frame.size.height - 100)
                owner.userListViewModel.inputs.loadMoreModels.onNext(moreLoading)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(UserListTableViewCellModel.self)
            .bind(to: userListViewModel.inputs.selectModel)
            .disposed(by: disposeBag)
    
        // MARK: - Outputs
        userListViewModel.outputs.users
            .drive(tableView.rx.items(cellIdentifier: DefaultTableViewCell.identifier, cellType: DefaultTableViewCell.self)){ [weak self] index, item, cell in
                guard let self = self else { return }
                cell.fill(with: item, index: index, bookmarkButtonTap: self.userListViewModel.inputs.markModel)
            }
            .disposed(by: disposeBag)
        
        userListViewModel.outputs.isfooterLoading
            .drive(with: self, onNext: { owner, state in
                owner.tableView.tableFooterView = state ? self.viewSpinner : UIView(frame: .zero)
            })
            .disposed(by: disposeBag)
        
        userListViewModel.outputs.showModel
            .emit(with: self, onNext: { owner, user in
                owner.coordinator!.navigateToDetail(with: user)
            })
            .disposed(by: disposeBag)
        
        userListViewModel.outputs.markCompleted
            .emit(onNext: { [weak self] (idx, action) in
                let message = (action == .add ? "즐겨찾기에 추가되었습니다." : "즐겨찾기에서 삭제되었습니다.")
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)
        
        userListViewModel.outputs.refreshCompleted
            .emit(with: self, onNext: { owner, _ in
                owner.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        userListViewModel.outputs.error
            .emit(with: self, onNext: { owner, errorString in
                owner.presentAlert(message: errorString ?? "")
            }).disposed(by: disposeBag)
        
    }

}


extension UserListViewController {
    private func setConstraints(){
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

    }
}
