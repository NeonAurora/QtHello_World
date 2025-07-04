#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
    , m_connectionTimer(std::make_unique<QTimer>(this))
    , m_statePollingTimer(std::make_unique<QTimer>(this))
{
    // ✅ Setup connection monitoring
    m_connectionTimer->setInterval(5000); // Check every 5 seconds
    connect(m_connectionTimer.get(), &QTimer::timeout,
            this, &DatabaseManager::checkConnection);

    // ✅ Setup database state polling (Railway-safe approach)
    m_statePollingTimer->setInterval(1); // Poll every 200ms for real-time feel
    connect(m_statePollingTimer.get(), &QTimer::timeout,
            this, &DatabaseManager::pollDatabaseState);

    qDebug() << "🚂 DatabaseManager initialized with polling approach";

    connectToDatabase();
}

DatabaseManager::~DatabaseManager()
{
    disconnectFromDatabase();
    qDebug() << "🚂 DatabaseManager destroyed";
}

bool DatabaseManager::isConnected() const
{
    return m_isConnected;
}

QString DatabaseManager::connectionStatus() const
{
    return m_connectionStatus;
}

bool DatabaseManager::connectToDatabase()
{
    try {
        m_database = QSqlDatabase::addDatabase("QPSQL", "railway_connection");
        m_database.setHostName("localhost");
        m_database.setPort(5432);
        m_database.setDatabaseName("postgres");
        m_database.setUserName("postgres");
        m_database.setPassword("qwerty");

        if (m_database.open()) {
            m_isConnected = true;
            m_connectionStatus = "Connected to PostgreSQL";

            qDebug() << "✅ Database connected successfully";

            setupDatabase();

            // ✅ Start monitoring
            m_connectionTimer->start();
            m_statePollingTimer->start(); // Start polling

            emit connectionChanged();
            return true;
        } else {
            m_isConnected = false;
            m_connectionStatus = "Connection Failed: " + m_database.lastError().text();
            logDatabaseError("Connection", m_database.lastError());
            emit connectionChanged();
            emit errorOccurred(m_connectionStatus);
            return false;
        }
    } catch (const std::exception& e) {
        m_isConnected = false;
        m_connectionStatus = QString("Exception: %1").arg(e.what());
        emit connectionChanged();
        emit errorOccurred(m_connectionStatus);
        return false;
    }
}

void DatabaseManager::disconnectFromDatabase()
{
    if (m_database.isOpen()) {
        m_connectionTimer->stop();
        m_statePollingTimer->stop(); // Stop polling
        m_database.close();
        m_isConnected = false;
        m_connectionStatus = "Disconnected";
        emit connectionChanged();
        qDebug() << "🔌 Database disconnected";
    }
}

bool DatabaseManager::testConnection()
{
    if (!m_database.isOpen()) {
        return connectToDatabase();
    }

    QSqlQuery query(m_database);
    if (query.exec("SELECT 1")) {
        qDebug() << "✅ Database test query successful";
        return true;
    } else {
        logDatabaseError("Test Query", query.lastError());
        return false;
    }
}

