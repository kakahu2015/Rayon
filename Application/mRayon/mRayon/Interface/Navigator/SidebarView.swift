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

    var body: some View {
        NavigationView {
            sidebar
            WelcomeView()
        }
    }

    var sidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                SidebarLinkCard(
                    title: "OpenClaw",
                    subtitle: "Open the management page in an embedded browser.",
                    systemImage: "network"
                ) {
                    SidebarBrowserContainerView(title: "OpenClaw", urlString: normalizedManagementURL)
                }

                SidebarLinkCard(
                    title: "Cloudflare Tunnel SSH",
                    subtitle: "Open the Cloudflare Tunnel protected Web SSH endpoint.",
                    systemImage: "lock.shield"
                ) {
                    SidebarBrowserContainerView(title: "Cloudflare Tunnel SSH", urlString: "https://ssh.kakahu.org")
                }

                SidebarLinkCard(
                    title: "Machine",
                    subtitle: "Manage saved hosts and connection targets.",
                    systemImage: "server.rack"
                ) {
                    MachineView()
                }

                SidebarLinkCard(
                    title: "Identity",
                    subtitle: "Manage usernames, passwords, and SSH keys.",
                    systemImage: "person"
                ) {
                    IdentityView()
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var normalizedManagementURL: String {
        let trimmed = managementURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return defaultOpenClawURL }
        if trimmed.contains("://") { return trimmed }
        return "https://" + trimmed
    }
}

private struct SidebarLinkCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let destination: Destination

    init(title: String, subtitle: String, systemImage: String, @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: systemImage)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
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
