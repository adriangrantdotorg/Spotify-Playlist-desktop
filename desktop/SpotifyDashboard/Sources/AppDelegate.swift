import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    var mainWindow: NSWindow!
    var webViewController: MainWindowController!
    var settingsWindowController: SettingsWindowController!
    var statusBarController: StatusBarController?
    var backendManager: BackendManager!
    var hotkeyManager: HotkeyManager!

    private var isMenuBarMode: Bool {
        get { UserDefaults.standard.bool(forKey: "menuBarMode") }
        set { UserDefaults.standard.set(newValue, forKey: "menuBarMode") }
    }

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start the Flask backend
        backendManager = BackendManager()
        backendManager.start()

        // Create the main window
        createMainWindow()

        // Create the web view controller
        webViewController = MainWindowController(window: mainWindow)

        // Set up hotkey manager
        hotkeyManager = HotkeyManager()
        hotkeyManager.delegate = self
        hotkeyManager.loadAndRegisterAll()

        // Set up settings window controller
        settingsWindowController = SettingsWindowController(hotkeyManager: hotkeyManager)
        settingsWindowController.delegate = self

        // Apply Dock/Menu Bar mode
        applyAppMode()

        // Wait for backend to be ready, then load the web view
        backendManager.waitForReady { [weak self] in
            DispatchQueue.main.async {
                self?.webViewController.loadPage(.playlists)
                self?.showWindowOnCurrentScreen()
            }
        }

        // Build the app menu
        buildMenu()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.unregisterAll()
        backendManager.stop()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            showWindowOnCurrentScreen()
        }
        return true
    }

    // MARK: - Window Creation

    private func createMainWindow() {
        let windowRect = NSRect(x: 0, y: 0, width: 900, height: 600)
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]

        mainWindow = NSWindow(
            contentRect: windowRect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        mainWindow.title = "Spotify Dashboard"
        mainWindow.level = .floating
        mainWindow.isReleasedWhenClosed = false
        mainWindow.delegate = self
        mainWindow.titlebarAppearsTransparent = true
        mainWindow.titleVisibility = .hidden
        mainWindow.backgroundColor = NSColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0)

        // Prevent resizing
        mainWindow.minSize = NSSize(width: 900, height: 600)
        mainWindow.maxSize = NSSize(width: 900, height: 600)

        mainWindow.center()
    }

    // MARK: - Window Show/Hide

    func showWindowOnCurrentScreen() {
        // Position on the current active monitor
        if let screen = NSScreen.main ?? NSScreen.screens.first {
            let screenFrame = screen.visibleFrame
            let windowSize = mainWindow.frame.size
            let x = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
            let y = screenFrame.origin.y + (screenFrame.height - windowSize.height) / 2
            mainWindow.setFrameOrigin(NSPoint(x: x, y: y))
        }

        mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hideWindow() {
        mainWindow.orderOut(nil)
    }

    func toggleWindow() {
        if mainWindow.isVisible {
            hideWindow()
        } else {
            showWindowOnCurrentScreen()
        }
    }

    /// Show the window and navigate to a specific page
    func showPage(_ page: DashboardPage) {
        webViewController.loadPage(page)
        showWindowOnCurrentScreen()
    }

    /// Toggle visibility; if showing, navigate to a specific page
    func togglePage(_ page: DashboardPage) {
        if mainWindow.isVisible {
            // If already on this page, hide. Otherwise navigate.
            if webViewController.currentPage == page {
                hideWindow()
            } else {
                webViewController.loadPage(page)
            }
        } else {
            webViewController.loadPage(page)
            showWindowOnCurrentScreen()
        }
    }

    // MARK: - App Mode (Dock vs Menu Bar)

    func applyAppMode() {
        if isMenuBarMode {
            NSApp.setActivationPolicy(.accessory)
            if statusBarController == nil {
                statusBarController = StatusBarController()
                statusBarController?.delegate = self
            }
        } else {
            NSApp.setActivationPolicy(.regular)
            statusBarController?.remove()
            statusBarController = nil
        }
    }

    func setMenuBarMode(_ enabled: Bool) {
        isMenuBarMode = enabled
        applyAppMode()
        if enabled {
            // When switching to menu bar mode, make sure window stays accessible
            showWindowOnCurrentScreen()
        }
    }

    // MARK: - Menu

    private func buildMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Spotify Dashboard", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Hide Spotify Dashboard", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit Spotify Dashboard", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // View menu
        let viewMenuItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Playlists", action: #selector(navigateToPlaylists), keyEquivalent: "1")
        viewMenu.addItem(withTitle: "Tracker", action: #selector(navigateToTracker), keyEquivalent: "2")
        viewMenu.addItem(withTitle: "Queue", action: #selector(navigateToQueue), keyEquivalent: "3")
        viewMenu.addItem(NSMenuItem.separator())
        viewMenu.addItem(withTitle: "Reload Page", action: #selector(reloadPage), keyEquivalent: "r")
        viewMenuItem.submenu = viewMenu
        mainMenu.addItem(viewMenuItem)

        // Window menu
        let windowMenuItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenuItem.submenu = windowMenu
        mainMenu.addItem(windowMenuItem)

        NSApp.mainMenu = mainMenu
    }

    @objc func openSettings() {
        settingsWindowController.showWindow()
    }

    @objc func navigateToPlaylists() {
        showPage(.playlists)
    }

    @objc func navigateToTracker() {
        showPage(.tracker)
    }

    @objc func navigateToQueue() {
        showPage(.queue)
    }

    @objc func reloadPage() {
        webViewController.reload()
    }
}

// MARK: - NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Hide instead of closing so AppleScript can toggle
        hideWindow()
        return false
    }
}

// MARK: - HotkeyManagerDelegate

extension AppDelegate: HotkeyManagerDelegate {
    func hotkeyTriggered(for page: DashboardPage) {
        togglePage(page)
    }
}

// MARK: - SettingsDelegate

extension AppDelegate: SettingsDelegate {
    func settingsDidChangeAppMode(menuBarMode: Bool) {
        setMenuBarMode(menuBarMode)
    }
}

// MARK: - StatusBarDelegate

extension AppDelegate: StatusBarDelegate {
    func statusBarShowPage(_ page: DashboardPage) {
        showPage(page)
    }

    func statusBarOpenSettings() {
        openSettings()
    }

    func statusBarQuit() {
        NSApp.terminate(nil)
    }
}
