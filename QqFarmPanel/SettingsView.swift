import SwiftUI

struct SettingsView: View {
    static let defaultServer = "http://150.138.73.130"

    @Environment(\.dismiss) private var dismiss
    @State private var input: String = ""
    let onSave: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("QQ农场智能助手").font(.headline)
                    Text("v1.0.0").font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)

            Text("请填写面板服务器地址（core 服务端所在地址）。")
                .font(.footnote)
                .foregroundColor(.secondary)

            TextField("例如 http://150.138.73.130", text: $input)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 12) {
                Button("恢复默认") {
                    input = SettingsView.defaultServer
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("保存并打开") {
                    let url = SettingsView.normalize(input)
                    if !url.isEmpty {
                        onSave(url)
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()

            Text("提示：进入面板后点右上角 ⚙ 可随时修改服务器地址。")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .onAppear {
            if input.isEmpty {
                input = SettingsView.defaultServer
            }
        }
    }

    static func normalize(_ raw: String) -> String {
        var url = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if url.isEmpty { return "" }
        if !url.lowercased().hasPrefix("http://") && !url.lowercased().hasPrefix("https://") {
            url = "http://" + url
        }
        while url.hasSuffix("/") {
            url.removeLast()
        }
        return url
    }
}
