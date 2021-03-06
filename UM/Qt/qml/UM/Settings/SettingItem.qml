// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the AGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.1 as UM

Item {
    id: base;

    property string name;
    property string description;
    property variant value;
    property string unit;
    property int valid;
    property string type;
    property int depth;
    property int visible_depth;

    property variant options;
    property int index;
    property variant key;

    property bool overridden;
    property bool is_enabled: parent.settingEnabled != false; // allow cases where parent.settingEnabled is not defined
    property bool has_inherit_function;
    property bool has_profile_value;
    property bool indent: true;
    property variant default_value;

    signal contextMenuRequested();
    signal itemValueChanged(variant value);
    signal showTooltip(variant position);
    signal hideTooltip();
    signal showInheritanceTooltip(variant position);
    signal showResetTooltip(variant position);
    signal resetRequested();
    signal resetToDefaultRequested();

    property bool hovered: false;

    MouseArea
    {
        id: mouse;

        anchors.fill: parent;

        acceptedButtons: Qt.RightButton;
        hoverEnabled: true;

        onClicked: base.contextMenuRequested();

        onEntered: {
            hoverTimer.start();
            base.hovered = true;
        }

        onExited: {
            if(controlContainer.item && controlContainer.item.hovered) {
                return;
            }

            base.hovered = false;
            hoverTimer.stop();
            base.hideTooltip();
        }

        Timer {
            id: hoverTimer;
            interval: 500;
            repeat: false;

            onTriggered: base.showTooltip({ x: mouse.mouseX, y: mouse.mouseY });
        }
    }
    property variant style: SettingItemStyle { }

    Rectangle{
        visible: base.visible_depth > 1 ? true : false
        id: separationLine
        width: UM.Theme.getSize("default_lining").width
        height: label.height
        color: UM.Theme.getColor("setting_control_depth_line");
        anchors.right: label.left
        anchors.rightMargin: UM.Theme.getSize("setting_control_depth_margin").width / 2
        anchors.verticalCenter: parent.verticalCenter
        z: parent.z + 1
    }

    Label
    {
        id: label;
        property int depth: base.visible_depth - 1;

        anchors.left: parent.left;
        anchors.leftMargin: base.indent ? (UM.Theme.getSize("section_icon_column").width + 5) + (label.depth * UM.Theme.getSize("setting_control_depth_margin").width) : 0
        anchors.right: settingControls.left;
        anchors.verticalCenter: parent.verticalCenter

        height: UM.Theme.getSize("section").height;
        verticalAlignment: Text.AlignVCenter;

        text: base.name
        elide: Text.ElideMiddle;

        color: base.style.controlTextColor;
        font: base.style.labelFont;
    }

    Row
    {
        id: settingControls

        height: parent.height / 2
        spacing: UM.Theme.getSize("default_margin").width / 2

        anchors {
            right: controlContainer.left
            rightMargin: UM.Theme.getSize("default_margin").width / 2
            verticalCenter: parent.verticalCenter
        }

        UM.SimpleButton
        {
            id: revertButton;

            visible: base.overridden && base.is_enabled

            height: parent.height;
            width: height;

            backgroundColor: hovered ? base.style.controlHighlightColor : base.style.controlColor;

            color: hovered ? UM.Theme.getColor("setting_control_button_hover") : UM.Theme.getColor("setting_control_button")
            iconSource: UM.Theme.getIcon("reset")

            onClicked: {
                base.resetRequested()
                controlContainer.notifyReset();
            }
            MouseArea
            {
                id: resetButtonMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: true
                onEntered:
                {
                    base.showResetTooltip({ x: mouse.mouseX, y: mouse.mouseY })
                }

                onExited:
                {
                    if(controlContainer.item && controlContainer.item.hovered)
                    {
                        return;
                    }

                    base.hovered = false;
                    base.hideTooltip();
                }
            }
        }

        UM.SimpleButton
        {
            // This button shows when the setting has an inherited function, but is overriden by profile.
            id: inheritButton;

            visible: has_profile_value && base.has_inherit_function && base.is_enabled
            height: parent.height;
            width: height;

            onClicked: {
                base.resetToDefaultRequested();
                controlContainer.notifyReset();
            }
            backgroundColor: hovered ? base.style.controlHighlightColor : base.style.controlColor;
            color: hovered ? UM.Theme.getColor("setting_control_button_hover") : UM.Theme.getColor("setting_control_button")
            iconSource: UM.Theme.getIcon("notice");
            MouseArea
            {
                id: inheritanceButtonMouseArea;

                anchors.fill: parent;

                acceptedButtons: Qt.NoButton;
                hoverEnabled: true;

                onEntered: {
                    base.showInheritanceTooltip({ x: mouse.mouseX, y: mouse.mouseY })
                }

                onExited: {
                    if(controlContainer.item && controlContainer.item.hovered) {
                        return;
                    }

                    base.hovered = false;
                    base.hideTooltip();
                }
            }

        }

    }

    Loader {
        id: controlContainer;

        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter;
        width: base.style.controlWidth;
        height: base.style.fixedHeight > 0 ? base.style.fixedHeight : parent.height;
        property variant itemStyle: base.style
        visible: status == Loader.Ready;
        enabled: base.is_enabled

        function notifyReset()
        {
            if(item && item.notifyReset)
            {
                item.notifyReset();
            }
        }

        source:
        {
            switch(base.type)
            {
                case "int":
                    return "SettingTextField.qml"
                case "float":
                    return "SettingTextField.qml"
                case "double":
                    return "SettingTextField.qml"
                case "enum":
                    return "SettingComboBox.qml"
                case "boolean":
                    return "SettingCheckBox.qml"
                case "string":
                    return "SettingTextField.qml"
                default:
                    return "SettingUnknown.qml"
            }
        }

        Connections {
            target: controlContainer.item;
            onValueChanged: {
                base.itemValueChanged(value);
            }
            onHoveredChanged: {
                if(controlContainer.item.hovered) {
                    hoverTimer.start();
                } else {
                    if(!mouse.containsMouse) {
                        hoverTimer.stop();
                        base.hideTooltip();
                    }
                }
            }
        }
    }
}
