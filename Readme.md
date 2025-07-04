# Railway HMI System

A professional, safety-critical Railway Human-Machine Interface (HMI) system built with Qt/QML and PostgreSQL for real-time railway signaling and train control operations.

---

## Features

### Core Functionality
- Real-time Railway Signaling Control – Manage signal states with database-driven updates
- Train Position Tracking – Monitor and control train movements across track sections
- Safety-Critical Architecture – UI updates only after database confirmation (no optimistic updates)
- Offline-First Design – Local PostgreSQL database for reliable operation without internet dependency
- Multi-Operator Support – Concurrent access with real-time state synchronization

### Technical Features
- High-Performance Polling – Configurable 1ms to 1000ms database polling for real-time feel
- Professional HMI Interface – Industrial-grade color scheme and layout
- Portable Deployment – Self-contained executable with all dependencies included
- Comprehensive Error Handling – Railway safety standards compliance
- Memory-Safe Implementation – Modern C++17 with smart pointers and RAII patterns

### Performance Modes
- **Teleportation Mode (1ms)** – Ultra-responsive for testing
- **Rocket Mode (10-50ms)** – High-performance operation
- **Supercar Mode (100ms)** – Balanced performance
- **Standard Mode (200ms)** – Production-ready efficiency

---

## Screenshots

