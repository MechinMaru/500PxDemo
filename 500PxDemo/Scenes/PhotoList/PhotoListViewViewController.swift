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
    
    lazy var viewModel: PhotoListViewViewModelType = {
		return PhotoListViewViewModel(config)
	}()

    var config: Config!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindInputs()
        bindOutputs()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindInputs() {
        viewModel.inputs.onViewDidLoad()
        
    }
    
    private func bindOutputs() {
        viewModel
            .outputs
            .isLoading
            .drive(UIApplication.shared.rx.isNetworkIndicatorAnimated)
            .disposed(by: disposeBag)
        
        viewModel.outputs.onRequestShowErrorMessage
            .drive(onNext: { [weak self] (error) in
                let alertVC = UIAlertController(title: "Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertVC.addAction(okAction)
                self?.navigationController?.present(alertVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
