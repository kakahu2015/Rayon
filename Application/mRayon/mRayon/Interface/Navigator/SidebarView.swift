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

    @State private var managementInput: String = ""
    @State private var preparedManagementURL: String = defaultOpenClawURL
    @State private var managementActive: Bool = false

    var body: some View {
        NavigationView {
            sidebar
            WelcomeView()
        }
        .onAppear {
            if managementInput.isEmpty {
                managementInput = managementURL
            }
        }
    }

    var sidebar: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                launcherCard

                SidebarFeatureCard(
                    eyebrow: "Cloudflare Route",
                    title: "Cloudflare Tunnel SSH",
                    subtitle: "Open the Cloudflare Tunnel protected SSH web entry in the embedded browser.",
                    systemImage: "lock.shield",
                    tint: .mint,
                    badges: ["Tunnel Protected", "Embedded Browser"]
                ) {
                    SidebarBrowserContainerView(title: "Cloudflare Tunnel SSH", urlString: "https://ssh.kakahu.org")
                }

                SidebarFeatureCard(
                    eyebrow: "SSH Hosts",
                    title: "Machine",
                    subtitle: "Manage saved hosts and connection targets with the same iPhone-first launcher card rhythm.",
                    systemImage: "server.rack",
                    tint: .blue,
                    badges: ["Saved Hosts", "Targets"]
                ) {
                    MachineView()
                }

                SidebarFeatureCard(
                    eyebrow: "SSH Identity",
                    title: "Identity",
                    subtitle: "Manage usernames, passwords, and SSH keys in the same visual shell.",
                    systemImage: "person.crop.circle",
                    tint: .purple,
                    badges: ["Credentials", "SSH Keys"]
                ) {
                    IdentityView()
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
                        .fill(Color.mint.opacity(0.14))
                        .frame(width: 220, height: 220)
                        .blur(radius: 42)
                        .offset(x: 90, y: -120)

                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 240, height: 240)
                        .blur(radius: 52)
                        .offset(x: -90, y: 220)
                }
            }
        )
    }

    private var launcherCard: some View {
        SidebarSurface {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.mint.opacity(0.22))
                            .frame(width: 72, height: 72)
                            .blur(radius: 12)

                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.96), .mint.opacity(0.82)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.24), lineWidth: 1)
                            )
                            .shadow(color: .mint.opacity(0.32), radius: 18, x: 0, y: 10)

                        Image(systemName: "network")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Launcher")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Your iPhone-first entry for OpenClaw, Cloudflare Tunnel SSH, Machine, and Identity.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    SidebarBadge(title: "Editable URL", systemImage: "link")
                    SidebarBadge(title: "Auto Saved", systemImage: "externaldrive.fill.badge.checkmark")
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
                                .fill(Color.black.opacity(0.12))
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

                VStack(alignment: .leading, spacing: 8) {
                    Label("Saved destination", systemImage: "link")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(.secondary)

                    Text(normalizedManagementURL)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                }

                VStack(spacing: 10) {
                    Button {
                        openManagementURL()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                            Text("Open OpenClaw")
                                .font(.system(.headline, design: .rounded).weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.accentColor.opacity(0.96), .mint.opacity(0.84)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    }
                    .buttonStyle(.plain)

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
                    destination: SidebarBrowserContainerView(title: "OpenClaw", urlString: preparedManagementURL),
                    isActive: $managementActive
                ) {
                    EmptyView()
                }
            }
        }
    }

    private var normalizedManagementURL: String {
        let trimmed = managementURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return defaultOpenClawURL }
        if trimmed.contains("://") { return trimmed }
        return "https://" + trimmed
    }

    private func openManagementURL() {
        let normalized = normalizedManagementURL(from: managementInput)
        managementInput = normalized
        managementURL = normalized
        preparedManagementURL = normalized
        managementActive = true
    }

    private func normalizedManagementURL(from value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return defaultOpenClawURL }
        if trimmed.contains("://") { return trimmed }
        return "https://" + trimmed
    }
}

private struct SidebarFeatureCard<Destination: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let badges: [String]
    let destination: Destination

    init(
        eyebrow: String,
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        badges: [String],
        @ViewBuilder destination: () -> Destination
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.badges = badges
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            SidebarSurface {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [tint.opacity(0.95), tint.opacity(0.62)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 54, height: 54)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                        Image(systemName: systemImage)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(eyebrow.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(tint)

                        Text(title)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundColor(.primary)

                        Text(subtitle)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            ForEach(badges, id: \.self) { badge in
                                Text(badge)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(Color.white.opacity(0.12))
                                    )
                            }
                        }
                    }

                    Spacer(minLength: 10)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SidebarSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
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
}

private struct SidebarBadge: View {
    let title: String
    let systemImage: String

    var body: some View {
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
