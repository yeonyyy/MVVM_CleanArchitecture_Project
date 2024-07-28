# MVVM_CleanArchitecture_Project
MVVM + Clean Architecture + repository pattern 적용한 샘플 앱의 구현

### 개발 환경
* Swift5, iOS13 이상

### Includes
* Clean Architecture
* MVVM Pattern + RxSwift / RxCocoa
* Repository Pattern
* Flow Coordinator Pattern
* Data Transfer Object(DTO)
* RxRealm / RealmSwift
* URLSession + EndPoint

### 주요 개발 사항
* Clean Architecure를 적용한 아키텍처 설계
  1. 의존성 역전 적용 : 모듈은 구현체가 아닌 추상화된 Interface에 의존하도록 구현.
  ```Swift

  protocol UserListViewModelType {
    var inputs: UserListViewModelInputs { get }
    var outputs: UserListViewModelOutputs { get }
  }
  
  class UserListViewController: UIViewController {
    private let userListViewModel : UserListViewModelType
    //...
  }
  
  protocol UserListUseCase {
    func fetchUserList(requestValue: FetchUserListRequestValue) -> Observable<[User]>
    func updateBookmark(action:DataBaseActionType, user:User) -> Observable<Void>
  }

  final class UserListViewModel : UserListViewModelType, UserListViewModelInputs, UserListViewModelOutputs {
    private let userListUseCase: UserListUseCase
    //...
  }
  ```
  2. Repository 패턴 적용: app의 business logic을 담고 있는 UseCase는 외부 데이터에 직접 접근해서는 안된다. usecase는 repository interface에만 의존하도록 구현. repository 구현체에서 외부 데이터에 접근하는 작업을 수행하도록 구현.
  ```Swift
  
  protocol UserRepository {
    func fetchUser(with url: String) -> Observable<User>
    func fetchUserList(per_page: Int, page: Int) -> Observable<[User]>
    func updateBookmark(_ action:DataBaseActionType, _ user:User) -> Observable<Void>
    func readAll() -> Observable<[User]>
  }

  final class DefaultUserListUseCase: UserListUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func fetchUserList(requestValue: FetchUserListRequestValue) -> Observable<[User]> {
        return self.userRepository.fetchUserList(per_page: requestValue.per_page, page: requestValue.since)
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] remoteUsers -> Observable<[User]> in
                guard let self = self else { return Observable.empty() }
                return self.userRepository.readAll().map { localUsers in
                    return remoteUsers.map { remoteUser in
                        var new = remoteUser
                        new.mark = localUsers.contains(remoteUser)
                        return new
                    }
                }
            }
    }
    
    func updateBookmark(action:DataBaseActionType, user:User) -> Observable<Void> {
        return self.userRepository.updateBookmark(action, user)
    }
  }
  
  ```

  3. Domain Object 적용 : usecase와 infrastructure layer는 분리되야 한다. Usecase는 dto가 아닌 domain object에 의존하도록 구현. Repository 구현체에서 DTO로부터 domain object로 변환하는 작업을 수행.
  ```Swift

  extension DefaultUserRepository: UserRepository {
    func fetchUserList(per_page: Int, page: Int) -> Observable<[User]>{
        let requestDTO = UserRequestDTO(per_page: per_page, since: page)
        let endpoint = APIEndpoints.getUsers(with: requestDTO)
        return self.dataTransferService.request(with: endpoint)
            .map { $0.map{ $0.toDomain() } }
    }
    //...
  }

  
  final class DefaultUserListUseCase: UserListUseCase {
    private let userRepository: UserRepository
    //...
  
    func fetchUserList(requestValue: FetchUserListRequestValue) -> Observable<[User]> {
        return self.userRepository.fetchUserList(per_page: requestValue.per_page, page: requestValue.since)
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] remoteUsers -> Observable<[User]> in
                guard let self = self else { return Observable.empty() }
                return self.userRepository.readAll().map { localUsers in
                    return remoteUsers.map { remoteUser in
                        var new = remoteUser
                        new.mark = localUsers.contains(remoteUser)
                        return new
                    }
                }
            }
    }
    //...
  }
  
  ```

### 스크린샷
<p align="left">
  <img src="https://github.com/yeonyyy/MVVM_CleanArchitecture_Project/assets/73291852/efcf8ba7-09e6-47ba-9b6b-b9c73ee5c934" width="200" height="400">
  <img src="https://github.com/yeonyyy/MVVM_CleanArchitecture_Project/assets/73291852/8f3c9b46-cca1-4ebc-a339-7dae311fe5ec" width="200" height="400">
  <img src="https://github.com/yeonyyy/MVVM_CleanArchitecture_Project/assets/73291852/ee7ae9da-5938-4a62-8270-a937f344fc0f" width="200" height="400">
</p>

### 참고문헌 
https://github.com/kudoleh/iOS-Clean-Architecture-MVVM
