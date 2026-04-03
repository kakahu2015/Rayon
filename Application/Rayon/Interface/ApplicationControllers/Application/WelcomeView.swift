//
//  WelcomeView.swift
//  Rayon
//
//  Created by Lakr Aream on 2022/2/9.
//

import Colorful
import NSRemoteShell
import RayonModule
import SwiftUI
import WebKit

let defaultOpenClawURL = "https://openclaw.kakahu.org"
let defaultCFSSHURL = "https://ssh.kakahu.org"

struct WelcomeView: View {
    @EnvironmentObject var store: RayonStore

    @AppStorage("launcher.managementURL") private var managementURL: String = defaultOpenClawURL
    @State private var managementInput: String = ""
    @State private var preparedManagementURL: String = defaultOpenClawURL
    @State private var managementActive: Bool = false

    @State var quickConnect: String = ""
    @FocusState private var textFieldIsFocused: Bool
    @State var buttonDisabled: Bool = true
    @State var suggestion: String? = nil

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
            VStack(alignment: .leading, spacing: 20) {
                launcherHero

                launcherRouteCard(
                    eyebrow: "Web Route",
                    title: "Cloudflare Tunnel SSH",
                    subtitle: "Open the Cloudflare Tunnel protected Web SSH endpoint in the embedded browser.",
                    systemImage: "lock.shield",
                    tint: .mint
                ) {
                    NavigationLink {
                        BrowserContainerView(title: "Cloudflare Tunnel SSH", urlString: defaultCFSSHURL)
                    } label: {
                        Label("Open Tunnel SSH", systemImage: "terminal")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.mint)
                }

                launcherRouteCard(
                    eyebrow: "Native Route",
                    title: "Native SSH",
                    subtitle: "Quick connect to saved machines or paste an SSH command directly.",
                    systemImage: "bolt.horizontal.circle",
                    tint: .blue
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            TextField("ssh root@www.example.com -p 22 ↵", text: $quickConnect)
                                .textFieldStyle(PlainTextFieldStyle())
                                .disableAutocorrection(true)
                                .focused($textFieldIsFocused)
                                .font(.system(.headline, design: .rounded))
                                .padding(6)
                                .background(
                                    Rectangle()
                                        .foregroundColor(Color(.black).opacity(0.08))
                                        .cornerRadius(6)
                                )
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

                            Button {
                                beginQuickConnect()
                            } label: {
                                Circle()
                                    .foregroundColor(.accentColor)
                                    .overlay(
                                        Image(systemName: "arrow.forward")
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                    )
                                    .frame(width: 34, height: 34)
                            }
                            .disabled(buttonDisabled)
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxWidth: 520)

                        if let suggestion {
                            suggestionButton
                                .transition(.offset(x: 0, y: 8).combined(with: .opacity))
                        }

                        Toggle("Record Command", isOn: $store.saveTemporarySession)
                            .font(.system(.subheadline, design: .rounded))

                        NavigationLink {
                            SettingView().requiresFrame()
                        } label: {
                            Label("Advanced Settings", systemImage: "gearshape")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }

                launcherActionCard(
                    title: "Ready to Launch",
                    subtitle: "OpenClaw URL is editable, normalized to https when needed, and remembered automatically.",
                    systemImage: "checkmark.shield"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            launcherStatusPill(title: "Saved", systemImage: "externaldrive.fill.badge.checkmark")
                            launcherStatusPill(title: "Auto HTTPS", systemImage: "lock.rotation")
                            launcherStatusPill(title: "Persistent", systemImage: "memorychip")
                        }

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
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 56)
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
                    .opacity(0.22)
                }
            }
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.mint.opacity(0.18))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: 40, y: -20)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(Color.blue.opacity(0.16))
                .frame(width: 220, height: 220)
                .blur(radius: 48)
                .offset(x: -50, y: 40)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            Text(version)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .opacity(0.45)
                .padding(.bottom, 16)
        }
        .background(
            NavigationLink(
                destination: BrowserContainerView(title: "OpenClaw", urlString: preparedManagementURL),
                isActive: $managementActive
            ) {
                EmptyView()
            }
            .hidden()
        )
    }

    private var launcherHero: some View {
        launcherActionCard(
            title: "OpenClaw Gateway",
            subtitle: "A focused Launcher that blends OpenClaw, Cloudflare Tunnel, and native SSH controls."
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.mint.opacity(0.3))
                            .frame(width: 76, height: 76)
                            .blur(radius: 12)
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.95), .mint.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                        Image(systemName: "network")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 66, height: 66)
                    .shadow(color: .mint.opacity(0.35), radius: 18, x: 0, y: 10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Launcher")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        Text("OpenClaw, Tunnel SSH, and native controls in a single mac launcher.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    launcherStatusPill(title: "Mac Ready", systemImage: "macwindow")
                    launcherStatusPill(title: "Layered UI", systemImage: "square.stack.3d.up.fill")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("OpenClaw URL")
                        .font(.system(.headline, design: .rounded))

                    TextField("https://example.com", text: $managementInput)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.08))
                        )
                        .onChange(of: managementInput) { newValue in
                            managementURL = newValue
                        }
                        .onSubmit {
                            openManagementURL()
                        }

                    Text("Examples: openclaw.example.com or a full https://... URL")
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
            }
        }
    }

    @ViewBuilder
    private func launcherRouteCard<Content: View>(
        eyebrow: String,
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        launcherActionCard(title: title, subtitle: subtitle, systemImage: systemImage) {
            VStack(alignment: .leading, spacing: 12) {
                Text(eyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(tint.opacity(0.14))
                    )

                content()
            }
        }
    }

    @ViewBuilder
    private func launcherActionCard<Content: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.system(.title3, design: .rounded).weight(.semibold))
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
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }

    private func launcherStatusPill(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundColor(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.14))
            )
    }

    private var suggestionButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                quickConnect = suggestion ?? quickConnect
            }
        }) {
            HStack {
                Text("Did you mean \"\(suggestion!)\"?")
                Text("⌘⏎")
            }
            .font(.system(.footnote, design: .rounded))
            .padding(6)
            .background(
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.1))
                    .cornerRadius(4)
            )
        }
        .buttonStyle(BorderlessButtonStyle())
        .overlay(
            Button(action: {
                withAnimation(.spring()) {
                    quickConnect = suggestion ?? quickConnect
                }
            }) {
                Text("")
            }
            .offset(x: 0, y: 999_999)
            .keyboardShortcut(.return, modifiers: .command)
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
        TerminalManager.shared.createSession(withCommand: command)
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

private struct EmbeddedWebView: NSViewRepresentable {
    let urlString: String

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        load(urlString, into: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
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
