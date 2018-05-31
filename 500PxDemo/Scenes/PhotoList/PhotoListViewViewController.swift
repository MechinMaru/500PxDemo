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
import ImageViewer

class PhotoListViewViewController: BaseViewController {

    struct Config {
        let categoryType: CategoryType
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
   
    @IBOutlet var galleryFooterView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authourLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    
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
        
        // setup Layout
        authorImageView.layer.cornerRadius = authorImageView.frame.width / 2
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
        
            collectionView.rx.itemSelected
                .asDriver()
                .drive(onNext: { [weak self] (indexPath) in
                    self?.viewModel.inputs.onSelectedItemAt(indexPath)
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
            .do(onNext: { [weak self](_) in
//                self?.galleryViewController?.fetch
            })
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
        
        viewModel.outputs.onRequestShowImageViewer
            .drive(onNext: { [weak self] (startIndex) in
                guard let `self` = self else { return }
                let galleryConfiguration: [GalleryConfigurationItem] = [
                    GalleryConfigurationItem.deleteButtonMode(.none),
                    GalleryConfigurationItem.seeAllCloseButtonMode(.none),
                    GalleryConfigurationItem.thumbnailsButtonMode(.none),
                    GalleryConfigurationItem.footerViewLayout(FooterLayout.center(0))
                ]
                
                let galleryViewController = GalleryViewController(startIndex: 0, itemsDataSource: self, configuration: galleryConfiguration)
                self.galleryFooterView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120)
                galleryViewController.footerView = self.galleryFooterView
                
                galleryViewController.landedPageAtIndexCompletion = { [weak self] (index) in
                    guard let `self` = self else { return }
                    
                    let indexPath = IndexPath(item: index, section: 0)
                    let photoCell = self.viewModel.outputs.itemAtIndexPath(indexPath)
                    
                    if case PhotoCellType.photo(let photo) = photoCell {
                        self.titleLabel.text = photo.name
                        let user = photo.user
                        var informantionStr = user.fullname
                        if let city = user.city,
                            !city.isEmpty {
                            informantionStr.append(", \(city)")
                        }
                        
                        if let country = user.country,
                            !country.isEmpty {
                            informantionStr.append(", \(country)")
                        }
                        self.authourLabel.text = informantionStr
                        
                        if let imageUrl = URL(string: user.userPicUrl) {
                            self.authorImageView.af_setImage(withURL: imageUrl, placeholderImage: R.image.person_grey())
                        }
                    }
                    
                }
                self.presentImageGallery(galleryViewController)
            })
            .disposed(by: disposeBag)
        
    }
    
    @objc private func refreshPhotoList (_ sender: Any) {
        viewModel.inputs.onPullToRefresh()
    }
    
}

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

extension PhotoListViewViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return viewModel.outputs.galleryData.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return viewModel.outputs.galleryData[index]
    }
}
