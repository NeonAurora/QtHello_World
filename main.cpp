#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include "DatabaseManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // ✅ Set application properties
    app.setApplicationName("Railway HMI System");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("RailFlux");

    app.setWindowIcon(QIcon(":/resources/icons/railway-icon.ico"));

    QQmlApplicationEngine engine;

    // ✅ Create and register DatabaseManager
    auto databaseManager = std::make_unique<DatabaseManager>();

    // ✅ Expose to QML context
    engine.rootContext()->setContextProperty("appVersion", app.applicationVersion());
    engine.rootContext()->setContextProperty("appName", app.applicationName());
    engine.rootContext()->setContextProperty("databaseManager", databaseManager.get());

    // ✅ Load QML
    const QUrl url(QStringLiteral("qrc:/qt/qml/HelloWorld/Main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
