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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                launcherHero

                launcherRouteCard(
                    eyebrow: "Cloudflare Route",
                    title: "Cloudflare Tunnel SSH",
                    subtitle: "Open the Cloudflare Tunnel SSH entry inside the embedded browser.",
                    systemImage: "lock.shield",
                    tint: .mint,
                    highlights: ["Tunnel Protected", "Embedded Browser"]
                ) {
                    NavigationLink {
                        BrowserContainerView(title: "Cloudflare Tunnel SSH", urlString: defaultCFSSHURL)
                    } label: {
                        launcherRouteButtonLabel(
                            title: "Open Cloudflare Tunnel SSH",
                            systemImage: "arrow.up.forward.app"
                        )
                    }
                    .buttonStyle(.plain)
                }

                launcherRouteCard(
                    eyebrow: "Native Route",
                    title: "Native SSH",
                    subtitle: "Jump into the original native flow with quick connect, suggestions, and the animated shell background.",
                    systemImage: "bolt.horizontal.circle",
                    tint: .blue,
                    highlights: ["Quick Connect", "Suggestions"]
                ) {
                    NavigationLink {
                        NativeSSHConnectView()
                    } label: {
                        launcherRouteButtonLabel(
                            title: "Enter Native SSH",
                            systemImage: "chevron.right.circle.fill"
                        )
                    }
                    .buttonStyle(.plain)
                }

                launcherActionCard(
                    title: "Ready to Launch",
                    subtitle: "OpenClaw URL stays editable, is normalized to https when needed, and keeps the same automatic memory logic for later launches.",
                    systemImage: "checkmark.shield"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                launcherStatusPill(title: "Saved", systemImage: "externaldrive.fill.badge.checkmark")
                                launcherStatusPill(title: "Auto HTTPS", systemImage: "lock.rotation")
                            }

                            HStack(spacing: 8) {
                                launcherStatusPill(title: "Persistent", systemImage: "memorychip")
                            }
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
            .padding(.top, 10)
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
                    .opacity(0.24)
                }
            }
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.mint.opacity(0.24))
                .frame(width: 210, height: 210)
                .blur(radius: 54)
                .offset(x: 56, y: -24)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 240, height: 240)
                .blur(radius: 56)
                .offset(x: -60, y: 36)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .top) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 180, height: 180)
                .blur(radius: 42)
                .offset(y: -70)
                .allowsHitTesting(false)
        }
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
            subtitle: "An iPhone-first launcher with a stronger visual anchor, deeper glow, and direct paths into OpenClaw, Cloudflare Tunnel SSH, and native SSH."
        ) {
            VStack(alignment: .leading, spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.mint.opacity(0.2))
                        .frame(width: 156, height: 156)
                        .blur(radius: 24)

                    Circle()
                        .fill(Color.blue.opacity(0.18))
                        .frame(width: 124, height: 124)
                        .blur(radius: 18)
                        .offset(x: -14, y: 10)

                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.96), .mint.opacity(0.84)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 108, height: 108)
                        .overlay(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .stroke(Color.white.opacity(0.26), lineWidth: 1)
                        )
                        .shadow(color: .mint.opacity(0.35), radius: 22, x: 0, y: 14)

                    Image(systemName: "network")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Launcher")
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text("Single-column rhythm, stronger hierarchy, and a cleaner mobile entry for your saved control plane.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    launcherStatusPill(title: "iPhone First", systemImage: "iphone")
                    launcherStatusPill(title: "Deep Glow", systemImage: "sparkles")
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
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.black.opacity(0.16))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
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

                VStack(spacing: 10) {
                    Button {
                        openManagementURL()
                    } label: {
                        Label("Open OpenClaw", systemImage: "arrow.up.forward.app")
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        managementInput = defaultOpenClawURL
                        managementURL = defaultOpenClawURL
                    } label: {
                        Label("Reset to Default", systemImage: "arrow.counterclockwise")
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
    private func launcherRouteCard<Content: View>(
        eyebrow: String,
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        highlights: [String],
        @ViewBuilder content: () -> Content
    ) -> some View {
        launcherActionCard(title: title, subtitle: subtitle, systemImage: systemImage) {
            VStack(alignment: .leading, spacing: 14) {
                Text(eyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(tint.opacity(0.14))
                    )

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(highlights, id: \.self) { item in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(tint)
                            Text(item)
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        }
                    }
                }

                content()
            }
        }
    }

    private func launcherRouteButtonLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            Text(title)
                .font(.system(.headline, design: .rounded).weight(.semibold))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.primary.opacity(0.9), .primary.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
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
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.clear, Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
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
