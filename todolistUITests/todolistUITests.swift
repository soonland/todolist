//
//  todolistUITests.swift
//  todolistUITests
//
//  Created by Jonathan Langlois on 2025-02-03.
//

import XCTest

final class todolistUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAddTask() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test adding a task
        let titleTextField = app.textFields["Titre de la tâche"]
        XCTAssertTrue(titleTextField.exists)
        titleTextField.tap()
        titleTextField.typeText("Nouvelle tâche")
        
        let detailsTextField = app.textFields["Détails de la tâche"]
        XCTAssertTrue(detailsTextField.exists)
        detailsTextField.tap()
        detailsTextField.typeText("Détails de la tâche")
        
        let addButton = app.buttons["Ajouter Tâche"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        // Verify task appears in the list
        let taskText = app.staticTexts["Nouvelle tâche"]
        XCTAssertTrue(taskText.exists)
    }
    
    @MainActor
    func testChangePriority() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Select high priority
        let highPriorityButton = app.buttons["Haute"]
        XCTAssertTrue(highPriorityButton.exists)
        highPriorityButton.tap()
        
        // Add task
        app.textFields["Titre de la tâche"].tap()
        app.textFields["Titre de la tâche"].typeText("Tâche prioritaire")
        app.buttons["Ajouter Tâche"].tap()
        
        // Verify task exists
        let taskText = app.staticTexts["Tâche prioritaire"]
        XCTAssertTrue(taskText.exists)
    }
}
