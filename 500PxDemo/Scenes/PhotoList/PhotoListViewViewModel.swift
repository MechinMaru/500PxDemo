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
import ImageViewer
import AlamofireImage

enum PhotoCellType {
    case loadingCell
    case photo(Photo)
}

protocol PhotoListViewViewModelInputs {
    func onViewDidLoad()
    func onLoadMore()
    func onPullToRefresh()
    func onSelectedItemAt(_ indexPath: IndexPath)
}

protocol PhotoListViewViewModelOutputs {
    var isRefreshing: Driver<Bool> { get }
    var onRequestShowErrorMessage: Driver<Error> { get }
    var rowData: Driver<[PhotoCellType]> { get }
    func photoCellAtIndex(_ index: Int) -> PhotoCellType
    var galleryData: [GalleryItem] { get }
    var onRequestShowImageViewer: Driver<Int>! { get }
}

protocol PhotoListViewViewModelType {
    var inputs: PhotoListViewViewModelInputs { get }
    var outputs: PhotoListViewViewModelOutputs { get }
}

class PhotoListViewViewModel: BaseViewModel, PhotoListViewViewModelType, PhotoListViewViewModelInputs, PhotoListViewViewModelOutputs {
   
    private var _isLoading = BehaviorRelay<Bool>(value: false)
    var isRefreshing: Driver<Bool> {
        return Driver.combineLatest(_isLoading.asDriver(), _rowData.asDriver(),
                                    resultSelector: { (isLoading, rowData) -> Bool in
                                        return isLoading && rowData.count == 0
                                    })
    }
   
    var galleryData: [GalleryItem] { return _photoData.value }
    var onRequestShowImageViewer: Driver<Int>!

    private var _photoRawData = BehaviorRelay<[Photo]>(value: [Photo]())
    private let _rowData = BehaviorRelay<[PhotoCellType]>(value: [])
    private var _photoData = BehaviorRelay<[GalleryItem]>(value: [])
    var rowData: Driver<[PhotoCellType]> { return _rowData.asDriver() }
    
    private let downloader = ImageDownloader()
    private let _onRequestShowErrorMessage = PublishSubject<Error>()
    private let _currentPage = BehaviorRelay<Int>(value: 0)
    private let _totalPage = BehaviorRelay<Int?>(value: nil)
    
    var onRequestShowErrorMessage: Driver<Error> { return _onRequestShowErrorMessage.asDriver(onErrorDriveWith: Driver.empty()) }
//    private let provider = MoyaProvider<MainService>(stubClosure: MoyaProvider.delayedStub(0.5) ,plugins: [NetworkLoggerPlugin(verbose: true)])
    private let provider = MoyaProvider<MainService>(plugins: [NetworkLoggerPlugin(verbose: true)])

