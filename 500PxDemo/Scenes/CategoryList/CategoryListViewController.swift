//
//  CategoryListViewController.swift
//  500PxDemo
//
//  Created by MECHIN on 5/27/18.
//Copyright © 2018 MECHIN. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var viewModel: CategoryListViewModelType = {
		return CategoryListViewModel()
	}()

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindInputs()
        bindOutput()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func bindInputs() {
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] (indexPath) in
                self?.viewModel.inputs.onSelectItemAt(indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel
            .outputs
            .onRequestShowRowData
            .drive(tableView.rx.items) { (tableView, row, item) in
                let indexPath = IndexPath(row: 0, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.categoryCell, for: indexPath)!
                cell.configureLayout(item)
                return cell
        }
        .disposed(by: disposeBag)
        
       
        viewModel
            .outputs
            .onRequestGoToPhotoListPage
            .drive(onNext: { (categoryType) in
                self.performSegue(withIdentifier: R.segue.categoryListViewController.categoryListGoToPhotoListPage, sender: categoryType)
            })
            .disposed(by: disposeBag)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoListVC = R.segue.categoryListViewController.categoryListGoToPhotoListPage(segue: segue),
            let categoryType = sender as? CategoryType {
            photoListVC.destination.config = PhotoListViewViewController.Config(categoryType: categoryType)
        }
    }
}
