# To-Do List App

A simple to-do list app built with SwiftUI. This app allows users to create, edit, delete, and manage tasks. The tasks are stored locally using `UserDefaults` to persist data between app sessions. The app includes basic features such as task completion and swipe actions for managing tasks.

## Features

- **Add new tasks** by tapping the "+" button in the navigation bar.
- **Edit existing tasks** by tapping on the task in the list.
- **Mark tasks as complete** with swipe left action.
- **Reopen completed tasks** by swiping left again.
- **Delete tasks** by swiping right.
- **Rearrange tasks** by using drag and drop.
- Data is saved locally using `UserDefaults`.

## Technologies Used

- SwiftUI
- `UserDefaults` for local data storage
- Swift 5.7 (or the latest version)

## Installation

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/yourusername/todo-list-app.git
   ```

2. Open the project in Xcode:

   ```bash
   open todo-list-app.xcodeproj
   ```

3. Build and run the app in the Xcode simulator or on your device.

## Usage

1. When the app is launched, you will see a list of tasks.
2. Tap the "+" button at the top-right to add a new task.
3. To edit a task, simply tap on it in the list.
4. Swipe left to mark a task as complete, or reopen a completed task.
5. Swipe right to delete a task.
6. Rearrange the tasks using drag and drop.

## Contributing

1. Fork the repository.
2. Create your branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -am 'Add feature'`).
4. Push to the branch (`git push origin feature-name`).
5. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
