//
//  HomeViewModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import Foundation

protocol HomeViewModelInterface {
    var view: HomeViewInterface? { get set }
    
    func viewDidLoad()
    func prepareHomeCollectionView()
}

final class HomeViewModel {
    weak var view: HomeViewInterface?
    
    init(view: HomeViewInterface) {
        self.view = view
    }
}

extension HomeViewModel: HomeViewModelInterface{
    
    func viewDidLoad() {
        view?.configureHome()
        prepareHomeCollectionView()
    }
    
    func prepareHomeCollectionView() {
        view?.configureHomeCollectionView()
    }
}
