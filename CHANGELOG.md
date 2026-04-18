# Changelog

All notable changes to this project are documented here.

---

## 1.7.0 — Smart Notifications & Architecture

### Added
- Smart local notifications for timed tasks:
  - Triggered 5 minutes before scheduled time
  - Minimal, non-intrusive reminder format

### Added
- Notification service abstraction layer:
  - Introduced `NotificationService` interface
  - iOS-specific implementation using local notifications

### Improved
- Task lifecycle integration:
  - Notifications scheduled on create/update
  - Notifications cancelled on delete/complete

### Architecture
- Applied SOLID principles to notification system
- Decoupled platform-specific logic from core business logic
- Prepared for future Android support without breaking existing code

### UX Impact
- Transitions app from passive planner → active assistant
- Maintains simplicity with zero user configuration

---

## 1.6.3 — Current Time UX Improvement

### Improved
- Refactored current time display:
  - Removed minute display from left-side hour labels
  - Introduced a floating current time label attached to the timeline indicator

- Current time label now:
  - Moves dynamically with the timeline as time progresses
  - Updates every minute
  - Stays visually aligned with the indicator dot and line

### UX Impact
- Improved clarity by separating static hour labels from dynamic time
- Stronger visual connection between current time and timeline
- Reduced clutter and enhanced real-time feel of the interface

---

## 1.6.2 — Bug Fixes

### Fixed
- Current time formatting bug (00:xx → 12:xx AM)
- Ensured consistent 12-hour format

---

## 1.6.1 — Spacing & Layout

### Improved
- Better spacing balance
- Text overflow handling (2-line limit + ellipsis)

---

## 1.6.0 — Usability Upgrade

### Added
- Increased text sizes for better readability
- Larger touch targets

---

## 1.5.2 — Visual Polish

### Improved
- Task card styling (padding, borders, elevation)
- FAB visual refinement
- Typography hierarchy

---

## 1.5.1 — UI Enrichment

### Improved
- Background tones (light/dark)
- Alternating hour shading
- Improved visual hierarchy

---

## 1.5.0 — Past Tasks System

### Added
- Horizontal past tasks strip
- Auto-move completed/expired tasks

---

## 1.4.1 — Layout Fixes

### Fixed
- FAB overlapping last timeline item
  - Added bottom padding to scroll content

---

## 1.4.0 — Live Timeline Enhancements

### Added
- Real-time current time indicator (line + dot)
- Auto-scroll to current time
- Past vs future visual differentiation

---

## 1.3.1 — UX Improvements

### Improved
- Bottom sheet input flow (auto focus, simplified UI)
- Interaction consistency

---

## 1.3.0 — Task Intelligence

### Added
- Next task prioritization logic
- Automatic task highlighting

---

## 1.2.0 — Timeline System

### Added
- 24-hour vertical timeline
- Timed task positioning
- Untimed “Next” section

---

## 1.1.0 — Core Task Features

### Added
- Task creation (title + optional time)
- Swipe to complete tasks
- Automatic task sorting

---

## 1.0.0 — Initial Product Foundation

### Added
- Core Flutter project setup
- Feature-first modular architecture
- Riverpod state management
- Hive local persistence
- Task data model

---

## Current Status

- Core product stabilized
- UX refinement ongoing
- Preparing for release-quality polish