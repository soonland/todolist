//
//  todolistTests.swift
//  todolistTests
//
//  Created by Jonathan Langlois on 2025-02-03.
//

import XCTest
@testable import todolist

final class todolistTests: XCTestCase {
    var viewModel: TaskViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = TaskViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testAddTask() {
        // Given
        let title = "Test Task"
        let details = "Test Details"
        let priority = TaskPriority.high
        
        // When
        viewModel.addTask(title: title, details: details, priority: priority)
        
        // Then
        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks[0].title, title)
        XCTAssertEqual(viewModel.tasks[0].details, details)
        XCTAssertEqual(viewModel.tasks[0].priority, priority)
        XCTAssertEqual(viewModel.tasks[0].status, .todo)
    }
    
    func testUpdateTaskStatus() {
        // Given
        viewModel.addTask(title: "Test", details: "Details", priority: .medium)
        let task = viewModel.tasks[0]
        let newStatus = TaskStatus.inProgress
        
        // When
        viewModel.updateTaskStatus(id: task.id, newStatus: newStatus)
        
        // Then
        XCTAssertEqual(viewModel.tasks[0].status, newStatus)
    }
    
    func testUpdateTaskStatusWithInvalidId() {
        // Given
        viewModel.addTask(title: "Test", details: "Details", priority: .medium)
        let invalidId = UUID()
        
        // When
        viewModel.updateTaskStatus(id: invalidId, newStatus: .done)
        
        // Then
        XCTAssertEqual(viewModel.tasks[0].status, .todo)
    }
}
