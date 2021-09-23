//
//  VKLoginViewController.swift
//  VK_application
//
//  Created by Сергей Чумовских  on 21.09.2021.
//

import UIKit
import WebKit

class VKLoginViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!{
        didSet{
            webView.navigationDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginToVk()
    }
    
    private func loginToVk() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "oauth.vk.com"
        urlComponents.path = "/authorize"
        urlComponents.queryItems = [
            // Идентификатор приложения
            URLQueryItem(name: "client_id", value: "7957447"),
            // Указывает тип отображения страницы авторизации
            URLQueryItem(name: "display", value: "mobile"),
            // Адрес, на который будет переадресован пользователь после прохождения авторизации
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            // Битовая маска настроек доступа приложения (262150 - Доступ к группам пользователя)
            URLQueryItem(name: "scope", value: "262150"),
            // Тип ответа, который необходимо получить
            URLQueryItem(name: "response_type", value: "token"),
            // Версия API
            URLQueryItem(name: "v", value: "5.8"),
            // если нужно повторно входить
            //                    URLQueryItem(name: "revoke", value: "1")
        ]
        let request = URLRequest(url: urlComponents.url!)
        webView.load(request)
    }
    
}

extension VKLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url,
              url.path == "/blank.html", let fragment = url.fragment else {
                  decisionHandler(.allow)
                  return
              }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }
        
        guard let token = params["access_token"] else { return }
        guard let userID = params["user_id"] else { return }
        print("++++++++++++++++++++++++++++")
        if !token.isEmpty && !userID.isEmpty {
            print("token = \(token)")
            print("userID = \(userID)")
            UserSession.shared.token = token
            UserSession.shared.userId = Int(userID)!
        } else {
            print("token or userID is nil")
        }
        print("++++++++++++++++++++++++++++")
        decisionHandler(.cancel)
        performSegue(withIdentifier: "fromWebToLoading", sender: nil)
    }
}