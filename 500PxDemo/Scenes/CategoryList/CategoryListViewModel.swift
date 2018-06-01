//
//  CategoryListViewModel.swift
//  500PxDemo
//
//  Created by MECHIN on 5/27/18.
//Copyright © 2018 MECHIN. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol CategoryListViewModelInputs {
    func onSelectItemAt(_ indexPath: IndexPath)
}

protocol CategoryListViewModelOutputs {
    var onRequestShowRowData: Driver<[CategoryType]> { get }
    var onRequestGoToPhotoListPage: Driver<CategoryType>! { get }
}

protocol CategoryListViewModelType {
    var inputs: CategoryListViewModelInputs { get }
    var outputs: CategoryListViewModelOutputs { get }
}

class CategoryListViewModel: BaseViewModel, CategoryListViewModelType, CategoryListViewModelInputs, CategoryListViewModelOutputs {

    var onRequestShowRowData: Driver<[CategoryType]> { return rowData.asDriver() }
    var onRequestGoToPhotoListPage: Driver<CategoryType>!
    
    private var rowData = BehaviorRelay<[CategoryType]>(value: CategoryType.categoryList)
    let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        onRequestGoToPhotoListPage = itemTrigger.asDriver(onErrorDriveWith: Driver.empty())
    }
    
    private let itemTrigger = PublishSubject<CategoryType>()
    func onSelectItemAt(_ indexPath: IndexPath) {
        let item = rowData.value[indexPath.row]
        itemTrigger.onNext(item)
    }

    var inputs: CategoryListViewModelInputs { return self }
    var outputs: CategoryListViewModelOutputs { return self }                                         

}
