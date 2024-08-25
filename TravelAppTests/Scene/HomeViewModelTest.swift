//
//  HomeViewModelTest.swift
//  TravelAppTests
//
//  Created by Samet Korkmaz on 24.08.2024.
//

import XCTest
import CoreData
@testable import TravelApp


final class HomeViewModelTest: XCTestCase {

    private var viewModel: HomeViewModel!
    private var view: MockHome_VC!
    private var mockPersistentContainer: NSPersistentContainer!

    override func setUp(){
        super.setUp()
        view = .init()
        viewModel = .init(view: view)
        viewModel.view = view
        // Mock persistent container setup with in-memory store
        mockPersistentContainer = NSPersistentContainer(name: "CoreData")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // Use in-memory store for testing
        mockPersistentContainer.persistentStoreDescriptions = [description]

        mockPersistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                XCTFail("Failed to load persistent stores: \(error)")
            }
        }
    }
    
    override func tearDown(){
        viewModel = nil
        view = nil
        mockPersistentContainer = nil
        super.tearDown()
    }

    func test_viewDidLoad_InvokesMethods() {
        // GIVEN
        XCTAssertEqual(view.invokedConfigureHomeCount, 0)
        XCTAssertEqual(view.invokedConfigureHomeCollectionViewCount, 0)
        
        // WHEN
        viewModel.viewDidLoad()
        
        // THEN
        XCTAssertEqual(view.invokedConfigureHomeCount, 1)
        XCTAssertEqual(view.invokedConfigureHomeCollectionViewCount, 1)
    }
    
    func test_prepareHomeCollectionView_InvokesMethods() {
        // GIVEN
        XCTAssertEqual(view.invokedConfigureHomeCollectionViewCount, 0)
        
        // WHEN
        viewModel.prepareHomeCollectionView()
        
        // THEN
        XCTAssertEqual(view.invokedConfigureHomeCollectionViewCount, 1)
    }
    
    func test_isHotelBookmarked_WhenHotelIsBookmarked_ShouldReturnTrue() {
        // GIVEN
        let mockHotelId = "a11"

        // Create and insert a mock Hotel object into the context
        let context = mockPersistentContainer.viewContext
        let hotelEntity = NSEntityDescription.entity(forEntityName: "Hotel", in: context)!
        let hotelObject = NSManagedObject(entity: hotelEntity, insertInto: context)
        hotelObject.setValue(mockHotelId, forKey: "hotelId")
        
        do {
            try context.save() // Save to the in-memory persistent store
        } catch {
            XCTFail("Failed to save mock hotel to Core Data: \(error)")
        }
        
        // WHEN
        viewModel = HomeViewModel(view: view)
        let result = viewModel.isHotelBookmarked(hotelId: mockHotelId)
        
        // THEN
        XCTAssertTrue(result)
    }
    
    func test_isHotelBookmarked_WhenHotelIsNotBookmarked_ShouldReturnFalse() {
        // GIVEN
        let mockHotelId = "noData"
        
        // WHEN
        let result = viewModel.isHotelBookmarked(hotelId: mockHotelId)
        
        // THEN
        XCTAssertFalse(result)
    }

    
    func test_getHotel_ReturnsCorrectHotel() {
        // GIVEN
        let mockIndexPath = IndexPath(row: 0, section: 0)
        
        // WHEN
        let hotel = viewModel.getHotel(at: mockIndexPath)
        
        // THEN
        XCTAssertNotNil(hotel)
    }
    
    func test_numberOfHotels_ReturnsCorrectCount() {
        // WHEN
        let count = viewModel.numberOfHotels()
        
        // THEN
        XCTAssertEqual(count, viewModel.hotels.count)
    }

}
