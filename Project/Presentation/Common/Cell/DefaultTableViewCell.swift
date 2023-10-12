//
//  UserInfoTableViewCell.swift
//  Project
//
//  Created by rayeon lee on 2023/04/03.
//

import RxSwift
import UIKit

class DefaultTableViewCell: UITableViewCell {
    static let identifier = "DefaultTableViewCell"
    
    static let estimatedCellHeight: CGFloat = 90
    
    let containerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 5
        container.clipsToBounds = true
        return container
    }()

    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    let markButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .gray
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .selected)
        return button
    }()
    
    var disposeBag = DisposeBag()
    
    private var cellModel: UserListTableViewCellModel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func setupViews(){
        contentView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(markButton)
        self.backgroundColor = .white
        self.selectionStyle = .none
    }
    
    func fill(with cellModel: UserListTableViewCellModel, index: Int, bookmarkButtonTap : PublishSubject<(DataBaseActionType, Int, UserListTableViewCellModel)>) {
        self.cellModel = cellModel
      
        self.cellModel.title
            .asDriver()
            .drive(nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.cellModel.imagePath
            .filter { $0 != nil }
            .map { $0! }
            .flatMap({
                ImageCacheService.shared.loadImage(from: $0)
            })
            .asDriver(onErrorJustReturn: nil)
            .drive(profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        self.cellModel.bookmark
            .asDriver()
            .drive(markButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        self.markButton.rx.tap
            .scan(markButton.isSelected) { (lastState, newValue) in
                !lastState
            }
            .map { (state) -> DataBaseActionType in
                state ? .add : .delete
            }
            .map { ($0, index, cellModel) }
            .bind {
                bookmarkButtonTap.onNext($0)
            }
            .disposed(by: disposeBag)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        nameLabel.text = ""
        profileImageView.image = nil
        markButton.isSelected = false
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension DefaultTableViewCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            containerView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            profileImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            profileImageView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            markButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            markButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }
    
}
