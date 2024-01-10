//
//  UserDetailViewController.swift
//  Project
//
//  Created by rayeon lee on 2023/04/02.
//

import UIKit
import RxSwift
import RxCocoa

class UserDetailViewController: UIViewController {
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        return label
    }()
    
    let blogLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        return label
    }()
    
    private var viewModel : UserDetailViewModelType!
    
    private let disposeBag = DisposeBag()
    
    init(viewModel : UserDetailViewModelType) {
        self.viewModel = viewModel
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
        view.addSubview(profileImageView)
        view.addSubview(titleLabel)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(blogLabel)
        view.backgroundColor = .white
        hidesBottomBarWhenPushed = true
    }
    
    private func setupBindings(){
        // MARK: - Inputs
        rx.viewWillAppear
            .asObservable()
            .bind(to: viewModel.inputs.fetchModel)
            .disposed(by: disposeBag)
        
        // MARK: - Outputs
        viewModel.outputs.title.drive(titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.fullname.drive(nameLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.blog.drive(blogLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.email.drive(emailLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.image.drive(profileImageView.rx.image).disposed(by: disposeBag)
    
    }
    
}

// MARK: - func setConstraints
extension UserDetailViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            emailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            blogLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            blogLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            blogLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    
    }
    
}
