# Brick Breaker

## Overview
A fast-paced Flutter brick breaker game that showcases a custom physics engine, real-time collision detection, and smooth touch controls. It is built to demonstrate end-to-end Flutter app craftsmanship—from rendering to input handling—while keeping the codebase approachable for learning.

## 1. Problem & Solution
- **Problem**: Arcade-style brick breaker games need tight, deterministic physics, efficient rendering, and responsive input to feel fair and fun on mobile devices.
- **Solution**: This project implements a custom physics loop with precise collision handling and a lightweight rendering pipeline, resulting in consistent paddle/ball interactions, minimal input latency, and clear visual feedback.

## 2. Tech Stack
- **Framework**: Flutter (Dart)
- **Rendering**: `CustomPainter` + Canvas APIs for real-time drawing
- **State & Game Loop**: Manual ticker/animation controller driving a fixed-step update loop
- **Input**: Gesture detection for touch/drag
- **Tooling**: Flutter SDK, hot reload/hot restart for rapid iteration

## 3. Architecture
- **Game Loop Core**: A fixed-timestep update cycle decoupled from rendering to keep physics deterministic.
- **Physics & Collision Module**: Custom collision detection/resolution between ball, paddle, and bricks; separates detection from response for clarity.
- **Rendering Layer**: Stateless drawing via `CustomPainter`, reading from immutable-ish frame state to avoid jank.
- **Input Layer**: Gesture handlers translate touch/drag into paddle position updates; throttled to maintain stability with the game loop.
- **State Flow**: Single source of truth for game state (positions, velocities, scores, lives) updated in the loop and read by the painter.

## 4. Challenges Faced
- **Collision Precision**: Handling corner/edge cases (literally) without tunneling or jitter when ball speed varies.
- **Performance**: Keeping frame times low with custom painting while avoiding unnecessary object allocations in the hot path.
- **Determinism**: Balancing a fixed timestep for physics with Flutter’s rendering cadence to avoid desync and visual stutter.
- **Input Responsiveness**: Ensuring paddle movement feels immediate on touch devices despite the game loop’s fixed update cadence.
- **Iteration Speed**: Managing hot reload cycles and debugging physics visually to quickly validate changes.

## App Demo


https://github.com/user-attachments/assets/fa050f8d-8412-4208-81c2-71442d5d9afc

