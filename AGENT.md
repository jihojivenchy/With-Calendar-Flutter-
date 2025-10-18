# Codex CLI rules

You are a senior Dart programmer with experience in the Flutter framework and a preference for clean programming and design patterns.

Generate code, corrections, and refactorings that comply with the basic principles and nomenclature.

## Dart General Guidelines
### Basic Principles
- Always declare the type of each variable and function (parameters and return value).
  - Avoid using any.
  - Create necessary types.
- Don't leave blank lines within a function.

### Nomenclature
- Use PascalCase for classes.
- Use camelCase for variables, functions, and methods.
- Use underscores_case for file and directory names.
- Use UPPERCASE for environment variables.
  - Avoid magic numbers and define constants.
- Start each function with a verb.
- Use verbs for boolean variables. Example: isLoading, hasError, canDelete, etc.
- Use complete words instead of abbreviations and correct spelling.
  - Except for standard abbreviations like API, URL, etc.
  - Except for well-known abbreviations:
    - i, j for loops
    - err for errors
    - ctx for contexts
    - req, res, next for middleware function parameters

### Functions
- In this context, what is understood as a function will also apply to a method.
- Write short functions with a single purpose. Less than 20 instructions.
- Name functions with a verb and something else.
  - If it returns a boolean, use isX or hasX, canX, etc.
  - If it doesn't return anything, use executeX or saveX, etc.
- Avoid nesting blocks by:
  - Early checks and returns.
  - Extraction to utility functions.
- Use higher-order functions (map, filter, reduce, etc.) to avoid function nesting.
  - Use arrow functions for simple functions (less than 3 instructions).
  - Use named functions for non-simple functions.
- Use default parameter values instead of checking for null or undefined.
- Reduce function parameters using RO-RO
  - Use an object to pass multiple parameters.
  - Use an object to return results.
  - Declare necessary types for input arguments and output.
- Use a single level of abstraction.

### Data
- Don't abuse primitive types and encapsulate data in composite types.
- Avoid data validations in functions and use classes with internal validation.
- Prefer immutability for data.
  - Use readonly for data that doesn't change.
  - Use as const for literals that don't change.

### Classes
- Follow SOLID principles.
- Prefer composition over inheritance.
- Declare interfaces to define contracts.
- Write small classes with a single purpose.
  - Less than 200 instructions.
  - Less than 10 public methods.
  - Less than 10 properties.

### Exceptions
- Use exceptions to handle errors you don't expect.
- If you catch an exception, it should be to:
  - Fix an expected problem.
  - Add context.
  - Otherwise, use a global handler.

## Specific to Flutter
### Architecture – Modified Clean Architecture for Flutter
This structure is fundamentally based on Clean Architecture, but customized for service-oriented needs. The application is divided into three main layers:

1. 📦 Data Layer
Handles all concerns related to external data sources such as APIs or local databases.

🧩 Responsibilities:
Network Services:
Implements single-responsibility classes for performing API requests.
Does not contain business logic.

DTO (Data Transfer Objects):
Defines data schemas received from or sent to APIs.
Handles serialization/deserialization.
Can include basic transformation methods to convert to domain entities.

2. 🧠 Domain Layer
Contains the core logic and models of the application. It is completely independent and has no dependencies on external libraries or Flutter itself.

🧩 Responsibilities:
Entities:
Core app objects (e.g., User, Post, Product).
Pure Dart objects with no dependencies.

Services (customized definition):
Responsible for business logic and orchestration.
Combines the responsibilities typically associated with both UseCases and Repositories.
Interfaces directly with the Data layer (e.g., Network Services).
Can be invoked directly by the Presentation layer for data flow or actions.

3. 🖼️ Presentation Layer
Responsible for the UI and interaction logic. Relies on the Domain layer to retrieve and display data.

🧩 Responsibilities:
Design System:
Common UI components (e.g., buttons, inputs, typography)
Foundational styles such as colors, spacing, and themes

Screens:
UI representation of features (stateless/stateful widgets, views)

Router:
Manages navigation and screen flow
Defines all routes and transitions between screens

📌 Key Architectural Features:
The Domain layer has no dependency on Flutter or any external package.
The Data layer knows nothing about the UI, and only provides raw data or domain-convertible DTOs.
The Presentation layer interacts with the Domain layer only via clean interfaces or services.

### Router
- Use GoRoute, AutoRoute to manage routes
  - Use extras to pass data between pages

### Basic Principles
- Use extensions to manage reusable code
- Use ThemeData to manage themes
- Use AppLocalizations to manage translations
- Use constants to manage constants values
- When a widget tree becomes too deep, it can lead to longer build times and increased memory usage. Flutter needs to traverse the entire tree to render the UI, so a flatter structure improves efficiency
- A flatter widget structure makes it easier to understand and modify the code. Reusable components also facilitate better code organization
- Avoid Nesting Widgets Deeply in Flutter. Deeply nested widgets can negatively impact the readability, maintainability, and performance of your Flutter app. Aim to break down complex widget trees into smaller, reusable components. This not only makes your code cleaner but also enhances the performance by reducing the build complexity
- Deeply nested widgets can make state management more challenging. By keeping the tree shallow, it becomes easier to manage state and pass data between widgets
- Break down large widgets into smaller, focused widgets
- Utilize const constructors wherever possible to reduce rebuilds
    
