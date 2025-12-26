import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    visible: true
    visibility: Window.FullScreen
    title: "Qt6 on webOS"
    color: "#1a1a2e"

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f0c29" }
            GradientStop { position: 0.5; color: "#302b63" }
            GradientStop { position: 1.0; color: "#24243e" }
        }

        // Header
        Rectangle {
            id: header
            width: parent.width
            height: 80
            color: "#e94560"

            Text {
                anchors.centerIn: parent
                text: "Qt6 on HP TouchPad"
                font.pixelSize: 36
                font.bold: true
                color: "white"
            }
        }

        // Main content area
        Flickable {
            anchors.top: header.bottom
            anchors.bottom: footer.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            contentHeight: mainLayout.height
            clip: true

            ColumnLayout {
                id: mainLayout
                width: parent.width
                spacing: 25

                // Welcome section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    radius: 15
                    color: "#ffffff20"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        Rectangle {
                            width: 80
                            height: 80
                            radius: 40
                            color: "#41b883"

                            Text {
                                anchors.centerIn: parent
                                text: "Qt"
                                font.pixelSize: 32
                                font.bold: true
                                color: "white"
                            }

                            RotationAnimation on rotation {
                                loops: Animation.Infinite
                                from: 0
                                to: 360
                                duration: 8000
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "Welcome to Qt " + Qt.version
                                font.pixelSize: 28
                                font.bold: true
                                color: "white"
                            }
                            Text {
                                text: "Running on " + Qt.platform.os + " (webOS)"
                                font.pixelSize: 18
                                color: "#aaa"
                            }
                        }
                    }
                }

                // Interactive Controls Section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: controlsColumn.height + 40
                    radius: 15
                    color: "#ffffff15"

                    Column {
                        id: controlsColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 20
                        spacing: 20

                        Text {
                            text: "Interactive Controls"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#e94560"
                        }

                        // Slider
                        RowLayout {
                            width: parent.width
                            spacing: 15

                            Text {
                                text: "Slider:"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredWidth: 100
                            }

                            Slider {
                                id: demoSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: 50

                                background: Rectangle {
                                    x: demoSlider.leftPadding
                                    y: demoSlider.topPadding + demoSlider.availableHeight / 2 - height / 2
                                    width: demoSlider.availableWidth
                                    height: 8
                                    radius: 4
                                    color: "#555"

                                    Rectangle {
                                        width: demoSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#e94560"
                                        radius: 4
                                    }
                                }

                                handle: Rectangle {
                                    x: demoSlider.leftPadding + demoSlider.visualPosition * (demoSlider.availableWidth - width)
                                    y: demoSlider.topPadding + demoSlider.availableHeight / 2 - height / 2
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: demoSlider.pressed ? "#c92a4a" : "#e94560"
                                }
                            }

                            Text {
                                text: Math.round(demoSlider.value) + "%"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredWidth: 50
                            }
                        }

                        // Progress bar controlled by slider
                        RowLayout {
                            width: parent.width
                            spacing: 15

                            Text {
                                text: "Progress:"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredWidth: 100
                            }

                            ProgressBar {
                                id: progressBar
                                Layout.fillWidth: true
                                value: demoSlider.value / 100

                                background: Rectangle {
                                    implicitHeight: 20
                                    color: "#555"
                                    radius: 10
                                }

                                contentItem: Rectangle {
                                    width: progressBar.visualPosition * parent.width
                                    height: parent.height
                                    radius: 10
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#41b883" }
                                        GradientStop { position: 1.0; color: "#35495e" }
                                    }
                                }
                            }
                        }

                        // Checkboxes
                        RowLayout {
                            width: parent.width
                            spacing: 30

                            Text {
                                text: "Options:"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredWidth: 100
                            }

                            CheckBox {
                                id: check1
                                text: "Enable Feature A"
                                checked: true
                                contentItem: Text {
                                    text: check1.text
                                    font.pixelSize: 16
                                    color: "white"
                                    leftPadding: check1.indicator.width + 10
                                }
                                indicator: Rectangle {
                                    width: 26
                                    height: 26
                                    radius: 5
                                    color: check1.checked ? "#41b883" : "#555"
                                    Text {
                                        anchors.centerIn: parent
                                        text: check1.checked ? "✓" : ""
                                        color: "white"
                                        font.pixelSize: 18
                                    }
                                }
                            }

                            CheckBox {
                                id: check2
                                text: "Enable Feature B"
                                contentItem: Text {
                                    text: check2.text
                                    font.pixelSize: 16
                                    color: "white"
                                    leftPadding: check2.indicator.width + 10
                                }
                                indicator: Rectangle {
                                    width: 26
                                    height: 26
                                    radius: 5
                                    color: check2.checked ? "#41b883" : "#555"
                                    Text {
                                        anchors.centerIn: parent
                                        text: check2.checked ? "✓" : ""
                                        color: "white"
                                        font.pixelSize: 18
                                    }
                                }
                            }
                        }

                        // Text Input
                        RowLayout {
                            width: parent.width
                            spacing: 15

                            Text {
                                text: "Input:"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredWidth: 100
                            }

                            TextField {
                                id: textInput
                                Layout.fillWidth: true
                                placeholderText: "Type something here..."
                                font.pixelSize: 18
                                color: "white"

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff20"
                                    border.color: textInput.activeFocus ? "#e94560" : "#555"
                                    border.width: 2
                                }
                            }
                        }
                    }
                }

                // Buttons Section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    radius: 15
                    color: "#ffffff15"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Text {
                            text: "Buttons"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#e94560"
                        }

                        Row {
                            spacing: 20
                            anchors.horizontalCenter: parent.horizontalCenter

                            Button {
                                id: btn1
                                text: "Primary"
                                font.pixelSize: 18

                                background: Rectangle {
                                    implicitWidth: 150
                                    implicitHeight: 50
                                    radius: 25
                                    color: btn1.pressed ? "#c92a4a" : "#e94560"
                                }

                                contentItem: Text {
                                    text: btn1.text
                                    font: btn1.font
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: statusText.text = "Primary button clicked!"
                            }

                            Button {
                                id: btn2
                                text: "Secondary"
                                font.pixelSize: 18

                                background: Rectangle {
                                    implicitWidth: 150
                                    implicitHeight: 50
                                    radius: 25
                                    color: btn2.pressed ? "#2d8a5f" : "#41b883"
                                }

                                contentItem: Text {
                                    text: btn2.text
                                    font: btn2.font
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: statusText.text = "Secondary button clicked!"
                            }

                            Button {
                                id: btn3
                                text: "Outline"
                                font.pixelSize: 18

                                background: Rectangle {
                                    implicitWidth: 150
                                    implicitHeight: 50
                                    radius: 25
                                    color: btn3.pressed ? "#ffffff30" : "transparent"
                                    border.color: "#e94560"
                                    border.width: 2
                                }

                                contentItem: Text {
                                    text: btn3.text
                                    font: btn3.font
                                    color: "#e94560"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: statusText.text = "Outline button clicked!"
                            }
                        }
                    }
                }

                // Animation Demo
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    radius: 15
                    color: "#ffffff15"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Text {
                            text: "Animations"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#e94560"
                        }

                        Row {
                            width: parent.width
                            spacing: 40
                            anchors.horizontalCenter: parent.horizontalCenter

                            // Bouncing ball
                            Rectangle {
                                width: 100
                                height: 100
                                color: "transparent"

                                Rectangle {
                                    id: ball
                                    width: 50
                                    height: 50
                                    radius: 25
                                    color: "#e94560"
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    SequentialAnimation on y {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 50; duration: 500; easing.type: Easing.OutBounce }
                                        NumberAnimation { to: 0; duration: 500; easing.type: Easing.OutQuad }
                                    }
                                }
                            }

                            // Pulsing circle
                            Rectangle {
                                width: 100
                                height: 100
                                color: "transparent"

                                Rectangle {
                                    width: 60
                                    height: 60
                                    radius: 30
                                    color: "#41b883"
                                    anchors.centerIn: parent

                                    SequentialAnimation on scale {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 1.3; duration: 800; easing.type: Easing.InOutQuad }
                                        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                                    }

                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.5; duration: 800 }
                                        NumberAnimation { to: 1.0; duration: 800 }
                                    }
                                }
                            }

                            // Spinning square
                            Rectangle {
                                width: 100
                                height: 100
                                color: "transparent"

                                Rectangle {
                                    width: 50
                                    height: 50
                                    color: "#9b59b6"
                                    anchors.centerIn: parent

                                    RotationAnimation on rotation {
                                        loops: Animation.Infinite
                                        from: 0
                                        to: 360
                                        duration: 2000
                                    }
                                }
                            }

                            // Color changing
                            Rectangle {
                                width: 100
                                height: 100
                                color: "transparent"

                                Rectangle {
                                    id: colorRect
                                    width: 60
                                    height: 60
                                    radius: 10
                                    anchors.centerIn: parent

                                    SequentialAnimation on color {
                                        loops: Animation.Infinite
                                        ColorAnimation { to: "#e94560"; duration: 1000 }
                                        ColorAnimation { to: "#41b883"; duration: 1000 }
                                        ColorAnimation { to: "#3498db"; duration: 1000 }
                                        ColorAnimation { to: "#f39c12"; duration: 1000 }
                                    }
                                }
                            }
                        }
                    }
                }

                // Counter Demo
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    radius: 15
                    color: "#ffffff15"

                    property int counter: 0

                    Row {
                        anchors.centerIn: parent
                        spacing: 30

                        Button {
                            text: "-"
                            font.pixelSize: 32
                            width: 60
                            height: 60

                            background: Rectangle {
                                radius: 30
                                color: parent.pressed ? "#c92a4a" : "#e94560"
                            }

                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: parent.parent.parent.counter--
                        }

                        Text {
                            text: parent.parent.counter
                            font.pixelSize: 48
                            font.bold: true
                            color: "white"
                            width: 120
                            horizontalAlignment: Text.AlignHCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Button {
                            text: "+"
                            font.pixelSize: 32
                            width: 60
                            height: 60

                            background: Rectangle {
                                radius: 30
                                color: parent.pressed ? "#2d8a5f" : "#41b883"
                            }

                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: parent.parent.parent.counter++
                        }
                    }
                }

                // Spacer at bottom
                Item {
                    Layout.preferredHeight: 20
                }
            }
        }

        // Footer with status
        Rectangle {
            id: footer
            width: parent.width
            height: 60
            anchors.bottom: parent.bottom
            color: "#00000050"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15

                Text {
                    id: statusText
                    text: "Qt6 running successfully on webOS!"
                    font.pixelSize: 18
                    color: "#7ec8e3"
                    Layout.fillWidth: true
                }

                Text {
                    text: new Date().toLocaleTimeString()
                    font.pixelSize: 16
                    color: "#888"

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: parent.text = new Date().toLocaleTimeString()
                    }
                }
            }
        }
    }
}
