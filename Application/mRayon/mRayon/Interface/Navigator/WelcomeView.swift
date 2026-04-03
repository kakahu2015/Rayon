//
//  WelcomeView.swift
//  mRayon
//
//  Created by Lakr Aream on 2022/3/2.
//

import Colorful
import RayonModule
import SwiftUI
import WebKit

private var importData: Data?
let defaultOpenClawURL = "https://openclaw.kakahu.org"
let defaultCFSSHURL = "https://ssh.kakahu.org"

struct WelcomeView: View {
    @EnvironmentObject var store: RayonStore

    @AppStorage("launcher.managementURL") private var managementURL: String = defaultOpenClawURL
    @State private var managementInput: String = ""
    @State private var preparedManagementURL: String = defaultOpenClawURL
    @State private var managementActive: Bool = false

    private var version: String {
        var ret = "Version: " +
            (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            + " Build: " +
            (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
        #if DEBUG
            ret += " DEBUG"
        #endif
        return ret
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                launcherHero

                HStack(alignment: .top, spacing: 14) {
                    launcherActionCard(
                        title: "CF SSH",
                        subtitle: "Open the Cloudflare Access protected Web SSH endpoint in the embedded browser.",
                        systemImage: "lock.shield"
                    ) {
                        NavigationLink {
                            BrowserContainerView(title: "CF SSH", urlString: defaultCFSSHURL)
                        } label: {
                            Label("Open Web SSH", systemImage: "terminal")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.mint)
                    }

                    launcherActionCard(
                        title: "Native SSH",
                        subtitle: "Jump to the original native entry with quick connect and animated background.",
                        systemImage: "bolt.horizontal.circle"
                    ) {
                        NavigationLink {
                            NativeSSHConnectView()
                        } label: {
                            Label("Enter Native SSH", systemImage: "chevron.right.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                launcherActionCard(
                    title: "Quick Notes",
                    subtitle: "OpenClaw URL is editable, normalized to https when needed, and remembered automatically for later launches.",
                    systemImage: "checkmark.shield"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Saved destination", systemImage: "link")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundColor(.secondary)

                        Text(normalizedURL(from: managementURL))
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Launcher")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if managementInput.isEmpty {
                managementInput = managementURL
            }
        }
        .background(
            Group {
                if !store.reducedViewEffects {
                    StarLinkView().ignoresSafeArea()
                }
            }
        )
        .background(
            Group {
                if !store.reducedViewEffects {
                    ColorfulView(
                        colors: [Color.accentColor, .mint, .blue],
                        colorCount: 10
                    )
                    .ignoresSafeArea()
                    .opacity(0.2)
                }
            }
        )
        .overlay(alignment: .bottom) {
            Text(version)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .opacity(0.45)
                .padding(.bottom, 18)
        }
    }

    private var launcherHero: some View {
        launcherActionCard(
            title: "OpenClaw Gateway",
            subtitle: "Bring back the layered native-style landing page, then jump into your management URL from here."
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.85), .mint.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Image(systemName: "network")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 58, height: 58)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Launcher")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                        Text("A richer entry page for OpenClaw, Web SSH, and native controls.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("OpenClaw URL")
                        .font(.system(.headline, design: .rounded))

                    TextField("https://example.com", text: $managementInput)
                        .textFieldStyle(.plain)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.12))
                        )
                        .onChange(of: managementInput) { newValue in
                            managementURL = newValue
                        }
                        .onSubmit {
                            openManagementURL()
                        }

                    Text("Examples: `openclaw.example.com` or a full `https://...` URL.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 10) {
                    Button {
                        openManagementURL()
                    } label: {
                        Label("Open OpenClaw", systemImage: "arrow.up.forward.app")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        managementInput = defaultOpenClawURL
                        managementURL = defaultOpenClawURL
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                NavigationLink(
                    destination: BrowserContainerView(title: "OpenClaw", urlString: preparedManagementURL),
                    isActive: $managementActive
                ) {
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private func launcherActionCard<Content: View>(
        title: String,
        subtitle: String,
        systemImage: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let systemImage {
                Label(title, systemImage: systemImage)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
            } else {
                Text(title)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
            }
            Text(subtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func normalizedURL(from value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return defaultOpenClawURL }
        if trimmed.contains("://") { return trimmed }
        return "https://" + trimmed
    }

    private func openManagementURL() {
        let normalized = normalizedURL(from: managementInput)
        managementInput = normalized
        managementURL = normalized
        preparedManagementURL = normalized
        managementActive = true
    }
}

private struct BrowserContainerView: View {
    let title: String
    let urlString: String

    var body: some View {
        EmbeddedWebView(urlString: urlString)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
    }
}

private struct EmbeddedWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .interactive
        load(urlString, into: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let current = webView.url?.absoluteString else {
            load(urlString, into: webView)
            return
        }
        if current != urlString {
            load(urlString, into: webView)
        }
    }

    private func load(_ value: String, into webView: WKWebView) {
        guard let url = URL(string: value) else { return }
        webView.load(URLRequest(url: url))
    }
}

struct NativeSSHConnectView: View {
    @EnvironmentObject var store: RayonStore

    @State var quickConnect: String = ""
    @FocusState var textFieldIsFocused: Bool
    @State var buttonDisabled: Bool = true
    @State var suggestion: String? = nil

    var version: String {
        var ret = "Version: " +
            (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            + " Build: " +
            (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
        #if DEBUG
            ret += " DEBUG"
        #endif
        return ret
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image("Avatar")
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)

            Text("Quick Connect (Identity Requires Auto Auth)")
                .font(.system(.headline, design: .rounded))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    TextField("ssh root@www.example.com -p 22 ↵", text: $quickConnect)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($textFieldIsFocused)
                        .font(.system(.headline, design: .rounded))
                        .onChange(of: quickConnect, perform: { newValue in
                            if newValue.hasPrefix("ssh ssh ") {
                                quickConnect.removeFirst("ssh ".count)
                            }
                            buttonDisabled = SSHCommandReader(command: newValue) == nil
                            refreshSuggestion()
                        })
                        .onChange(of: textFieldIsFocused, perform: { newValue in
                            if newValue, quickConnect.isEmpty {
                                quickConnect = "ssh "
                            }
                        })
                        .onSubmit {
                            beginQuickConnect()
                        }
                        .padding(6)
                        .background(
                            Rectangle()
                                .foregroundColor(.black.opacity(0.1))
                                .cornerRadius(4)
                        )
                }
                .frame(maxWidth: 400)

                if suggestion != nil {
                    suggestionButton
                        .transition(.offset(x: 0, y: 10).combined(with: .opacity))
                }
            }

            Button {
                beginQuickConnect()
            } label: {
                Circle()
                    .foregroundColor(.accentColor)
                    .overlay(
                        Image(systemName: "arrow.forward")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    )
                    .frame(width: 45, height: 45)
            }
            .disabled(buttonDisabled)
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)
            .onLongPressGesture {
                print("importer called")
                guard let paste = UIPasteboard
                    .general
                    .string?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                else {
                    return
                }
                if let data = importData {
                    let key = paste
                    print("import key ready, trying import")
                    importData = nil
                    RayonStore.overrideImport(from: data, key: key)
                } else {
                    guard let data = Data(base64Encoded: paste) else {
                        return
                    }
                    importData = data
                    print("import data ready, requires key")
                }
            }
            Spacer()
                .frame(height: 40)
        }
        .navigationTitle("Native SSH")
        .padding()
        .expended()
        .background(
            Group {
                if !store.reducedViewEffects {
                    StarLinkView().ignoresSafeArea()
                }
            }
        )
        .background(
            Group {
                if !store.reducedViewEffects {
                    ColorfulView(
                        colors: [Color.accentColor],
                        colorCount: 16
                    )
                    .ignoresSafeArea()
                    .opacity(0.25)
                }
            }
        )
        .overlay(
            VStack {
                Spacer()
                Text(version)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .opacity(0.5)
                Spacer()
                    .frame(height: 20)
            }
        )
    }

    private var suggestionButton: some View {
        func fillSuggestion() {
            withAnimation(.spring()) {
                quickConnect = suggestion ?? quickConnect
            }
        }

        return Button(action: {
            fillSuggestion()
        }) {
            HStack {
                Text("Did you mean \"\(suggestion!)\"?")
                    .foregroundColor(.white)
                    .font(.system(.headline, design: .rounded))
            }
            .padding(6)
            .background(
                Rectangle()
                    .foregroundColor(.accentColor)
                    .cornerRadius(4)
            )
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    private func refreshSuggestion() {
        let matchedCommands = store.recentRecord.lazy.map { connection -> String in
            connection.equivalentSSHCommand
        }.filter { command in
            command.hasPrefix(quickConnect) && command != quickConnect
        }

        withAnimation(.spring(response: 0.35)) {
            suggestion = quickConnect.count > 4 ? matchedCommands.first : nil
        }
    }

    private func beginQuickConnect() {
        guard let command = SSHCommandReader(command: quickConnect) else {
            return
        }
        TerminalManager.shared.begin(for: command)
    }
}

struct JustWelcomeView: View {
    var body: some View {
        WelcomeView()
    }
}
