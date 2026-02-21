import Foundation

class BackendManager {

    private var process: Process?
    private let port: Int = 8888
    private let healthURL: URL

    /// Path to the project root (where app.py lives)
    private let projectRoot: String

    init() {
        self.healthURL = URL(string: "http://127.0.0.1:\(port)/health")!

        // Determine project root:
        // 1. Check SPOTIFY_DASHBOARD_PATH environment variable
        // 2. Fall back to the directory containing the .app bundle's grandparent
        // 3. Fall back to current working directory
        if let envPath = ProcessInfo.processInfo.environment["SPOTIFY_DASHBOARD_PATH"] {
            self.projectRoot = envPath
        } else {
            // The app is expected to be at: <project>/desktop/SpotifyDashboard/build/SpotifyDashboard.app
            // So project root is 4 levels up from the .app bundle
            let bundlePath = Bundle.main.bundlePath
            let bundleURL = URL(fileURLWithPath: bundlePath)
            let candidate = bundleURL
                .deletingLastPathComponent() // build/
                .deletingLastPathComponent() // SpotifyDashboard/
                .deletingLastPathComponent() // desktop/
            let appPyPath = candidate.appendingPathComponent("app.py").path

            if FileManager.default.fileExists(atPath: appPyPath) {
                self.projectRoot = candidate.path
            } else {
                // Try current working directory
                let cwd = FileManager.default.currentDirectoryPath
                let cwdAppPy = URL(fileURLWithPath: cwd).appendingPathComponent("app.py").path
                if FileManager.default.fileExists(atPath: cwdAppPy) {
                    self.projectRoot = cwd
                } else {
                    // Last resort: go up from bundle until we find app.py
                    var searchURL = bundleURL
                    for _ in 0..<8 {
                        searchURL = searchURL.deletingLastPathComponent()
                        let testPath = searchURL.appendingPathComponent("app.py").path
                        if FileManager.default.fileExists(atPath: testPath) {
                            self.projectRoot = searchURL.path
                            return
                        }
                    }
                    self.projectRoot = cwd
                }
            }
        }
    }

    /// Start the Flask backend as a subprocess
    func start() {
        // Check if backend is already running
        if isBackendRunning() {
            print("[BackendManager] Backend already running on port \(port)")
            return
        }

        let appPyPath = URL(fileURLWithPath: projectRoot).appendingPathComponent("app.py").path
        guard FileManager.default.fileExists(atPath: appPyPath) else {
            print("[BackendManager] ERROR: app.py not found at \(appPyPath)")
            return
        }

        print("[BackendManager] Starting Flask backend from: \(projectRoot)")

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = ["python3", "app.py"]
        proc.currentDirectoryURL = URL(fileURLWithPath: projectRoot)

        // Inherit environment (for .env variables via python-dotenv)
        var env = ProcessInfo.processInfo.environment
        env["PYTHONUNBUFFERED"] = "1"
        proc.environment = env

        // Pipe stdout/stderr for debugging
        let outputPipe = Pipe()
        proc.standardOutput = outputPipe
        proc.standardError = outputPipe

        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                print("[Flask] \(str)", terminator: "")
            }
        }

        proc.terminationHandler = { process in
            print("[BackendManager] Flask process terminated with status: \(process.terminationStatus)")
        }

        do {
            try proc.run()
            self.process = proc
            print("[BackendManager] Flask process started (PID: \(proc.processIdentifier))")
        } catch {
            print("[BackendManager] Failed to start Flask: \(error)")
        }
    }

    /// Stop the Flask backend
    func stop() {
        guard let proc = process, proc.isRunning else { return }
        print("[BackendManager] Stopping Flask backend...")
        proc.terminate()

        // Give it a moment to shut down gracefully
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            if proc.isRunning {
                proc.interrupt()
            }
        }
        process = nil
    }

    /// Check if the backend is responding
    func isBackendRunning() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isRunning = false

        var request = URLRequest(url: healthURL)
        request.timeoutInterval = 1.0

        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse,
               (200...399).contains(httpResponse.statusCode) {
                isRunning = true
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return isRunning
    }

    /// Wait for the backend to become ready, then call the completion handler
    func waitForReady(completion: @escaping () -> Void) {
        waitForReady(progress: nil, completion: completion)
    }

    /// Wait for the backend with progress reporting.
    /// Progress callback is called on a background thread with values 0.0–1.0.
    func waitForReady(progress: ((Double) -> Void)?, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let pollInterval: TimeInterval = 0.5
            let maxAttempts = 40  // 40 × 0.5s = 20s max wait
            let expectedReadyAttempt: Double = 10 // Expect ~5s typical startup

            for attempt in 1...maxAttempts {
                // Report estimated progress (asymptotic curve so it never quite hits 1.0)
                let raw = Double(attempt) / expectedReadyAttempt
                let estimated = min(raw / (1.0 + raw * 0.3), 0.95)
                progress?(estimated)

                if self.isBackendRunning() {
                    print("[BackendManager] Backend ready after \(attempt) attempt(s) (\(Double(attempt) * pollInterval)s)")
                    progress?(1.0)
                    completion()
                    return
                }
                Thread.sleep(forTimeInterval: pollInterval)
            }

            print("[BackendManager] WARNING: Backend did not become ready after \(Double(maxAttempts) * pollInterval)s")
            progress?(1.0)
            // Load anyway - the WebView will show an error and can retry
            completion()
        }
    }
}
