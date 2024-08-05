//
//  DetailViewModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import Foundation

protocol DetailViewModelInterface{
    var view: DetailViewInterface? { get set }
    
    func viewDidLoad()
    func detailBookmarkButton()
}

final class DetailViewModel{
    var view: DetailViewInterface?
    
    init(view: DetailViewInterface) {
        self.view = view
    }
}

extension DetailViewModel: DetailViewModelInterface{

    func viewDidLoad() {
        view?.configureDetailPage()
    }
    
    func detailBookmarkButton() {
        view?.configureDetailBookmarkButtonText()
    }

}
