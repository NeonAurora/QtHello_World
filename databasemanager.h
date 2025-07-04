#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlDriver>
#include <QTimer>
#include <QString>
#include <QDebug>
#include <QMap>
#include <memory>

class DatabaseManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)
    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionChanged)

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    bool isConnected() const;
    QString connectionStatus() const;

    Q_INVOKABLE bool connectToDatabase();
    Q_INVOKABLE void disconnectFromDatabase();
    Q_INVOKABLE bool testConnection();
    Q_INVOKABLE void loadCurrentState();
    Q_INVOKABLE void enterTeleportationMode();
    Q_INVOKABLE void enterRocketMode();
    Q_INVOKABLE void enterSupercarMode();
    Q_INVOKABLE void enterNormalMode();

private slots:
    void checkConnection();
    void pollDatabaseState();  // ← New polling method

private:
    QSqlDatabase m_database;
    std::unique_ptr<QTimer> m_connectionTimer;
    std::unique_ptr<QTimer> m_statePollingTimer;  // ← New polling timer
    bool m_isConnected = false;
    QString m_connectionStatus = "Not Connected";

    // ✅ Track last known states for change detection
    QMap<int, QString> m_lastKnownSignalStates;
    QMap<int, QString> m_lastKnownTrainPositions;

    void setupDatabase();
    void logDatabaseError(const QString &operation, const QSqlError &error);

signals:
    void connectionChanged();
    void signalStateChanged(int signalId, const QString &state);
    void trainPositionChanged(int trainId, const QString &position);
    void errorOccurred(const QString &error);

public slots:
    void updateSignalState(int signalId, const QString &state);
    void updateTrainPosition(int trainId, const QString &position);
};

#endif // DATABASEMANAGER_H
