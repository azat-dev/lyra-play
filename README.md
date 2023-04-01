<h1 align="center">
  <br>
  <img src="https://raw.githubusercontent.com/azat-dev/lyra-play/main/LyraPlay/SupportFiles/Assets.xcassets/AppIcon.appiconset/180.png" alt="LyraPlay" width="150"></a>
  <br>
  LyraPlay
  <br>
</h1>

<p align="center">
  <a href="#about">About</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#license">License</a>
</p>

## About
The "LyraPlay" is the perfect tool for those who love to learn on the go. With this app, you can easily learn new information, concepts, or skills simply by listening to your favorite music, audiobooks, or podcasts.

With the "LyraPlay", you can turn your idle time into valuable learning opportunities. Start listening today and expand your knowledge, all while enjoying your favorite music, audiobooks, or podcasts.

## Architecture

The architecture of this app is based on the "Clean Architecture" principle, which ensures that each component of the app is independent and easily testable. The app consists of four main parts:

- **Domain**: This is where the core business logic of the app is implemented. It contains entities, use cases, and repositories that define the app's functionality and behavior.

- **Data**: This component deals with the app's data sources and storage. In this app, CoreData is used to store data. The data layer interacts with the domain layer through repositories, ensuring that the business logic remains decoupled from the data layer.

- **Presentation**: This component is responsible for displaying data to the user and handling user interactions. In this app, the presentation layer uses the Model-View-ViewModel (MVVM) architecture pattern, along with Combine for binding. The presentation layer is built with UIKit, but it can be easily replaced with SwiftUI.

- **Application**: The application layer contains the flow models that define the logic between screens. This ensures that the presentation layer remains agnostic to the navigation and routing of the app.

Overall, the clean architecture of this app ensures that each component is well-defined and testable, leading to a more maintainable and scalable codebase.

## License

Licensed under [GNU GPL v. 3.0](https://opensource.org/licenses/GPL-3.0). See `LICENSE` for details.
