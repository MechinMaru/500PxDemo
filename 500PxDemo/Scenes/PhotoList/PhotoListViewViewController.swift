//
//  PhotoListViewViewController.swift
//  500PxDemo
//
//  Created by MECHIN on 5/29/18.
//Copyright © 2018 MECHIN. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoListViewViewController: BaseViewController {

    struct Config {
        let categoryType: CategoryType
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    
    lazy var viewModel: PhotoListViewViewModelType = {
		return PhotoListViewViewModel(config)
	}()

    var config: Config!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindInputs()
        bindOutputs()
        
        viewModel.inputs.onViewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func setupView() {
        self.title = config.categoryType.categoryName
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshPhotoList(_:)), for: .valueChanged)
//        collectionView.dataSource = self
    }
    
    private func bindInputs() {
        
        collectionView.rx
            .willDisplayCell
            .asDriver()
            .withLatestFrom(viewModel.outputs.rowData) { (arg0, rowData) -> Bool  in
                let lastIndex = rowData.count - 1
                if arg0.at.item == lastIndex {
                    let item = rowData[arg0.at.item]
                    if case PhotoCellType.photo = item {
                        return true
                    }
                }
                return false
            }
            .filter { $0 }
            .drive(onNext: { [weak self] (_) in
                self?.viewModel.inputs.onLoadMore()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputs() {
        
        viewModel
            .outputs
            .isRefreshing
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .rowData
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: collectionView.rx.items) { (collectionView, item, element) in
//            .drive(collectionView.rx.items) { (collectionView, item, element) in
                let indexPath = IndexPath(item: item, section: 0)
                switch element {
                    case .loadingCell:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.loadingCell, for: indexPath)!
                        cell.indicatorView.startAnimating()
                        return cell

                    case .photo(let photo):
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.photoCell, for: indexPath)!
                        cell.configureLayoutWithModel(photo)
                        return cell

                }
            }
            .disposed(by: disposeBag)
    
        
        viewModel.outputs.onRequestShowErrorMessage
            .drive(onNext: { [weak self] (error) in
                print(error)
                
                let alertVC = UIAlertController(title: "Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertVC.addAction(okAction)
                self?.navigationController?.present(alertVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
    }
    
    @objc private func refreshPhotoList (_ sender: Any) {
        viewModel.inputs.onPullToRefresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

//extension PhotoListViewViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return viewModel.outputs.rowCount
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let element = viewModel.outputs.itemAtIndexPath(indexPath)
//        switch element {
//            case .loadingCell:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.loadingCell, for: indexPath)!
//                cell.indicatorView.startAnimating()
//                return cell
//
//            case .photo(let photo):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.photoCell, for: indexPath)!
//                cell.configureLayoutWithModel(photo)
//                return cell
//
//        }
//    }
//}

extension PhotoListViewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellType = viewModel.outputs.itemAtIndexPath(indexPath)
        switch cellType {
        case .loadingCell:
            return CGSize(width: collectionView.frame.size.width, height: 44)

        case .photo:
            let cellWidth = (collectionView.frame.size.width / 2)
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }
    
}
