import Cocoa
import Carbon

protocol HotkeyManagerDelegate: AnyObject {
    func hotkeyTriggered(for page: DashboardPage)
}

/// Represents a saved keyboard shortcut
struct HotkeyBinding: Codable {
    let keyCode: UInt32
    let modifiers: UInt32
    let page: String

    var displayString: String {
        var parts: [String] = []
        if modifiers & UInt32(cmdKey) != 0 { parts.append("\u{2318}") }        // Cmd
        if modifiers & UInt32(optionKey) != 0 { parts.append("\u{2325}") }     // Option
        if modifiers & UInt32(controlKey) != 0 { parts.append("\u{2303}") }    // Control
        if modifiers & UInt32(shiftKey) != 0 { parts.append("\u{21E7}") }      // Shift

        let keyName = HotkeyManager.keyCodeToString(keyCode)
        parts.append(keyName)
        return parts.joined()
    }
}

class HotkeyManager {

    weak var delegate: HotkeyManagerDelegate?

    private var registeredHotkeys: [DashboardPage: EventHotKeyRef] = [:]
    private var bindings: [DashboardPage: HotkeyBinding] = [:]

    // Map from hotkey ID to page for dispatch
    private var hotkeyIDToPage: [UInt32: DashboardPage] = [:]

    // Unique signature for our app's hotkeys
    private let appSignature: OSType = 0x53504448 // "SPDH"
    private var nextHotkeyID: UInt32 = 1

    // Static reference for the C callback
    private static var shared: HotkeyManager?

    init() {
        HotkeyManager.shared = self
        installEventHandler()
    }

    // MARK: - Event Handler Installation

    private var eventHandlerRef: EventHandlerRef?

    private func installEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                guard let event = event else { return OSStatus(eventNotHandledErr) }

                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    UInt32(kEventParamDirectObject),
                    UInt32(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard status == noErr else { return status }

                // Dispatch to the correct page based on hotkey ID
                if let manager = HotkeyManager.shared,
                   let page = manager.hotkeyIDToPage[hotKeyID.id] {
                    manager.delegate?.hotkeyTriggered(for: page)
                    return noErr
                }

                return OSStatus(eventNotHandledErr)
            },
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )

        if status != noErr {
            print("[HotkeyManager] Failed to install event handler: \(status)")
        }
    }

    // MARK: - Registration

    func register(page: DashboardPage, keyCode: UInt32, modifiers: UInt32) {
        // Unregister existing hotkey for this page
        unregister(page: page)

        let binding = HotkeyBinding(keyCode: keyCode, modifiers: modifiers, page: page.rawValue)
        bindings[page] = binding

        var hotKeyRef: EventHotKeyRef?
        let currentID = nextHotkeyID
        let hotkeyID = EventHotKeyID(signature: appSignature, id: currentID)
        nextHotkeyID += 1

        // Convert Cocoa modifiers to Carbon modifiers (already in Carbon format from recorder)
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr, let ref = hotKeyRef {
            registeredHotkeys[page] = ref
            hotkeyIDToPage[currentID] = page
            print("[HotkeyManager] Registered hotkey for \(page.displayName): \(binding.displayString)")
        } else {
            print("[HotkeyManager] Failed to register hotkey: \(status)")
        }

        saveBindings()
    }

    func unregister(page: DashboardPage) {
        if let ref = registeredHotkeys[page] {
            UnregisterEventHotKey(ref)
            registeredHotkeys.removeValue(forKey: page)
        }
        bindings.removeValue(forKey: page)
        saveBindings()
    }

    func unregisterAll() {
        for (_, ref) in registeredHotkeys {
            UnregisterEventHotKey(ref)
        }
        registeredHotkeys.removeAll()
    }

    func binding(for page: DashboardPage) -> HotkeyBinding? {
        return bindings[page]
    }

    // MARK: - Persistence

    private func saveBindings() {
        let encoder = JSONEncoder()
        var dict: [String: Data] = [:]
        for (page, binding) in bindings {
            if let data = try? encoder.encode(binding) {
                dict[page.rawValue] = data
            }
        }
        UserDefaults.standard.set(dict, forKey: "hotkeyBindings")
    }

    func loadAndRegisterAll() {
        guard let dict = UserDefaults.standard.dictionary(forKey: "hotkeyBindings") as? [String: Data] else {
            return
        }

        let decoder = JSONDecoder()
        for (pageStr, data) in dict {
            guard let page = DashboardPage(rawValue: pageStr),
                  let binding = try? decoder.decode(HotkeyBinding.self, from: data) else {
                continue
            }
            bindings[page] = binding

            var hotKeyRef: EventHotKeyRef?
            let currentID = nextHotkeyID
            let hotkeyID = EventHotKeyID(signature: appSignature, id: currentID)
            nextHotkeyID += 1

            let status = RegisterEventHotKey(
                binding.keyCode,
                binding.modifiers,
                hotkeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )

            if status == noErr, let ref = hotKeyRef {
                registeredHotkeys[page] = ref
                hotkeyIDToPage[currentID] = page
                print("[HotkeyManager] Loaded hotkey for \(page.displayName): \(binding.displayString)")
            }
        }
    }

    // MARK: - Key Code Utilities

    /// Convert a Carbon key code to a human-readable string
    static func keyCodeToString(_ keyCode: UInt32) -> String {
        let mapping: [UInt32: String] = [
            0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H",
            0x05: "G", 0x06: "Z", 0x07: "X", 0x08: "C", 0x09: "V",
            0x0B: "B", 0x0C: "Q", 0x0D: "W", 0x0E: "E", 0x0F: "R",
            0x10: "Y", 0x11: "T", 0x12: "1", 0x13: "2", 0x14: "3",
            0x15: "4", 0x16: "6", 0x17: "5", 0x18: "=", 0x19: "9",
            0x1A: "7", 0x1B: "-", 0x1C: "8", 0x1D: "0", 0x1E: "]",
            0x1F: "O", 0x20: "U", 0x21: "[", 0x22: "I", 0x23: "P",
            0x25: "L", 0x26: "J", 0x27: "'", 0x28: "K", 0x29: ";",
            0x2A: "\\", 0x2B: ",", 0x2C: "/", 0x2D: "N", 0x2E: "M",
            0x2F: ".", 0x30: "Tab", 0x31: "Space", 0x32: "`",
            0x33: "Delete", 0x24: "Return", 0x35: "Escape",
            0x60: "F5", 0x61: "F6", 0x62: "F7", 0x63: "F3",
            0x64: "F8", 0x65: "F9", 0x67: "F11", 0x69: "F13",
            0x6B: "F14", 0x6D: "F10", 0x6F: "F12", 0x71: "F15",
            0x72: "Help", 0x73: "Home", 0x74: "PageUp", 0x75: "FwdDel",
            0x76: "F4", 0x77: "End", 0x78: "F2", 0x79: "PageDown",
            0x7A: "F1", 0x7B: "Left", 0x7C: "Right", 0x7D: "Down",
            0x7E: "Up",
        ]
        return mapping[keyCode] ?? "Key\(keyCode)"
    }

    /// Convert NSEvent modifier flags to Carbon modifier mask
    static func cocoaToCarbonModifiers(_ flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbonMods: UInt32 = 0
        if flags.contains(.command) { carbonMods |= UInt32(cmdKey) }
        if flags.contains(.option) { carbonMods |= UInt32(optionKey) }
        if flags.contains(.control) { carbonMods |= UInt32(controlKey) }
        if flags.contains(.shift) { carbonMods |= UInt32(shiftKey) }
        return carbonMods
    }
}
