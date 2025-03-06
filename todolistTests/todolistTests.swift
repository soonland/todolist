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
    
    // MARK: - Group Tests
    
    func testAddGroup() {
        // Given
        let name = "Test Group"
        let description = "Test Description"
        
        // When
        viewModel.addGroup(name: name, description: description)
        
        // Then
        XCTAssertEqual(viewModel.groups.count, 1)
        XCTAssertEqual(viewModel.groups[0].name, name)
        XCTAssertEqual(viewModel.groups[0].description, description)
    }
    
    func testAddTaskWithGroup() {
        // Given
        viewModel.addGroup(name: "Test Group", description: "Description")
        let groupId = viewModel.groups[0].id
        
        // When
        viewModel.addTask(title: "Task in group", details: "Details", priority: .medium, groupId: groupId)
        
        // Then
        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks[0].groupId, groupId)
    }
    
    func testTasksForGroup() {
        // Given
        viewModel.addGroup(name: "Group 1", description: "Description 1")
        let group1Id = viewModel.groups[0].id
        viewModel.addGroup(name: "Group 2", description: "Description 2")
        let group2Id = viewModel.groups[1].id
        
        viewModel.addTask(title: "Task 1", details: "Details", priority: .medium, groupId: group1Id)
        viewModel.addTask(title: "Task 2", details: "Details", priority: .medium, groupId: group2Id)
        viewModel.addTask(title: "Task 3", details: "Details", priority: .medium, groupId: group1Id)
        
        // When
        let tasksInGroup1 = viewModel.tasksForGroup(group1Id)
        
        // Then
        XCTAssertEqual(tasksInGroup1.count, 2)
        XCTAssertTrue(tasksInGroup1.allSatisfy { $0.groupId == group1Id })
    }
    
    func testTasksWithNoGroup() {
        // Given
        viewModel.addTask(title: "Task without group", details: "Details", priority: .medium)
        viewModel.addGroup(name: "Group", description: "Description")
        let groupId = viewModel.groups[0].id
        viewModel.addTask(title: "Task with group", details: "Details", priority: .medium, groupId: groupId)
        
        // When
        let tasksWithoutGroup = viewModel.tasksForGroup(nil)
        
        // Then
        XCTAssertEqual(tasksWithoutGroup.count, 1)
        XCTAssertNil(tasksWithoutGroup[0].groupId)
    }
}
