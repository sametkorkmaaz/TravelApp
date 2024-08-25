//
//  MockHome_VC.swift
//  TravelAppTests
//
//  Created by Samet Korkmaz on 24.08.2024.
//

@testable import TravelApp

final class MockHome_VC: HomeViewInterface{

    var invokedConfigureHome = false
    var invokedConfigureHomeCount = 0

    func configureHome() {
        invokedConfigureHome = true
        invokedConfigureHomeCount += 1
    }

    var invokedConfigureHomeCollectionView = false
    var invokedConfigureHomeCollectionViewCount = 0

    func configureHomeCollectionView() {
        invokedConfigureHomeCollectionView = true
        invokedConfigureHomeCollectionViewCount += 1
    }

    var invokedReloadData = false
    var invokedReloadDataCount = 0

    func reloadData() {
        invokedReloadData = true
        invokedReloadDataCount += 1
    }
}
