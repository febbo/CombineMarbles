# CombineMarbles 🔵

An educational iOS app for visualizing Combine operators through interactive marble diagrams, built with SwiftUI.

## 📱 Overview

CombineMarbles transforms the Combine learning process into a visual and interactive experience. Each operator is represented through animated marble diagrams that show how data flows through streams and gets transformed.

## 🏗️ Architecture

The app follows the **MVVM** pattern with clear separation of responsibilities:

### 📁 Module Structure

```
CombineMarbles/
├── 🎯 Core/
│   ├── MarbleEvent.swift          # Base model for stream events
│   ├── StreamEvent.swift          # Advanced event representation
│   └── CombineOperator.swift      # Operator definitions + library
├── 🎨 UI/
│   ├── Views/
│   │   ├── ContentView.swift      # Operators list
│   │   ├── OperatorDetailView.swift # Operator detail
│   │   ├── MarbleStreamView.swift  # Stream timeline
│   │   └── MarbleView.swift       # Single marble
│   └── ViewModels/
│       ├── OperatorsViewModel.swift     # Operators list
│       ├── OperatorDetailViewModel.swift # Detail logic
│       └── MarbleStreamViewModel.swift  # Stream timeline
├── 🔧 Utilities/
│   └── InputGenerationStrategy.swift    # Data input strategies
└── 📱 App/
    └── CombineMarblesApp.swift
```

## ✨ Current Features

### 🔀 Implemented Operators

#### Transforming
- ✅ `map` - Transforms elements with a closure
- ✅ `compactMap` - Transforms and filters nil values

#### Filtering  
- ✅ `filter` - Filters elements with predicate
- ✅ `filter(isMultipleOf:)` - Specialized filter
- ✅ `removeDuplicates` - Removes consecutive duplicates
- ✅ `prefix(_:)` - First N elements
- ✅ `drop(while:)` - Ignores while condition is true
- ✅ `dropFirst(_:)` - Ignores first N elements

#### Combining
- ✅ `merge` - Combines interleaved streams
- ✅ `combineLatest` - Combines latest values
- ✅ `zip` - Combines in synchronized pairs

#### Error Handling
- ✅ `catch` - Handles errors with substitute publisher
- ✅ `retry` - Retries failed subscriptions
- ✅ `assertNoFailure` - Ensures no errors occur
## 🛠️ Development Setup

### Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Installation
```bash
git clone https://github.com/yourusername/CombineMarbles.git
cd CombineMarbles
open CombineMarbles.xcodeproj
```

### Adding New Operators

1. **Define the operator** in `OperatorLibrary`:
```swift
private func createYourOperator() -> OperatorDefinition {
    return OperatorDefinition(
        name: "yourOperator",
        category: .transforming,
        description: "Your operator description",
        codeExample: "code example",
        inputStrategies: [.random],
        apply: { publishers in
            // Implementation
        }
    )
}
```
## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-operator`)
3. Commit changes (`git commit -am 'Add amazing operator'`)
4. Push branch (`git push origin feature/amazing-operator`)
5. Create Pull Request
## Configuration

1. Clone the repository
   ```bash
   git clone https://github.com/tuousername/CombineMarbles.git
   ```

2. Configure development settings
   ```bash
   cd CombineMarbles
   cp DeveloperSettings.xcconfig.template DeveloperSettings.xcconfig
   ```

3. Edit `DeveloperSettings.xcconfig` and enter your DEVELOPMENT_TEAM and your DEVELOPER_BUNDLE_PREFIX (com.example)

4. Open the project in Xcode
   ```bash
   open CombineMarbles.xcodeproj
   ```

5. Select your development team in the signing settings