    let disposeBag = DisposeBag()
    
    
    init(_ config: PhotoListViewViewController.Config) {
        super.init()
        
        let pages = Observable.combineLatest(_currentPage, _totalPage, resultSelector: { (current: $0, total: $1) })
        
        Observable
            .merge([
                loadMoreTrigger.asObservable(),
                pullToRefreshTrigger.asObservable(),
                viewDidLoadTrigger.asObservable()
            ])
            .withLatestFrom(_isLoading)
            .filter { $0 == false }
            .withLatestFrom(pages)
            .filter({ (pages) -> Bool in
                if let total = pages.total {
                    return total != pages.current
                }
                return true
            })
            .map { (pages) -> MainService in
                return MainService.photos(categoryType: config.categoryType.categoryName, currentPage: pages.current + 1)
            }
            .do(onNext: { [weak self](_) in
                self?._isLoading.accept(true)
            })
            .flatMapLatest({ [weak self] (service) -> Observable<Event<PhotoResponse>> in
                guard let `self` = self else { return Observable.empty() }
                return self.provider.rx.request(service)
                    .map(PhotoResponse.self)
                    .asObservable()
                    .materialize()
            })
            .flatMapLatest { [weak self] (event) -> Observable<PhotoResponse> in
                switch event {
                    case .completed:
                        break
                    case .next(let element):
                        return Observable.just(element)
                    
                    case .error(let error):
                        self?._onRequestShowErrorMessage.onNext(error)
                        break
                }
                self?._isLoading.accept(false)
                return Observable.empty()
            }
            .asDriver(onErrorDriveWith: Driver.empty())
            .do(onNext: { [weak self] (resp) in
                guard let `self` = self else { return }
                let oldTotalPage = self._totalPage.value
                if oldTotalPage != resp.totalPages {
                    self._totalPage.accept(resp.totalPages)
                }
            })
            .map { (response) -> [Photo] in
                return response.photos
            }
            .withLatestFrom(_photoRawData.asDriver(), resultSelector: { (newData, oldData) -> [Photo] in
                var tempPhotos = oldData
                tempPhotos.append(contentsOf: newData)
                return tempPhotos
            })
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self._isLoading.accept(false)
                self._currentPage.accept(self._currentPage.value + 1)
            })
            .drive(_photoRawData)
            .disposed(by: disposeBag)
        
        Driver.combineLatest(
                _photoRawData.asDriver(),
                _isLoading.asDriver(),
            resultSelector: { (rawData, isLoading) -> [PhotoCellType] in
                var photoArray = [PhotoCellType]()
                for photo in rawData {
                    photoArray.append(PhotoCellType.photo(photo))
                }
                if rawData.count > 0  && isLoading {
                    photoArray.append(PhotoCellType.loadingCell)
                }
                return photoArray
            })
            .drive(_rowData)
            .disposed(by: disposeBag)
        
        _photoRawData.asDriver()
            .map { [weak self] (photos) -> [GalleryItem] in
                guard let `self` = self else { return [] }
                var galleryItems = [GalleryItem]()
                
                for photo in photos {
                    if let url = URL(string: photo.imageUrl[1]) {
                        let urlRequest = URLRequest(url: url)
                        let galleryItem = GalleryItem.image(fetchImageBlock: { [weak self] (completion) in
                            self?.downloader.download(urlRequest, completion: { (response) in
                                if let image = response.result.value {
                                    completion(image)
                                }
                            })
                        })
                        galleryItems.append(galleryItem)
                    }
                }
                return galleryItems
            }
            .drive(_photoData)
            .disposed(by: disposeBag)
        
       onRequestShowImageViewer = selectedItemTrigger
            .asDriver(onErrorDriveWith: Driver.empty())
            .withLatestFrom(_rowData.asDriver()) { (indexPath, rowData) -> Int? in
                if case PhotoCellType.photo = rowData[indexPath.item] {
                    return indexPath.item
                }else{
                    return nil
                }
            }
            .filter { $0 != nil }
            .map {$0!}
        
        
    }

    private let viewDidLoadTrigger = PublishSubject<Void>()
    func onViewDidLoad() {
        viewDidLoadTrigger.onNext(())
    }
    
    private var loadMoreTrigger = PublishSubject<Void>()
    func onLoadMore() {
        loadMoreTrigger.onNext(())
    }
    
    private var pullToRefreshTrigger = PublishSubject<Void>()
    func onPullToRefresh() {
        _currentPage.accept(0)
        _totalPage.accept(nil)
        _photoRawData.accept([Photo]())
        pullToRefreshTrigger.onNext(())
    }
    
    func photoCellAtIndex(_ index: Int) -> PhotoCellType {
        return _rowData.value[index]
    }
    
    private var selectedItemTrigger = PublishSubject<IndexPath>()
    func onSelectedItemAt(_ indexPath: IndexPath) {
        selectedItemTrigger.onNext(indexPath)
    }
    var inputs: PhotoListViewViewModelInputs { return self }
    var outputs: PhotoListViewViewModelOutputs { return self }                                         

}
