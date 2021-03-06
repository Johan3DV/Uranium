// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the AGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

//import ".." as UM
import UM 1.1 as UM

ComboBox
{
    signal valueChanged(string value);
    id: base
    model: options //From parent loader
    textRole: "name";

    MouseArea
    {
        anchors.fill: parent;
        acceptedButtons: Qt.NoButton;
        onWheel: wheel.accepted = true;
    }

    style: ComboBoxStyle {
        background: Rectangle {
            color:
            {
                if (!enabled)
                {
                    return itemStyle.controlDisabledColor
                }
                if(control.hovered || base.activeFocus)
                {
                    return itemStyle.controlHighlightColor
                }
                else
                {
                    return itemStyle.controlColor
                }
            }
            border.width: itemStyle.controlBorderWidth;
            border.color: !enabled ? itemStyle.controlDisabledBorderColor : control.hovered ? itemStyle.controlBorderHighlightColor : itemStyle.controlBorderColor;
        }
        label: Item {
            Label {
                anchors.left: parent.left;
                anchors.leftMargin: itemStyle.controlBorderWidth
                anchors.right: downArrow.left;
                anchors.rightMargin: itemStyle.controlBorderWidth;
                anchors.verticalCenter: parent.verticalCenter;

                text: control.currentText;
                font: itemStyle.controlFont;
                color: !enabled ? itemStyle.controlDisabledTextColor : itemStyle.controlTextColor;

                elide: Text.ElideRight;
                verticalAlignment: Text.AlignVCenter;
            }

            UM.RecolorImage {
                id: downArrow
                anchors.right: parent.right;
                anchors.rightMargin: itemStyle.controlBorderWidth * 2;
                anchors.verticalCenter: parent.verticalCenter;

                source: UM.Theme.getIcon("arrow_bottom")
                width: UM.Theme.getSize("standard_arrow").width
                height: UM.Theme.getSize("standard_arrow").height
                sourceSize.width: width + 5
                sourceSize.height: width + 5

                color: itemStyle.controlTextColor;

            }
        }
    }

    onActivated: {
        valueChanged(options.getItem(index).value);
    }

    onModelChanged: {
        updateCurrentIndex();
    }

    Component.onCompleted: {
        parent.parent.valueChanged.connect(updateCurrentIndex)
    }

    function updateCurrentIndex() {
        if (!options) {
            return;
        }

        for(var i = 0; i < options.rowCount(); ++i) {
            if(options.getItem(i).value == value /*From parent loader*/) {
                currentIndex = i;
                return;
            }
        }

        currentIndex = -1;
    }
}
