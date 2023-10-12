//
//  RealmStorage.swift
//  Project
//
//  Created by rayeon lee on 2023/07/06.
//

import UIKit
import RxRealm
import RxSwift
import RealmSwift

enum DataBaseActionType {
    case add
    case delete
}

final class RealmStorage {
    
    static let shared = RealmStorage()
    private var realm = try! Realm()
    
    func getLocationOfDefaultRealm() {
        print("Realm is located at:", realm.configuration.fileURL!)
    }
    
    func write<R: RealmRepresentable>(action:DataBaseActionType, entity: R) -> Observable<Void> where R.RealmType: Object {

        return Observable.create { observer in
            switch action {
            case .add:
                do {
                    try self.realm.write {
                        self.realm.add(entity.asRealm())
                        
                        observer.onNext(())
                        observer.onCompleted()
                    }
                } catch {
                    observer.onError(error)
                }
            case .delete:
                do {
                    guard let object = self.realm.object(ofType: R.RealmType.self, forPrimaryKey: entity.id) else { fatalError() }

                    try self.realm.write {
                        self.realm.delete(object)
                        
                        observer.onNext(())
                        observer.onCompleted()
                    }

                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func read<R: RealmRepresentable>() -> Observable<[R]> where R == R.RealmType.DomainType, R.RealmType : Object {
        return Observable.create { observer in
                let result = self.realm.objects(R.RealmType.self)
                                    .sorted(byKeyPath: "id", ascending: true)
                                    .map { $0.asDomain() }

                observer.onNext(Array(result))
                observer.onCompleted()

            return Disposables.create()
        }
        
        
    }
    
}
