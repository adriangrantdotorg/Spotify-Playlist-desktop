import Cocoa

protocol StatusBarDelegate: AnyObject {
    func statusBarShowPage(_ page: DashboardPage)
    func statusBarOpenSettings()
    func statusBarQuit()
}

class StatusBarController {

    private var statusItem: NSStatusItem?
    weak var delegate: StatusBarDelegate?

    init() {
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            // Use the music.note SF Symbol if available, otherwise use a text icon
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "music.note.list", accessibilityDescription: "Spotify Dashboard")
            } else {
                button.title = "SD"
            }
        }

        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        menu.addItem(withTitle: "Playlists", action: #selector(showPlaylists), keyEquivalent: "")
            .target = self
        menu.addItem(withTitle: "Tracker", action: #selector(showTracker), keyEquivalent: "")
            .target = self
        menu.addItem(withTitle: "Queue", action: #selector(showQueue), keyEquivalent: "")
            .target = self

        menu.addItem(NSMenuItem.separator())

        menu.addItem(withTitle: "Settings...", action: #selector(openSettings), keyEquivalent: "")
            .target = self

        menu.addItem(NSMenuItem.separator())

        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
            .target = self

        statusItem?.menu = menu
    }

    func remove() {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }
    }

    // MARK: - Actions

    @objc private func showPlaylists() {
        delegate?.statusBarShowPage(.playlists)
    }

    @objc private func showTracker() {
        delegate?.statusBarShowPage(.tracker)
    }

    @objc private func showQueue() {
        delegate?.statusBarShowPage(.queue)
    }

    @objc private func openSettings() {
        delegate?.statusBarOpenSettings()
    }

    @objc private func quit() {
        delegate?.statusBarQuit()
    }
}
