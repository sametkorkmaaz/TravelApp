//
//  TravelAppUITests.swift
//  TravelAppUITests
//
//  Created by Samet Korkmaz on 1.09.2024.
//

import XCTest

final class TravelAppUITests: XCTestCase {

    override func setUpWithError() throws {

        continueAfterFailure = false

        
    }

    func test_homeCollectionView_elementsTap_to_detailPage() throws {
        let app = XCUIApplication()
        app.launch()
        
        let collectionView = app.collectionViews
        XCTAssertTrue(collectionView.element.exists)
        
        XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.tap()
        
        let detailLabel = app.staticTexts["Hotel"]
        XCTAssertTrue(detailLabel.exists)
        
    }
    
    func test_homeScreen_press_hotelButton_goTo_ListView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Hotel button var  mı?
        let hotelButton = app.buttons["house.lodge.fill"]
        XCTAssertTrue(hotelButton.exists)
        
        hotelButton.tap()
        
        // Hotel listView ekranına gittiğini anlamak için
        let listViewTitle = app.staticTexts["Hotel"]
        XCTAssertTrue(listViewTitle.exists)
        
    }
    
    func test_homeScreen_press_flightButton_goTo_ListView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Hotel button var  mı?
        let flightButton = app.buttons["airplane.departure"]
        XCTAssertTrue(flightButton.exists)
        
        flightButton.tap()
        
        // Hotel listView ekranına gittiğini anlamak için
        let listViewTitle = app.staticTexts["Flights"]
        XCTAssertTrue(listViewTitle.exists)
        
    }
    
    func test_homeCollectionView_scrollLeft() throws{
        let app = XCUIApplication()
        app.launch()
        
        XCUIApplication().windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .collectionView).element.swipeLeft()
                
    }

    func testLaunchPerformance() throws {
        print("aAAAAAAAAAAAAAAAAAAAAÂEQ")
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
