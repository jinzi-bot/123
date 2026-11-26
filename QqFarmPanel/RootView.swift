import SwiftUI

struct RootView: View {
    @AppStorage("serverUrl") private var serverUrl: String = SettingsView.defaultServer
    @StateObject private var controller = PanelController()
    @State private var isLoading = false
    @State private var showSettings = false
    @State private var showSettingsFirst = false

    private var configured: Bool {
        !serverUrl.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                if configured {
                    WebPanelView(urlString: serverUrl, controller: controller, isLoading: $isLoading)
                        .ignoresSafeArea(edges: .bottom)

                    if isLoading {
                        ProgressView()
                            .padding(6)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            .padding(.top, 6)
                    }
                } else {
                    SettingsView { url in
                        serverUrl = url
                        showSettingsFirst = false
                    }
                }
            }
            .navigationTitle("QQ农场智能助手")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if configured {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            controller.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        Button {
                            controller.reload()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView { url in
                        serverUrl = url
                    }
                    .navigationTitle("服务器设置")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("关闭") { showSettings = false }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}
