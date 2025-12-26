/**
 * Qt6 Hello World for webOS
 * Proof of life test application
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QDebug>

int main(int argc, char *argv[])
{
    qDebug() << "Qt6 Hello World starting on webOS...";

    QGuiApplication app(argc, argv);
    app.setApplicationName("Qt6 Hello");
    app.setApplicationVersion("1.0.0");

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            qCritical() << "Failed to load QML";
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    engine.load(url);

    qDebug() << "Qt6 Hello World loaded successfully!";

    return app.exec();
}