![Main Control Panel](https://github.com/NeonAurora/QtHello_World/blob/main/resources/QtHelloWorld.png)
*Main control panel showing real-time signal states.*

![Train Position Tracking](https://github.com/NeonAurora/QtHello_World/blob/main/resources/QtHelloWorld2.png)
*Train position tracking interface with live updates.*

## Technology Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Frontend | [Qt Quick/QML](https://www.qt.io/) | 6.9+ | Modern declarative UI |
| Backend | [C++](https://isocpp.org/) | C++17 | High-performance logic |
| Database | [PostgreSQL](https://postgresql.org/) | 17+ | Reliable data storage |
| Build System | [CMake](https://cmake.org/) | 3.20+ | Cross-platform compilation |
| Compiler | MinGW/GCC | 13.1+ | Native compilation |

---

## System Requirements

### Development Environment
- Operating System: Windows 10/11, Linux, or macOS
- Qt Framework: Qt 6.9.1 or later with Qt Creator
- Database: PostgreSQL 17+ with pgAdmin 4
- Compiler: MinGW 13.1.0+ or equivalent GCC/Clang
- Memory: 4GB RAM minimum (8GB recommended)
- Storage: 2GB free space for development tools

### Runtime Requirements
- Operating System: Windows 10/11 (primary), Linux support available
- Memory: 512MB RAM minimum
- Storage: 100MB for application and database
- Network: None required (offline-capable)

---

## Quick Start

1. **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/railway-hmi.git
    cd railway-hmi
    ```

2. **Install Dependencies**

    **Windows:**
    ```bash
    # Install Qt 6.9.1 with Qt Creator from https://qt.io/
    # Install PostgreSQL 17 from https://postgresql.org/
    ```

    **Linux (Ubuntu/Debian):**
    ```bash
    sudo apt update
    sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev
    sudo apt install postgresql-17 postgresql-client-17
    sudo apt install cmake build-essential
    ```

3. **Setup Database**
    ```sql
    -- Connect to PostgreSQL as postgres user
    createdb railway_hmi_db
    psql -d railway_hmi_db
    -- Database schema will be created automatically on first run
    ```

4. **Configure Database Connection**
    ```cpp
    // Update DatabaseManager.cpp line ~50:
    m_database.setPassword("your_postgres_password");
    ```

5. **Build and Run**

    **Using Qt Creator (Recommended):**
    - Open `CMakeLists.txt` in Qt Creator
    - Configure with Qt 6.9.1 MinGW kit
    - Build (Ctrl+B) and Run (Ctrl+R)

    **Command Line:**
    ```bash
    mkdir build && cd build
    cmake .. -DCMAKE_PREFIX_PATH=/path/to/Qt/6.9.1/mingw_64
    make -j4
    ./railway-hmi
    ```

---

## Architecture Overview

### System Design

```
┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   QML Frontend  │    │  C++ Backend     │    │  PostgreSQL DB   │
│                 │    │                  │    │                  │
│ • Professional  │◄──►│ • DatabaseMgr    │◄──►│ • Signal States  │
│   HMI Interface │    │ • Real-time      │    │ • Train Positions│
│ • Touch-friendly│    │   Polling        │    │ • Event Logging  │
│ • Status Display│    │ • Error Handling │    │ • User Sessions  │
└─────────────────┘    └──────────────────┘    └──────────────────┘
```


---

### Data Flow

**User Action → Database Update → Polling Detection → Signal Emission → UI Update**

_Key Principle:_  
UI **never updates optimistically** – only after database confirmation.

---

## Database Schema

```sql
-- Core Tables

CREATE TABLE railway_signals (
  signal_id SERIAL PRIMARY KEY,
  name TEXT,
  state TEXT,
  track_section TEXT,
  last_updated TIMESTAMP
);

CREATE TABLE railway_trains (
  train_id SERIAL PRIMARY KEY,
  name TEXT,
  current_position TEXT,
  status TEXT,
  last_updated TIMESTAMP
);

CREATE TABLE railway_operators (
  operator_id SERIAL PRIMARY KEY,
  name TEXT,
  role TEXT,
  last_login TIMESTAMP
);

CREATE TABLE system_events (
  event_id SERIAL PRIMARY KEY,
  event_type TEXT,
  details TEXT,
  timestamp TIMESTAMP
);
```
---
## Usage
### Basic Operations
**Start Application**
```bash
./railway-hmi.exe
```
---
### Signal Control

Click **"Test Signal"** to cycle through signal states.

**States:**

- RED → YELLOW → GREEN

Changes are immediately reflected in both the database and the UI.

---

### Train Movement

Click **"Move Train"** to update train positions.

**Positions cycle through:**

- Platform A → Junction B → Section C → Terminal D

---

### Performance Tuning

Use mode buttons to adjust responsiveness:

- **Teleportation (1ms):** Ultra-responsive
- **Rocket (50ms):** High performance
- **Supercar (100ms):** Balanced
- **Normal (200ms):** Production-ready

---
### Database Management

**View Real-time Data**

```sql
SELECT * FROM railway_signals
ORDER BY last_updated DESC;

SELECT * FROM railway_trains
ORDER BY last_updated DESC;
```
**Manual State Changes**
```sql
UPDATE railway_signals
SET state = 'GREEN'
WHERE signal_id = 1;

-- The UI will update within the configured polling interval.

```
---

## Development

### Project Structure
```
railway-hmi/
├── CMakeLists.txt # Build configuration
├── main.cpp # Application entry point
├── DatabaseManager.h/.cpp # Database abstraction layer
├── Main.qml # Primary UI interface
├── resources/ # Images, icons, assets
├── docs/ # Documentation and screenshots
├── scripts/ # Deployment and utility scripts
└── tests/ # Unit and integration tests
```
---

### Key Components

**DatabaseManager Class**

```cpp
class DatabaseManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)

public slots:
    void updateSignalState(int signalId, const QString &state);
    void updateTrainPosition(int trainId, const QString &position);

signals:
    void signalStateChanged(int signalId, const QString &state);
    void trainPositionChanged(int trainId, const QString &position);

private slots:
    void pollDatabaseState();  // Real-time polling mechanism
};
```
---
### QML integration
```qml
Connections {
    target: databaseManager
    function onSignalStateChanged(signalId, state) {
        statusDisplay.text = "Signal A" + signalId + ": " + state;
    }
}

```
---
### Building for Development
**Debug Build**
```bash
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j4
```
**Realease Build**
```bash
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j4
```
**Custom Qt**
```bash
cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/6.9.1/mingw_64 ..
```
---

## Deployment
### Creating Portable Executable
**Build Release Version**
```bash
# In Qt Creator: switch to Release mode and build
# Or command line:
cmake --build . --config Release
```
**Deploy Qt Dependencies**
```bash
# Navigate to release build directory
cd build-Release/

# Deploy with SQL drivers (CRITICAL for PostgreSQL)
windeployqt.exe appHelloWorld.exe
```

**Verify Deployment**
```bash
# Check for required files:
ls sqldrivers/qsqlpsql.dll  # PostgreSQL driver
ls Qt6Sql.dll               # SQL module
ls platforms/qwindows.dll   # Platform plugin
```

**Test Standalone**
```bash
# Test on machine without Qt installed
./appHelloWorld.exe
```
---
### Deployment Script
```bat
@echo off
echo Deploying Railway HMI...
cmake --build . --config Release
windeployqt.exe --sql --compiler-runtime railway-hmi.exe
echo  Deployment complete!
```
---
## Performance
### Polling Performance Characterstics

| Mode           | Interval | Frequency | CPU Usage   | Responsiveness       |
|----------------|----------|-----------|-------------|----------------------|
| Teleportation  | 1 ms     | 1000 Hz   | High        | Instant              |
| Rocket         | 50 ms    | 20 Hz     | Low         | Very responsive      |
| Supercar       | 100 ms   | 10 Hz     | Minimal     | Balanced             |
| Normal         | 200 ms   | 5 Hz      | Negligible  | Production-ready     |
---

### Optimization Tip
**1. Database Tuning**

```sql
-- Optimize PostgreSQL for frequent polling
VACUUM ANALYZE railway_signals;
CREATE INDEX ON railway_signals(signal_id);
```

**2. Memory Usage**
```cpp
// State caching prevents redundant UI updates
QMap<int, QString> m_lastKnownSignalSt
```

**3. Network Optimization**
- Use a **local PostgreSQL installation** for optimal performance.
- Avoid remote database connections for real-time operation.
---

## Safety Considerations
### Railway Critical Design Principles

**1. Database as Single Source of Truth**
- UI updates only after database confirmation.

---

**2. Error Handling**

```cpp
if (query.exec()) {
    if (query.numRowsAffected() == 0) {
        emit errorOccurred("Operation failed - no rows affected");
    }
} else {
    logDatabaseError("Update Signal", query.lastError());
}
```
**3. Connection Monitoring**

- Automatic reconnection and clear error states.
- Clear error states displayed to the operators.

---

**4. Audit Trail**

- All operations logged with timestamps.
- Complete event history of safety analysis.

---

### Compliance Features

- RAII Memory Management
- Input Validation
- Graceful Degradation
- Real-time Monitoring

---

## Troubleshooting
### Common Issues

**Database Connection Fails**

_Error:_ 
```error
Driver not loaded `QPSQL`
```

**Solution:**: Ensure SQL drivers deployed with --sql flag:
```bash
windeployqt.exe --sql railway-hmi.exe
```
---

**UI Not Updating**: 
```
Database shows changes but UI doesn't update.
```

**Solution:**  Check polling timer is running:

```cpp
qDebug() << "Polling active:" << m_statePollingTimer->isActive();
```
---

**PostgreSQL Service Issues**
```
Connection Failed: could not connect to server
```
**Solution:** Verify PostgreSQL service:
```bash
# Windows
services.msc  # Look for PostgreSQL service

# Linux  
sudo systemctl status postgresql
```
---

**Performance Issues**
```
High CPU usage or slow response
```
**Solution:** Adjust polling interval:
```cpp
m_statePollingTimer->setInterval(200);  // Increase for lower CPU usage
```
---
### Debug Mode

**Enable detailed logging:**
```cpp
QLoggingCategory::setFilterRules("qt.sql.* = true");
```
---
### Contact Support
- Issues
- Discussions
- Documentation
---

## Contributing
We welcome contributions!

### Development Setup

1. Fork the repository.

2. Create a feature branch:
```bash
git checkout -b feature/your-feature
```

3. Make your changes with proper testing.

4. Ensure all safety-critical features continue to function.

5. Submit a pull request with a detailed description.

6. Code Standards

7. Follow Railway HMI Coding Standards.

8. All safety-critical code must include comprehensive error handling.

9. Database operations must be thoroughly tested.

10. UI changes must maintain a professional HMI appearance.
---

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments

1. [Qt Framework](https://www.qt.io/)
2. [PostgreSQL](https://www.postgresql.org/)
3. [C++ Community](https://isocpp.org/)
4. [CMake](https://cmake.org/)
5. Railway Industry Standards
6. Open Source Community

---

## Project Status
- Core Functionality: Complete
- Database Integration: Complete
- Real-time Updates: Complete
- Deployment: Complete
- Advanced Features: In Development
- Documentation: Ongoing


---



