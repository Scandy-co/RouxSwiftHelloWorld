//
//  RouxSwiftHelloWorldUITests.swift
//  RouxSwiftHelloWorldUITests
//
//  Created by H. Cole Wiley on 6/4/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import XCTest


extension XCUIElement {
  func labelContains(text: String) -> Bool {
    let predicate = NSPredicate(format: "label CONTAINS %@", text)
    return staticTexts.matching(predicate).firstMatch.exists
  }
}

class RouxSwiftHelloWorldUITests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  
  func testExample() throws {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launch()
    
    // Allow camera access
    addUIInterruptionMonitor(withDescription: "System Dialog") {
      (alert) -> Bool in
      alert.buttons["Allow"].tap()
      return true
    }
    
    // Let Roux finish initializing, then start scanning
    sleep(5)
    XCTAssert(app.buttons["Start Scanning"].isEnabled)
    app.buttons["Start Scanning"].tap()
    
    // Scan for a bit then stop
    sleep(2)
    XCTAssert(app.buttons["Stop Scanning"].isEnabled)
    app.buttons["Stop Scanning"].tap()
    
    // Let the stop go through, then save
    sleep(2)
    XCTAssert(app.buttons["Save Mesh"].isEnabled)
    XCTAssert(app.buttons["Start Preview"].isEnabled)
    app.buttons["Save Mesh"].tap()
    
    // Check that we got a MeshSaved dialog
    addUIInterruptionMonitor(withDescription: "System Dialog") {
      (alert) -> Bool in
       let notifPermission = "MeshSaved"
    
       if alert.labelContains(text: notifPermission) {
         alert.buttons["Dismiss"].tap()
       } else {
        XCTFail("Mesh did not save")
      }
      return true
    }
  }
}
