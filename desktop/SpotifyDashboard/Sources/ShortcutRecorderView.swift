import Cocoa
import Carbon

/// A custom view that records keyboard shortcuts
/// Click to start recording, press a key combination, it captures it.
class ShortcutRecorderView: NSView {

    var onShortcutRecorded: ((_ keyCode: UInt32, _ modifiers: UInt32, _ displayString: String) -> Void)?

    private var isRecording = false
    private var displayString: String = "Click to record"
    private var hasShortcut = false

    private let textColor = NSColor.white
    private let recordingColor = NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
    private let bgColor = NSColor(white: 0.15, alpha: 1.0)
    private let borderColor = NSColor(white: 0.3, alpha: 1.0)
    private let recordingBorderColor = NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.8)

    override var acceptsFirstResponder: Bool { true }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 200, height: 28)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTrackingArea()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTrackingArea()
    }

    private func setupTrackingArea() {
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }

    /// Set the displayed shortcut text (e.g., from a loaded binding)
    func setDisplayString(_ string: String) {
        displayString = string
        hasShortcut = true
        needsDisplay = true
    }

    /// Clear the displayed shortcut
    func clearShortcut() {
        displayString = "Click to record"
        hasShortcut = false
        isRecording = false
        needsDisplay = true
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: 6, yRadius: 6)

        // Background
        bgColor.setFill()
        path.fill()

        // Border
        if isRecording {
            recordingBorderColor.setStroke()
        } else {
            borderColor.setStroke()
        }
        path.lineWidth = 1.5
        path.stroke()

        // Text
        let font = NSFont.systemFont(ofSize: 13, weight: .medium)
        let color = isRecording ? recordingColor : (hasShortcut ? textColor : NSColor.secondaryLabelColor)
        let text = isRecording ? "Press shortcut..." : displayString

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]

        let attrStr = NSAttributedString(string: text, attributes: attrs)
        let textSize = attrStr.size()
        let textRect = NSRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        attrStr.draw(in: textRect)
    }

    // MARK: - Mouse Events

    override func mouseDown(with event: NSEvent) {
        if isRecording {
            // Click again to cancel recording
            isRecording = false
            if !hasShortcut {
                displayString = "Click to record"
            }
        } else {
            isRecording = true
            window?.makeFirstResponder(self)
        }
        needsDisplay = true
    }

    // MARK: - Key Events

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        // Require at least one modifier key
        let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
        guard !modifiers.isEmpty else {
            // Escape cancels recording
            if event.keyCode == 53 { // Escape key
                isRecording = false
                if !hasShortcut {
                    displayString = "Click to record"
                }
                needsDisplay = true
            }
            return
        }

        let keyCode = UInt32(event.keyCode)
        let carbonModifiers = HotkeyManager.cocoaToCarbonModifiers(modifiers)

        // Build display string
        var parts: [String] = []
        if modifiers.contains(.command) { parts.append("\u{2318}") }
        if modifiers.contains(.option) { parts.append("\u{2325}") }
        if modifiers.contains(.control) { parts.append("\u{2303}") }
        if modifiers.contains(.shift) { parts.append("\u{21E7}") }
        parts.append(HotkeyManager.keyCodeToString(keyCode))
        let display = parts.joined()

        displayString = display
        hasShortcut = true
        isRecording = false
        needsDisplay = true

        onShortcutRecorded?(keyCode, carbonModifiers, display)
    }

    override func flagsChanged(with event: NSEvent) {
        // Don't call super to prevent beep on modifier-only press
        if !isRecording {
            super.flagsChanged(with: event)
        }
    }
}
