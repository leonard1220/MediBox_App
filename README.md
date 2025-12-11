# MediBox - Smart Pill Organizer Prototype

MediBox is a modern iOS companion app prototype for a smart pill dispenser. It is designed to help users manage their medication schedule, track their adherence, and monitor inventory levels with a futuristic, neon-styled interface.

## Features

### 🏠 Today's Dashboard
- **Real-time Clock**: Large, easy-to-read digital clock.
- **Next Dose Indicator**: Shows the next scheduled medication, time remaining, and specific instructions (e.g., "Before Meal").
- **Dose Simulation**: Interactive neon progress bar. Tap to simulate taking a pill.
- **Low Stock Alerts**: Visual warning banners when compartment inventory drops below the threshold.
- **Reset Simulation**: A restart button to reset the daily progress for testing purposes.

### 💊 My Medicine Box
- **Compartment Management**: Configure up to 5 smart compartments.
- **Inventory Tracking**: Track current stock and set low-stock alert thresholds.
- **Medication Details**: Assign names, dosages, and custom interaction instructions (e.g., "After Meal", "With Food").
- **Schedule Manager**: Set multiple daily reminders for each compartment.

### 📊 Statistics
- **Weekly Report**: A visualized 7-day retrospective of medication adherence.
- **Status Indicators**:
    - 🔵 **Perfect**: All doses taken.
    - 🟠 **Partial**: Some doses missed.
    - 🔴 **Missed**: No doses taken.
    - *(Note: Data is currently simulated for prototype demonstration)*

### ⚙️ Settings
- Placeholder for future configuration options.

## Technical Overview

- **Platform**: iOS 17.0+
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **Architecture**: MVVM-based patterns
- **Design System**: Custom "Neon Dark Mode" theme (Black background, Cyan/Red/Yellow neon accents).

## Getting Started

1.  Clone the repository.
2.  Open the folder in **Xcode 15+**.
3.  Build and run on an **iPhone Simulator** or **Device**.

> **Note**: This is a prototype application. Some data (like the Weekly Report) is simulated to demonstrate UI states without requiring a week of real-world usage.

## License

Private Prototype.
