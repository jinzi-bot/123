import SwiftUI
import WebKit

/// 保存 WebView 的弱引用，让工具栏按钮可以控制页面
final class PanelController: ObservableObject {
    weak var webView: WKWebView?

    func reload() {
        webView?.reload()
    }

    func goBack() {
        if webView?.canGoBack == true {
            webView?.goBack()
        }
    }
}

struct WebPanelView: UIViewRepresentable {
    let urlString: String
    let controller: PanelController
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        // 用公开 API 追加 UA 标识，避免 KVC 私有接口；必须在创建 WKWebView 之前设置
        config.applicationNameForUserAgent = "QQFarmPanel/1.0"

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        controller.webView = webView
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let current = webView.url?.absoluteString else {
            if let url = URL(string: urlString) {
                webView.load(URLRequest(url: url))
            }
            return
        }
        // 服务器地址变更后重新加载
        if !current.hasPrefix(urlString) {
            if let url = URL(string: urlString) {
                webView.load(URLRequest(url: url))
            }
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let isLoading: Binding<Bool>

        init(isLoading: Binding<Bool>) {
            self.isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading.wrappedValue = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading.wrappedValue = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading.wrappedValue = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading.wrappedValue = false
        }

        /// 打开外部协议（tel: / mailto: 等）
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               let scheme = url.scheme?.lowercased(),
               scheme != "http", scheme != "https", scheme != "about", scheme != "file" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        /// window.open / target=_blank 在当前 WebView 打开
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
    }
}
