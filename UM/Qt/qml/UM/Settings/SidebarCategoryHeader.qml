// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.1 as UM

Button {
    id: base;

    property variant color;

    style: UM.Theme.styles.sidebar_category;

    signal configureSettingVisibility()
    signal showAllHiddenInheritedSettings()

    signal showTooltip();
    signal hideTooltip();

    UM.SimpleButton {
        id: settingsButton

        visible: base.hovered || settingsButton.hovered
        height: base.height * 0.6
        width: base.height * 0.6

        anchors {
            right: inheritButton.visible ? inheritButton.left : parent.right
            rightMargin: inheritButton.visible? UM.Theme.getSize("default_margin").width / 2 : UM.Theme.getSize("setting_preferences_button_margin").width
            verticalCenter: parent.verticalCenter;
        }

        color: hovered ? UM.Theme.getColor("setting_control_button_hover") : UM.Theme.getColor("setting_control_button");
        iconSource: UM.Theme.getIcon("settings");

        onClicked: {
            base.configureSettingVisibility()
        }
    }
    UM.SimpleButton
    {
        // This button shows when the setting has an inherited function, but is overriden by profile.
        id: inheritButton;

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: UM.Theme.getSize("setting_preferences_button_margin").width

        visible: hiddenValuesCount > 0
        height: parent.height / 2;
        width: height;

        onClicked: {
            base.showAllHiddenInheritedSettings()
        }

        color: hovered ? UM.Theme.getColor("setting_control_button_hover") : UM.Theme.getColor("setting_control_button")
        iconSource: UM.Theme.getIcon("notice")

        MouseArea
        {
            id: inheritButtonMouseArea;

            anchors.fill: parent;

            acceptedButtons: Qt.NoButton
            hoverEnabled: true;

            onEntered: {
                base.showTooltip()
            }

            onExited: {
                base.hideTooltip();
            }
        }
    }
}

