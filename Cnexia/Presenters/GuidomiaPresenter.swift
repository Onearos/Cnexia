//
//  GuidomiaPresenter.swift
//  Cnexia
//
//  Created by Macbook PRO on 21/09/2022.
//

import UIKit

protocol CarsPresenterProtocol {
    func sceneDidLoad()
    func sceneWillAppear()
    func didSelectCar(indexPath: Int)
    func didChangeMake(make: String)
    func didChangeModel(model: String)
}

final class GuidomiaPresenter {
    var fetchCars: FetchCars
    var fetchImage: FetchImage
    weak var view: CarsView?
    var expandedItemIndex: Int = 0
    var selectedMake = "Any Make"
    var selectedModel = "Any Model"
    
    private var cars: [Car] = [] {
        didSet {
            filteredCars = cars
        }
    }
    
    private var filteredCars: [Car] = [] {
        didSet {
            updateView()
        }
    }
    
    init(fetchCars: FetchCars = FetchCarsAdapter(),
         fetchImage: FetchImage = FetchImageAdapter(),
         view: CarsView?) {
        self.fetchCars = fetchCars
        self.fetchImage = fetchImage
        self.view = view
    }
}

extension GuidomiaPresenter: CarsPresenterProtocol {
    func sceneDidLoad() {
        setupView()
        requestCars()
    }
    
    func sceneWillAppear() {
    
    }
    
    func didChangeMake(make: String) {
        expandedItemIndex = 0
        selectedMake = make
        filteredCars = selectedMake == "Any Make" ? cars : cars.filter { $0.make.rawValue == selectedMake }
    }
    
    func didChangeModel(model: String) {
        expandedItemIndex = 0
        selectedModel = model
        filteredCars = selectedModel == "Any Model" ? cars : cars.filter { $0.model == selectedModel }
    }
    
    func didSelectCar(indexPath: Int) {
        guard expandedItemIndex != indexPath else {
            return
        }
        
        let deletedViewModel = formatViewModel(insert: false)
        let deleteIndex = deletedViewModel.sections[0].firstIndex { item in
            if let car = item as? CarTableViewCellViewModel {
                return car.index == expandedItemIndex
            } else {
                return false
            }
        } ?? 0
        view?.delete(deletedViewModel, indexPath: [.init(row: deleteIndex + 1, section: 0)])
        expandedItemIndex = indexPath
        
        let newViewModel = formatViewModel(insert: true)
        let insertIndex = newViewModel.sections[0].firstIndex { item in
            if let car = item as? CarTableViewCellViewModel {
                return car.index == indexPath
            } else {
                return false
            }
        } ?? 0
        view?.insert(newViewModel, indexPath: [.init(row: insertIndex + 1, section: 0)])
    }
}

private extension GuidomiaPresenter {
    func setupView() {
        view?.setup(formatViewModel())
    }
    
    func updateView() {
        view?.updateContent(formatViewModel())
    }
    
    func formatViewModel(insert: Bool = true) -> CarsViewModel {
        var items: [CarsTableViewItem] = []
        filteredCars.enumerated().forEach { element in
            if element.offset != 0 {
                items.append(CarTableViewSeparatorViewModel())
            }
            
            items.append(CarTableViewCellViewModel(image: fetchImage.execute(forModel: element.element),
                                                   title: .init(text: element.element.model,
                                                                appearance: .init(font: .systemFont(ofSize: 20, weight: .bold),
                                                                                  textColor: .customBlack)),
                                                   subtitle: .init(text: "Price: \(Int(element.element.customerPrice / 1000))k",
                                                                   appearance: .init(font: .systemFont(ofSize: 15, weight: .semibold),
                                                                                     textColor: .customBlack)),
                                                   rate: element.element.rating,
                                                   index: element.offset))
            
            if expandedItemIndex == element.offset && insert {
                items.append(ExpandedCarTableViewCellViewModel(prosTitle: .init(text: "Pros",
                                                                                appearance: .init(font: .systemFont(ofSize: 17, weight: .semibold),
                                                                                                  textColor: .customBlack)),
                                                               pros: element.element.prosList.compactMap { pro in
                                                                guard !pro.isEmpty else { return nil }
                                                                return .init(text: pro,
                                                                             appearance: .init(font: .systemFont(ofSize: 13,
                                                                                                                 weight: .semibold),
                                                                                               textColor: .black))
                                                               },
                                                               consTitle: .init(text: "Cons",
                                                                                appearance: .init(font: .systemFont(ofSize: 17,
                                                                                                                    weight: .semibold),
                                                                                                                textColor: .customBlack)),
                                                               cons: element.element.consList.compactMap { con in
                                                                guard !con.isEmpty else { return nil }
                                                                return .init(text: con,
                                                                             appearance: .init(font: .systemFont(ofSize: 13,
                                                                                                                 weight: .semibold),
                                                                                               textColor: .black))
                                                               }))
            }
            
            
        }
        
        let makeOptions: [String] = ["Any Make"] + cars.compactMap { $0.make.rawValue }
        let modelOptions: [String] = ["Any Model"] + cars.compactMap { $0.model }
        
        return .init(headerImage: .init(named: "tacoma"),
                     filter: .init(title: .init(text: " Filters ",
                                                appearance: .init(font: .systemFont(ofSize: 18, weight: .semibold), textColor: .white)),
                                   selectedMakeOption: selectedMake,
                                   anyMakeOptions: makeOptions,
                                   selectedModelOption: selectedModel,
                                   anyModelOptions: modelOptions),
                     sections: [items])
    }
    
    func requestCars() {
        fetchCars.fetch { [weak self] response in
            switch response {
                case .success(let cars):
                    self?.cars = cars
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
            }
        }
    }
}
