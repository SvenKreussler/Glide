//
//  EventHandling.swift
//  glide
//
//  Ported from https://www.dribin.org/dave/software/#ddhidlib
//
//  Copyright (c) 2019 cocoatoucher user on github.com (https://github.com/cocoatoucher/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import IOKit

internal protocol USBGameControllerDeviceDelegate: class {
    func deviceXAxisStickValueChanged(_ device: USBGameController.Device, value: Int, stickIndex: Int)
    func deviceYAxisStickValueChanged(_ device: USBGameController.Device, value: Int, stickIndex: Int)
    func deviceOtherAxisStickValueChanged(_ device: USBGameController.Device, value: Int, stickIndex: Int, otherAxisIndex: Int)
    func devicePovAxisStickValueChanged(_ device: USBGameController.Device, value: Int, stickIndex: Int, povNumber: Int)
    
    func deviceDidPressButton(_ device: USBGameController.Device, buttonIndex: Int)
    func deviceDidReleaseButton(_ device: USBGameController.Device, buttonIndex: Int)
}

extension USBGameController.Device: USBGameControllerEventQueueDelegate {
    
    func queueDidReceiveEvents(_ queue: EventQueue) {
        while case let e = queue.nextEvent, let event = e {
            parseValueFromEvent(event)
        }
    }
    
    private func parseValueFromEvent(_ event: EventQueue.Event) {
        let cookie = event.elementCookie
        let value = event.value

        if let xAxisStick = stickForXAxis(withCookie: cookie) {
            let normalizedValue = xAxisStick.element.normalizedValue(from: Int(value))

            delegate?.deviceXAxisStickValueChanged(self, value: normalizedValue, stickIndex: xAxisStick.stickIndex)
        } else if let yAxisStick = stickForYAxis(withCookie: cookie) {
            let normalizedValue = yAxisStick.element.normalizedValue(from: Int(value))

            delegate?.deviceYAxisStickValueChanged(self, value: normalizedValue, stickIndex: yAxisStick.stickIndex)
        } else if let otherAxisStick = stickForOtherAxis(withCookie: cookie) {
            let normalizedValue = otherAxisStick.element.normalizedValue(from: Int(value))

            delegate?.deviceOtherAxisStickValueChanged(self, value: normalizedValue, stickIndex: otherAxisStick.stickIndex, otherAxisIndex: otherAxisStick.axis)
        } else if let povStick = stickForPOVNumber(withCookie: cookie) {
            let normalizedValue = povStick.element.normalizedValue(from: Int(value))

            delegate?.devicePovAxisStickValueChanged(self, value: normalizedValue, stickIndex: povStick.stickIndex, povNumber: povStick.povNumber)
        } else {
            let buttonIndex = buttons.firstIndex { cookie == $0.cookie } ?? 0

            if value == 1 {
                delegate?.deviceDidPressButton(self, buttonIndex: buttonIndex)
            } else if value == 0 {
                delegate?.deviceDidReleaseButton(self, buttonIndex: buttonIndex)
            } else {
                let element = elementsByCookie[UInt(event.elementCookie)]
                print("Element not found \(element)")
            }
        }
    }

    private func stickForXAxis(withCookie cookie: IOHIDElementCookie) -> (stickIndex: Int, element: Element)? {
        for (index, stick) in sticks.enumerated() {
            if let xAxisElement = stick.xAxisElement, xAxisElement.cookie == cookie {
                return (stickIndex: index, element: xAxisElement)
            }
        }
        return nil
    }

    private func stickForYAxis(withCookie cookie: IOHIDElementCookie) -> (stickIndex: Int, element: Element)? {
        for (index, stick) in sticks.enumerated() {
            if let yAxisElement = stick.yAxisElement, yAxisElement.cookie == cookie {
                return (stickIndex: index, element: yAxisElement)
            }
        }
        return nil
    }

    private func stickForOtherAxis(withCookie cookie: IOHIDElementCookie) -> (stickIndex: Int, element: Element, axis: Int)? {
        for (index, stick) in sticks.enumerated() {
            for (stickElementIndex, stickElement) in stick.stickElements.enumerated() where stickElement.cookie == cookie {
                return (stickIndex: index, element: stickElement, axis: stickElementIndex)
            }
        }
        return nil
    }

    private func stickForPOVNumber(withCookie cookie: IOHIDElementCookie) -> (stickIndex: Int, element: Element, povNumber: Int)? {
        for (index, stick) in sticks.enumerated() {
            for (povElementIndex, povElement) in stick.povElements.enumerated() where povElement.cookie == cookie {
                return (stickIndex: index, element: povElement, povNumber: povElementIndex)
            }
        }
        return nil
    }
}
