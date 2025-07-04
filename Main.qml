import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800
    visible: true
    title: appName + " - Railway Control System"

    // ✅ Professional Railway HMI Theme
    QtObject {
        id: theme
        readonly property color darkBackground: "#1a1a1a"
        readonly property color controlBackground: "#2d3748"
        readonly property color accentBlue: "#3182ce"
        readonly property color successGreen: "#38a169"
        readonly property color warningYellow: "#d69e2e"
        readonly property color dangerRed: "#e53e3e"
        readonly property color textPrimary: "#ffffff"
        readonly property color textSecondary: "#a0aec0"
        readonly property color borderColor: "#4a5568"

        // Spacing system
        readonly property int spacingTiny: 4
        readonly property int spacingSmall: 8
        readonly property int spacingMedium: 16
        readonly property int spacingLarge: 24
        readonly property int spacingHuge: 32
    }

    // ✅ Solid professional background (no gradients)
    Rectangle {
        anchors.fill: parent
        color: theme.darkBackground
    }

    // Main content container
    Rectangle {
        anchors.fill: parent
        anchors.margins: theme.spacingLarge
        color: "transparent"

        // Header section
        Rectangle {
            id: headerSection
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 120
            color: theme.controlBackground
            radius: 8
            border.color: theme.borderColor
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: theme.spacingLarge

                // System status indicator
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: theme.successGreen
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "RAILWAY CONTROL SYSTEM"
                        font.family: "Segoe UI"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: theme.textPrimary
                    }

                    Text {
                        text: "Professional Railway Signaling & Train Control"
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                        color: theme.textSecondary
                    }
                }

                // Version info panel
                Rectangle {
                    width: 200
                    height: 60
                    color: theme.darkBackground
                    radius: 4
                    border.color: theme.borderColor
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Column {
                        anchors.centerIn: parent
                        spacing: theme.spacingTiny

                        Text {
                            text: "Version: " + appVersion
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                            color: theme.textPrimary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Qt 6.9 + PostgreSQL 17"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            color: theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        // Main control panel
        Rectangle {
            id: controlPanel
            anchors.top: headerSection.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: statusPanel.top
            anchors.topMargin: theme.spacingLarge
            anchors.bottomMargin: theme.spacingLarge
            color: theme.controlBackground
            radius: 8
            border.color: theme.borderColor
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: theme.spacingHuge

                // Signal control section
                Column {
                    spacing: theme.spacingMedium
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "SIGNAL CONTROL"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: theme.textPrimary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        spacing: theme.spacingLarge
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Signal Control Button - Professional Railway Style
                        Button {
                            id: signalButton
                            text: "SIGNAL CONTROL"
                            width: 180
                            height: 60
                            enabled: databaseManager.isConnected

                            background: Rectangle {
                                color: {
                                    if (!signalButton.enabled) return theme.borderColor
                                    if (signalButton.pressed) return theme.accentBlue
                                    return theme.successGreen
                                }
                                radius: 4
                                border.color: theme.borderColor
                                border.width: 2

                                // Professional button indicator
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: signalButton.enabled ? theme.textPrimary : theme.textSecondary
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 8
                                }
                            }

                            contentItem: Text {
                                text: signalButton.text
                                font.family: "Segoe UI"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                let states = ["RED", "YELLOW", "GREEN"];
                                let randomState = states[Math.floor(Math.random() * states.length)];
                                databaseManager.updateSignalState(1, randomState);
                                console.log("Signal updated in database:", randomState);
                            }
                        }

                        // Train Control Button - Professional Railway Style
                        Button {
                            id: trainButton
                            text: "TRAIN CONTROL"
                            width: 180
                            height: 60
                            enabled: databaseManager.isConnected

                            background: Rectangle {
                                color: {
                                    if (!trainButton.enabled) return theme.borderColor
                                    if (trainButton.pressed) return theme.accentBlue
                                    return theme.warningYellow
                                }
                                radius: 4
                                border.color: theme.borderColor
                                border.width: 2

                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: trainButton.enabled ? theme.textPrimary : theme.textSecondary
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 8
                                }
                            }

                            contentItem: Text {
                                text: trainButton.text
                                font.family: "Segoe UI"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: theme.darkBackground
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                let positions = ["Platform A", "Junction B", "Section C", "Terminal D"];
                                let randomPos = positions[Math.floor(Math.random() * positions.length)];
                                databaseManager.updateTrainPosition(1, randomPos);
                                console.log("Train updated in database:", randomPos);
                            }
                        }
                    }
                }

                // Status display section - Critical Information
                Column {
                    spacing: theme.spacingMedium
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "SYSTEM STATUS"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: theme.textPrimary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: 500
                        height: 120
                        color: theme.darkBackground
                        radius: 4
                        border.color: theme.borderColor
                        border.width: 2
                        anchors.horizontalCenter: parent.horizontalCenter

                        Column {
                            anchors.centerIn: parent
                            spacing: theme.spacingMedium

                            // Signal status - Critical safety information
                            Rectangle {
                                width: 460
                                height: 40
                                color: "transparent"
                                border.color: theme.borderColor
                                border.width: 1
                                radius: 4
                                anchors.horizontalCenter: parent.horizontalCenter

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: theme.spacingMedium
                                    spacing: theme.spacingMedium

                                    Text {
                                        text: "SIGNAL:"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        color: theme.textSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        id: statusDisplay
                                        text: "A1 - RED (STOP)"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                        color: theme.dangerRed
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            // Train status
                            Rectangle {
                                width: 460
                                height: 40
                                color: "transparent"
                                border.color: theme.borderColor
                                border.width: 1
                                radius: 4
                                anchors.horizontalCenter: parent.horizontalCenter

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: theme.spacingMedium
                                    spacing: theme.spacingMedium

                                    Text {
                                        text: "TRAIN:"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        color: theme.textSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        id: trainStatus
                                        text: "001 - Platform A (STOPPED)"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                        color: theme.warningYellow
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }

                // Performance control section
                Column {
                    spacing: theme.spacingMedium
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "PERFORMANCE MODE"
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: theme.textSecondary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        spacing: theme.spacingSmall
                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {
                            text: "1ms"
                            width: 80
                            height: 48
                            background: Rectangle {
                                color: parent.pressed ? theme.accentBlue : theme.controlBackground
                                radius: 4
                                border.color: theme.borderColor
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: databaseManager.enterTeleportationMode()
                        }

                        Button {
                            text: "10ms"
                            width: 80
                            height: 48
                            background: Rectangle {
                                color: parent.pressed ? theme.accentBlue : theme.controlBackground
                                radius: 4
                                border.color: theme.borderColor
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: databaseManager.enterRocketMode()
                        }

                        Button {
                            text: "50ms"
                            width: 80
                            height: 48
                            background: Rectangle {
                                color: parent.pressed ? theme.accentBlue : theme.controlBackground
                                radius: 4
                                border.color: theme.borderColor
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: databaseManager.enterSupercarMode()
                        }

                        Button {
                            text: "200ms"
                            width: 80
                            height: 48
                            background: Rectangle {
                                color: parent.pressed ? theme.accentBlue : theme.controlBackground
                                radius: 4
                                border.color: theme.borderColor
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: databaseManager.enterNormalMode()
                        }
                    }
                }
            }
        }

        // Professional status bar
        Rectangle {
            id: statusPanel
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 60
            color: theme.controlBackground
            radius: 8
            border.color: theme.borderColor
            border.width: 1

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: theme.spacingLarge
                spacing: theme.spacingHuge

                // System status
                Row {
                    spacing: theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: theme.successGreen
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "SYSTEM ONLINE"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: theme.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Database status
                Row {
                    spacing: theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: databaseManager.isConnected ? theme.successGreen : theme.dangerRed
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: databaseManager.isConnected ?
                              "DATABASE CONNECTED" :
                              "DATABASE: " + databaseManager.connectionStatus.toUpperCase()
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: databaseManager.isConnected ? theme.textPrimary : theme.dangerRed
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Mode indicator
                Row {
                    spacing: theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: theme.warningYellow
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "DEVELOPMENT MODE"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: theme.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Timestamp
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: theme.spacingLarge
                text: new Date().toLocaleString()
                font.family: "Segoe UI"
                font.pixelSize: 11
                color: theme.textSecondary
            }
        }
    }

    // ✅ Professional data binding - Railway safety compliant
    Connections {
        target: databaseManager

        function onSignalStateChanged(signalId, state) {
            console.log("🔔 QML RECEIVED: Signal", signalId, "changed to", state);

            // Update UI based on confirmed database state
            let displayText = "";
            let color = "";

            switch(state) {
                case "RED":
                    displayText = "A" + signalId + " - RED (STOP)";
                    color = theme.dangerRed;
                    break;
                case "YELLOW":
                    displayText = "A" + signalId + " - YELLOW (CAUTION)";
                    color = theme.warningYellow;
                    break;
                case "GREEN":
                    displayText = "A" + signalId + " - GREEN (PROCEED)";
                    color = theme.successGreen;
                    break;
                default:
                    displayText = "A" + signalId + " - UNKNOWN";
                    color = theme.textSecondary;
            }

            statusDisplay.text = displayText;
            statusDisplay.color = color;
        }

        function onTrainPositionChanged(trainId, position) {
            console.log("🔔 QML RECEIVED: Train", trainId, "moved to", position);

            let formattedId = String(trainId).padStart(3, '0');
            trainStatus.text = formattedId + " - " + position + " (ACTIVE)";
        }

        function onErrorOccurred(error) {
            console.log("❌ QML RECEIVED ERROR:", error);
            statusDisplay.text = "SYSTEM ERROR: " + error.toUpperCase();
            statusDisplay.color = theme.dangerRed;
        }
    }
}
