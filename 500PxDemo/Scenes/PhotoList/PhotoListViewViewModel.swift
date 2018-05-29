//
//  PhotoListViewViewModel.swift
//  500PxDemo
//
//  Created by MECHIN on 5/29/18.
//Copyright © 2018 MECHIN. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya


protocol PhotoListViewViewModelInputs {
    func onViewDidLoad()
}

protocol PhotoListViewViewModelOutputs {
    var isLoading: ActivityIndicator { get }
    var onRequestShowErrorMessage: Driver<Error> { get }
    var onRequestShowPhotoDataSource: Driver<[Photo]> { get }

}

protocol PhotoListViewViewModelType {
    var inputs: PhotoListViewViewModelInputs { get }
    var outputs: PhotoListViewViewModelOutputs { get }
}

class PhotoListViewViewModel: BaseViewModel, PhotoListViewViewModelType, PhotoListViewViewModelInputs, PhotoListViewViewModelOutputs {
   
    var isLoading = ActivityIndicator()
   
    private var _photoRowData = BehaviorRelay<[Photo]>(value: [Photo]())
    var onRequestShowPhotoDataSource: Driver<[Photo]> {
        return _photoRowData.asDriver(onErrorDriveWith: Driver.empty())
    }

    private let _onRequestShowErrorMessage = PublishSubject<Error>()
    var onRequestShowErrorMessage: Driver<Error> { return _onRequestShowErrorMessage.asDriver(onErrorDriveWith: Driver.empty()) }
    
    let disposeBag = DisposeBag()
    init(_ config: PhotoListViewViewController.Config) {
        super.init()
        
        let photoResponse = viewDidLoadTrigger
            .map { (_) -> MainService in
                return MainService.photos(categoryType: config.categoryType.categoryName)
            }
            .flatMapLatest({ [weak self] (service) -> Observable<Event<PhotoResponse>> in
                guard let `self` = self else { return Observable.empty() }
                let provider = MoyaProvider<MainService>()
                return provider.rx.request(service)
                    .trackActivity(self.isLoading)
                    .map(PhotoResponse.self)
                    .materialize()
            })
            .flatMapLatest { (event) -> Observable<PhotoResponse> in
                switch event {
                    case .completed:
                        break
                    case .next(let element):
                        return Observable.just(element)
                        break
                    case .error(let error):
                        self._onRequestShowErrorMessage.onNext(error)
                        break
                }
                return Observable.empty()
            }
            .asDriver(onErrorDriveWith: Driver.empty())
            .map { (response) -> [Photo] in
                return response.photos
            }
            .drive(_photoRowData)

    }

    private let viewDidLoadTrigger = PublishSubject<Void>()
    func onViewDidLoad() {
        viewDidLoadTrigger.onNext(())
    }
    
    var inputs: PhotoListViewViewModelInputs { return self }
    var outputs: PhotoListViewViewModelOutputs { return self }                                         

}
