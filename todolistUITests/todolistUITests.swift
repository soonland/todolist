import XCTest

final class todolistUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // Helper function to create a group
    func createGroup(app: XCUIApplication, name: String, description: String) throws {
        let addButton = app.buttons["Ajouter"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        app.buttons["Nouveau groupe"].tap()
        sleep(1) // Add small delay for keyboard
        
        let groupNameField = app.textFields["Nom du groupe"]
        XCTAssertTrue(groupNameField.exists)
        groupNameField.tap()
        groupNameField.typeText(name)
        
        let groupDescField = app.textFields["Description"]
        XCTAssertTrue(groupDescField.exists)
        groupDescField.tap()
        groupDescField.typeText(description)
        
        app.buttons["Créer"].tap()
        
        // Verify group was created
        let groupText = app.staticTexts[name]
        XCTAssertTrue(groupText.exists)
    }
    
    // Helper function to create a task
    func createTask(app: XCUIApplication, title: String, details: String, priority: String? = nil, groupName: String? = nil) throws {
        let addButton = app.buttons["Ajouter"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        if (groupName == nil) {
            app.buttons["Nouvelle tâche"].tap()
            sleep(1) // Add small delay for keyboard
        }
        
        let titleTextField = app.textFields["Titre"]
        XCTAssertTrue(titleTextField.exists)
        titleTextField.tap()
        titleTextField.typeText(title)
        
        let detailsTextField = app.textFields["Détails"]
        XCTAssertTrue(detailsTextField.exists)
        detailsTextField.tap()
        detailsTextField.typeText(details)
        
        if let priority = priority {
            let picker = app.buttons["priorityPicker"]
            XCTAssertTrue(picker.exists)
            picker.tap()
            app.buttons[priority].tap()
        }
        
        let addTaskButton = app.navigationBars.buttons["Ajouter tâche"]
        XCTAssertTrue(addTaskButton.exists)
        addTaskButton.tap()
        
        // Verify task was created
        // let taskText = app.staticTexts[title]
        // XCTAssertTrue(taskText.exists)
    }

    @MainActor
    func testAddTask() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Select "All Tasks" in sidebar
        app.buttons["Toutes les tâches"].tap()
        
        // Create a new task
        try createTask(
            app: app,
            title: "Nouvelle tâche",
            details: "Détails de la tâche"
        )
    }
    
    @MainActor
    func testChangePriority() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Create a group first
        try createGroup(
            app: app,
            name: "Groupe Test",
            description: "Description test"
        )

        // Select the created group
        let groupButton = app.buttons["Groupe Test"]
        XCTAssertTrue(groupButton.exists)
        groupButton.tap()
        sleep(1) // Add small delay for animation

        // Create a task with high priority
        try createTask(
            app: app,
            title: "Tâche prioritaire",
            details: "Détails de la tâche",
            priority: "Haute",
            groupName: "Groupe Test"
        )
        
        // Additional verification for priority indicator
        // let priorityIndicator = app.images["priorityHigh"]
        // XCTAssertTrue(priorityIndicator.exists)
    }
    
    @MainActor
    func testAddGroup() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Create a new group
        try createGroup(
            app: app,
            name: "Nouveau groupe",
            description: "Description du groupe"
        )
    }
    
    @MainActor
    func testAddTaskToGroup() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Create a group first
        try createGroup(
            app: app,
            name: "Groupe Test",
            description: "Description test"
        )
        
        // Select the created group
        let groupButton = app.buttons["Groupe Test"]
        XCTAssertTrue(groupButton.exists)
        groupButton.tap()
        sleep(1) // Add small delay for animation
        
        // Add task to the group
        try createTask(
            app: app,
            title: "Tâche dans groupe",
            details: "Détails de la tâche",
            groupName: "Groupe Test"
        )
    }
}
