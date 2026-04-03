//
//  SidebarView.swift
//  mRayon
//
//  Created by Lakr Aream on 2022/3/2.
//

import RayonModule
import SwiftUI
import WebKit

struct SidebarView: View {
    @EnvironmentObject var store: RayonStore

    @AppStorage("launcher.managementURL") private var managementURL: String = defaultOpenClawURL
    @AppStorage("launcher.cfsshURL") private var cfsshURL: String = defaultCFSSHURL

    @State private var managementInput: String = ""
    @State private var cfsshInput: String = ""

    @State private var preparedManagementURL: String = defaultOpenClawURL
    @State private var preparedCFSSHURL: String = defaultCFSSHURL

    @State private var managementActive: Bool = false
    @State private var cfsshActive: Bool = false

    var body: some View {
        NavigationView {
            sidebar
            WelcomeView()
        }
        .onAppear {
            if managementInput.isEmpty {
                managementInput = managementURL
            }
            if cfsshInput.isEmpty {
                cfsshInput = cfsshURL
            }
        }
    }

    var sidebar: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                editableURLCard(
                    title: "OpenClaw",
                    buttonTitle: "Open OpenClaw",
                    placeholder: "https://openclaw.example.com",
                    systemImage: "network",
                    tint: .accentColor,
                    text: $managementInput,
                    savedValue: normalizedManagementURL,
                    persistAction: { managementURL = $0 },
                    openAction: openManagementURL,
                    resetAction: resetManagementURL
                )

                editableURLCard(
                    title: "Cloudflare Tunnel SSH",
                    buttonTitle: "Open Cloudflare Tunnel SSH",
                    placeholder: "https://ssh.example.com",
                    systemImage: "lock.shield",
                    tint: .mint,
                    text: $cfsshInput,
                    savedValue: normalizedCFSSHURL,
                    persistAction: { cfsshURL = $0 },
                    openAction: openCFSSHURL,
                    resetAction: resetCFSSHURL
                )

                HStack(spacing: 10) {
                    SidebarCompactNavCard(title: "Machine", systemImage: "server.rack", tint: .blue) {
                        MachineView()
                    }

                    SidebarCompactNavCard(title: "Identity", systemImage: "person.crop.circle", tint: .purple) {
                        IdentityView()
                    }
                }

                NavigationLink(
                    destination: SidebarBrowserContainerView(title: "OpenClaw", urlString: preparedManagementURL),
                    isActive: $managementActive
                ) {
                    EmptyView()
                }

                NavigationLink(
                    destination: SidebarBrowserContainerView(title: "Cloudflare Tunnel SSH", urlString: preparedCFSSHURL),
                    isActive: $cfsshActive
                ) {
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if !store.reducedViewEffects {
                    Circle()
                        .fill(Color.mint.opacity(0.12))
                        .frame(width: 220, height: 220)
                        .blur(radius: 42)
                        .offset(x: 90, y: -120)
                        .allowsHitTesting(false)

                    Circle()
                        .fill(Color.blue.opacity(0.08))
                        .frame(width: 240, height: 240)
                        .blur(radius: 52)
                        .offset(x: -90, y: 220)
                        .allowsHitTesting(false)
                }
            }
        )
    }

    @ViewBuilder
    private func editableURLCard(
        title: String,
        buttonTitle: String,
        placeholder: String,
        systemImage: String,
        tint: Color,
        text: Binding<String>,
        savedValue: String,
        persistAction: @escaping (String) -> Void,
        openAction: @escaping () -> Void,
        resetAction: @escaping () -> Void
    ) -> some View {
        SidebarSurface {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [tint.opacity(0.95), tint.opacity(0.65)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46, height: 46)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )

                        Image(systemName: systemImage)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                        Text("Editable + remembered")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }

                TextField(placeholder, text: text)
                    .textFieldStyle(.plain)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .onChange(of: text.wrappedValue) { newValue in
                        persistAction(newValue)
                    }
                    .onSubmit {
                        openAction()
                    }

                Text(savedValue)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Button {
                        openAction()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.forward.app")
                            Text(buttonTitle)
                                .lineLimit(1)
                        }
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [tint.opacity(0.95), tint.opacity(0.72)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        resetAction()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var normalizedManagementURL: String {
        normalizedURL(from: managementURL, fallback: defaultOpenClawURL)
    }

    private var normalizedCFSSHURL: String {
        normalizedURL(from: cfsshURL, fallback: defaultCFSSHURL)
    }

    private func normalizedURL(from value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return fallback }
        if trimmed.contains("://") { return trimmed }
        return "https://" + trimmed
    }

    private func openManagementURL() {
        let normalized = normalizedURL(from: managementInput, fallback: defaultOpenClawURL)
        managementInput = normalized
        managementURL = normalized
        preparedManagementURL = normalized
        managementActive = true
    }

    private func openCFSSHURL() {
        let normalized = normalizedURL(from: cfsshInput, fallback: defaultCFSSHURL)
        cfsshInput = normalized
        cfsshURL = normalized
        preparedCFSSHURL = normalized
        cfsshActive = true
    }

    private func resetManagementURL() {
        managementInput = defaultOpenClawURL
        managementURL = defaultOpenClawURL
    }

    private func resetCFSSHURL() {
        cfsshInput = defaultCFSSHURL
        cfsshURL = defaultCFSSHURL
    }
}

private struct SidebarCompactNavCard<Destination: View>: View {
    let title: String
    let systemImage: String
    let tint: Color
    let destination: Destination

    init(
        title: String,
        systemImage: String,
        tint: Color,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            SidebarSurface {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [tint.opacity(0.95), tint.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )

                        Image(systemName: systemImage)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Text(title)
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)

                    Spacer(minLength: 6)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

private struct SidebarSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.clear, Color.white.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 10)
    }
}

private struct SidebarBrowserContainerView: View {
    let title: String
    let urlString: String

    var body: some View {
        SidebarEmbeddedWebView(urlString: urlString)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
    }
}

private struct SidebarEmbeddedWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
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
