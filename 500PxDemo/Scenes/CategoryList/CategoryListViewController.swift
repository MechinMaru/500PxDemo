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
//        tableView.rx.itemSelected.asDriver().drive(onNext: { (<#IndexPath#>) in
//            <#code#>
//        }, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        
        
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
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
