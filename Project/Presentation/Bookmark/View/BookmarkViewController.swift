//
//  BookmarkViewController.swift
//  Project
//
//  Created by rayeon lee on 2023/07/05.
//

import UIKit
import RxSwift

class BookmarkViewController: UIViewController {
    private let coordinator: BookmarkCoordinator
    
    private let bookmarkViewModel : BookmarkViewModelType
    
    private var disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let refreshControl = UIRefreshControl()
    
    init(coordinator : BookmarkCoordinator, viewModel : BookmarkViewModelType) {
        self.bookmarkViewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setupViews()
        setConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        navigationItem.title = "Bookmark"
        
        refreshControl.endRefreshing()
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: DefaultTableViewCell.identifier)
    }
    
    private func setupBindings() {
        //MARK: - Inputs
        Observable.of(rx.viewWillAppear, refreshControl.rx.controlEvent(.valueChanged))
            .merge()
            .bind(to: bookmarkViewModel.inputs.refreshModels)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(UserListTableViewCellModel.self)
            .bind(to: bookmarkViewModel.inputs.selectModel)
            .disposed(by: disposeBag)
        
        // MARK: - Outputs
        bookmarkViewModel.outputs.users
            .drive(tableView.rx.items(cellIdentifier: DefaultTableViewCell.identifier, cellType: DefaultTableViewCell.self)){ [weak self] index, item, cell in
                guard let self = self else { return }
                cell.fill(with: item, index: index, bookmarkButtonTap: self.bookmarkViewModel.inputs.markModel)
            }
            .disposed(by: disposeBag)
        
        bookmarkViewModel.outputs.refreshCompleted
            .emit(with: self, onNext: { owner, state in
                owner.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        bookmarkViewModel.outputs.showModel
            .emit(with: self, onNext: { owner, user in
                owner.coordinator.navigateToDetail(with: user)
            })
            .disposed(by: disposeBag)
        
        bookmarkViewModel.outputs.markCompleted
            .emit(with: self, onNext: { owner, idx in
                owner.tableView.reloadRows(at: [IndexPath(item: idx, section: 0)], with: .none)
            })
            .disposed(by: disposeBag)
        
        
    }

}

// MARK: - func setConstraints
extension BookmarkViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