void DatabaseManager::setupDatabase()
{
    QSqlQuery query(m_database);

    // Create signals table
    QString createSignalsTable = R"(
        CREATE TABLE IF NOT EXISTS railway_signals (
            signal_id SERIAL PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            state VARCHAR(10) DEFAULT 'RED',
            track_section VARCHAR(50),
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    if (!query.exec(createSignalsTable)) {
        logDatabaseError("Create Signals Table", query.lastError());
        return;
    }

    // Create trains table
    QString createTrainsTable = R"(
        CREATE TABLE IF NOT EXISTS railway_trains (
            train_id SERIAL PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            current_position VARCHAR(100),
            status VARCHAR(20) DEFAULT 'STOPPED',
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    if (!query.exec(createTrainsTable)) {
        logDatabaseError("Create Trains Table", query.lastError());
        return;
    }

    // Insert test data if tables are empty
    query.exec("SELECT COUNT(*) FROM railway_signals");
    if (query.next() && query.value(0).toInt() == 0) {
        query.exec("INSERT INTO railway_signals (name, state, track_section) VALUES "
                   "('Signal A1', 'RED', 'Platform A'), "
                   "('Signal B2', 'GREEN', 'Junction B'), "
                   "('Signal C3', 'YELLOW', 'Section C')");
        qDebug() << "✅ Test signals inserted";
    }

    query.exec("SELECT COUNT(*) FROM railway_trains");
    if (query.next() && query.value(0).toInt() == 0) {
        query.exec("INSERT INTO railway_trains (name, current_position, status) VALUES "
                   "('Train 001', 'Platform A', 'STOPPED'), "
                   "('Train 002', 'Junction B', 'MOVING')");
        qDebug() << "✅ Test trains inserted";
    }

    qDebug() << "✅ Railway database schema initialized";

    // ✅ Load initial state
    loadCurrentState();
}

// ✅ NEW: Railway-safe database polling
void DatabaseManager::pollDatabaseState()
{
    if (!m_isConnected) return;

    try {
        // Poll signal states
        QSqlQuery signalQuery(m_database);
        if (signalQuery.exec("SELECT signal_id, state FROM railway_signals ORDER BY signal_id")) {
            while (signalQuery.next()) {
                int signalId = signalQuery.value("signal_id").toInt();
                QString currentState = signalQuery.value("state").toString();

                // Check if state changed from last known state
                if (!m_lastKnownSignalStates.contains(signalId) ||
                    m_lastKnownSignalStates[signalId] != currentState) {

                    qDebug() << "🔄 DATABASE CHANGE DETECTED: Signal" << signalId << "changed to" << currentState;
                    m_lastKnownSignalStates[signalId] = currentState;
                    emit signalStateChanged(signalId, currentState);
                }
            }
        }

        // Poll train positions
        QSqlQuery trainQuery(m_database);
        if (trainQuery.exec("SELECT train_id, current_position FROM railway_trains ORDER BY train_id")) {
            while (trainQuery.next()) {
                int trainId = trainQuery.value("train_id").toInt();
                QString currentPosition = trainQuery.value("current_position").toString();

                if (!m_lastKnownTrainPositions.contains(trainId) ||
                    m_lastKnownTrainPositions[trainId] != currentPosition) {

                    qDebug() << "🔄 DATABASE CHANGE DETECTED: Train" << trainId << "moved to" << currentPosition;
                    m_lastKnownTrainPositions[trainId] = currentPosition;
                    emit trainPositionChanged(trainId, currentPosition);
                }
            }
        }

    } catch (const std::exception& e) {
        qDebug() << "❌ Error polling database:" << e.what();
    }
}

void DatabaseManager::checkConnection()
{
    if (!testConnection()) {
        m_isConnected = false;
        m_connectionStatus = "Connection Lost";
        emit connectionChanged();
        qDebug() << "🔄 Attempting to reconnect...";
        connectToDatabase();
    }
}

void DatabaseManager::updateSignalState(int signalId, const QString &state)
{
    if (!m_isConnected) {
        qDebug() << "❌ Cannot update signal: Database not connected";
        emit errorOccurred("Cannot update signal: Database not connected");
        return;
    }

    QSqlQuery query(m_database);
    query.prepare("UPDATE railway_signals SET state = ?, last_updated = CURRENT_TIMESTAMP WHERE signal_id = ?");
    query.addBindValue(state);
    query.addBindValue(signalId);

    if (query.exec()) {
        qDebug() << "✅ Signal" << signalId << "UPDATE command sent to database";
        // ✅ UI will update within 200ms via polling

        if (query.numRowsAffected() == 0) {
            qDebug() << "⚠️ Warning: No signal found with ID" << signalId;
            emit errorOccurred(QString("No signal found with ID %1").arg(signalId));
        }
    } else {
        QString errorMsg = QString("Failed to update signal %1: %2").arg(signalId).arg(query.lastError().text());
        qDebug() << "❌" << errorMsg;
        emit errorOccurred(errorMsg);
        logDatabaseError("Update Signal", query.lastError());
    }
}

void DatabaseManager::updateTrainPosition(int trainId, const QString &position)
{
    if (!m_isConnected) {
        qDebug() << "❌ Cannot update train: Database not connected";
        emit errorOccurred("Cannot update train: Database not connected");
        return;
    }

    QSqlQuery query(m_database);
    query.prepare("UPDATE railway_trains SET current_position = ?, last_updated = CURRENT_TIMESTAMP WHERE train_id = ?");
    query.addBindValue(position);
    query.addBindValue(trainId);

    if (query.exec()) {
        qDebug() << "✅ Train" << trainId << "UPDATE command sent to database";
        // ✅ UI will update within 200ms via polling

        if (query.numRowsAffected() == 0) {
            qDebug() << "⚠️ Warning: No train found with ID" << trainId;
            emit errorOccurred(QString("No train found with ID %1").arg(trainId));
        }
    } else {
        QString errorMsg = QString("Failed to update train %1: %2").arg(trainId).arg(query.lastError().text());
        qDebug() << "❌" << errorMsg;
        emit errorOccurred(errorMsg);
        logDatabaseError("Update Train Position", query.lastError());
    }
}

void DatabaseManager::loadCurrentState()
{
    if (!m_isConnected) {
        qDebug() << "❌ Cannot load state: Database not connected";
        return;
    }

    // Load and cache current signal states
    QSqlQuery signalQuery(m_database);
    if (signalQuery.exec("SELECT signal_id, state, name FROM railway_signals ORDER BY signal_id")) {
        while (signalQuery.next()) {
            int signalId = signalQuery.value("signal_id").toInt();
            QString state = signalQuery.value("state").toString();
            QString name = signalQuery.value("name").toString();

            qDebug() << "📊 Loading signal state:" << name << "(" << signalId << ") =" << state;
            m_lastKnownSignalStates[signalId] = state; // Cache it
            emit signalStateChanged(signalId, state);
        }
    }

    // Load and cache current train positions
    QSqlQuery trainQuery(m_database);
    if (trainQuery.exec("SELECT train_id, current_position, name FROM railway_trains ORDER BY train_id")) {
        while (trainQuery.next()) {
            int trainId = trainQuery.value("train_id").toInt();
            QString position = trainQuery.value("current_position").toString();
            QString name = trainQuery.value("name").toString();

            qDebug() << "📊 Loading train position:" << name << "(" << trainId << ") =" << position;
            m_lastKnownTrainPositions[trainId] = position; // Cache it
            emit trainPositionChanged(trainId, position);
        }
    }
}

void DatabaseManager::logDatabaseError(const QString &operation, const QSqlError &error)
{
    QString errorMsg = QString("❌ Database %1 Error: %2").arg(operation, error.text());
    qDebug() << errorMsg;
    emit errorOccurred(errorMsg);
}

void DatabaseManager::enterTeleportationMode() {
    m_statePollingTimer->setInterval(1);  // 1ms = 1000 Hz
    qDebug() << "⚡ TELEPORTATION MODE ACTIVATED! (1ms polling)";
    qDebug() << "🔥 Warning: May cause spontaneous combustion of CPU";
}

void DatabaseManager::enterRocketMode() {
    m_statePollingTimer->setInterval(10);  // 10ms = 100 Hz
    qDebug() << "🚀 ROCKET MODE ACTIVATED! (10ms polling)";
}

void DatabaseManager::enterSupercarMode() {
    m_statePollingTimer->setInterval(50);  // 50ms = 20 Hz
    qDebug() << "🏎️ SUPERCAR MODE ACTIVATED! (50ms polling)";
}

void DatabaseManager::enterNormalMode() {
    m_statePollingTimer->setInterval(200); // 200ms = 5 Hz
    qDebug() << "🚂 NORMAL RAILWAY MODE ACTIVATED (200ms polling)";
}
