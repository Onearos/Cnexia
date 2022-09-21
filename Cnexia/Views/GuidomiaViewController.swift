//
//  GuidomiaViewController.swift
//  Cnexia
//
//  Created by Macbook PRO on 21/09/2022.
//

import UIKit

protocol CarsView: AnyObject {
    func setup(_ viewModel: CarsViewModel)
    func updateContent(_ viewModel: CarsViewModel)
    func insert(_ viewModel: CarsViewModel, indexPath: [IndexPath])
    func delete(_ viewModel: CarsViewModel, indexPath: [IndexPath])
}

struct CarsViewModel {
    static let empty = CarsViewModel()
    
    var headerImage: UIImage?
    var filter: FilterViewModel = .empty
    var sections: [[CarsTableViewItem]] = []
}

final class GuidomiaViewController: UIViewController {

    @IBOutlet weak var headerImage: HeaderImage!
    @IBOutlet private weak var carsTableView: UITableView!
    
    private lazy var presenter: CarsPresenterProtocol = GuidomiaPresenter(view: self)
    private lazy var cellFactory: CarsTableViewCellFactory = .init(tableView: self.carsTableView)
    
    @IBOutlet weak var filterView: FilterView!
    var viewModel: CarsViewModel = .empty
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        filterView.delegate = self
        presenter.sceneDidLoad()
        self.view.backgroundColor = .customOrange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension GuidomiaViewController: CarsView {
    func setup(_ viewModel: CarsViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel = viewModel
            self?.headerImage.imageView.image = viewModel.headerImage
            self?.filterView.setup(viewModel: viewModel.filter)
            self?.headerImage.title.text = "Tacoma 2021"
            self?.headerImage.subtitle.text = "Get your's now"
            self?.carsTableView.reloadData()
        }
    }
    
    func updateContent(_ viewModel: CarsViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel = viewModel
            self?.filterView.setup(viewModel: viewModel.filter)
            self?.carsTableView.reloadData()
        }
    }
    
    func insert(_ viewModel: CarsViewModel, indexPath: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel = viewModel
            self?.carsTableView.beginUpdates()
            self?.carsTableView.insertRows(at: indexPath, with: .automatic)
            self?.carsTableView.endUpdates()
            
            self?.carsTableView.scrollToRow(at: indexPath.first ?? .init(row: 0, section: 0), at: .bottom, animated: true)
        }
    }
    
    func delete(_ viewModel: CarsViewModel, indexPath: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel = viewModel
            self?.carsTableView.beginUpdates()
            self?.carsTableView.deleteRows(at: indexPath, with: .none)
            self?.carsTableView.endUpdates()
        }
    }
}

extension GuidomiaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let car = viewModel.sections[indexPath.section][indexPath.row] as? CarTableViewCellViewModel else {
            return
        }
        
        presenter.didSelectCar(indexPath: car.index)
    }
}

extension GuidomiaViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFactory.build(item: viewModel.sections[indexPath.section][indexPath.row], indexPath: indexPath)
    }
}

extension GuidomiaViewController: FilterViewDelegate {
    func didSelectMake(_ make: String) {
        view.endEditing(true)
        presenter.didChangeMake(make: make)
    }
    
    func didSelectModel(_ model: String) {
        view.endEditing(true)
        presenter.didChangeModel(model: model)
    }
}

private extension GuidomiaViewController {
    func setupTableView() {
        carsTableView.delegate = self
        carsTableView.dataSource = self
        carsTableView.rowHeight = UITableView.automaticDimension
        carsTableView.estimatedRowHeight = UITableView.automaticDimension
        carsTableView.backgroundColor = .white
        carsTableView.separatorStyle = .none
        
        let nib = UINib(nibName: "CarTableViewCell", bundle: nil)
        carsTableView.register(nib, forCellReuseIdentifier: "CarTableViewCell")
        let nib2 = UINib(nibName: "SeparatorTableViewCell", bundle: nil)
        carsTableView.register(nib2, forCellReuseIdentifier: "SeparatorTableViewCell")
        let nib3 = UINib(nibName: "ExpandedCarTableViewCell", bundle: nil)
        carsTableView.register(nib3, forCellReuseIdentifier: "ExpandedCarTableViewCell")
    }
}
