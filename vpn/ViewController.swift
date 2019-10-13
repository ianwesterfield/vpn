//
//  ViewController.swift
//  vpn
//
//  Created by Ian Westerfield on 10/12/19.
//  Copyright © 2019 Enquiren. All rights reserved.
//
import UIKit

class ViewController: UIViewController {
  var isVpnRunning = true
  let baseUri = "http://192.168.1.1"
  let authroizationToken = "Basic YWRtaW46Q3IwYXQwYU4="
  let httpId = "TID32d44da2ce41e436"
  let referrer = "http://192.168.1.1/vpn-client.asp"
  let contentType = "application/x-www-form-urlencoded"
  
  //MARK: Properties
  @IBOutlet weak var toggleVpnButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getVpnStatus()
  }
  
  @IBAction func vpnButton(_ sender: Any) {
    toggleVpn()
  }
  
  func getVpnStatus() {
    let url = URL(string: "\(baseUri)/vpnstatus.cgi?client=1&_http_id=\(httpId)")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    request.addValue(authroizationToken, forHTTPHeaderField: "Authorization")
    submitRequest(request: request, statusOnly: true)
  }
  
  func toggleVpn() {
    let url = URL(string: "\(baseUri)/service.cgi")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    request.addValue(authroizationToken, forHTTPHeaderField: "Authorization")
    request.addValue(referrer, forHTTPHeaderField: "Referrer")
    request.addValue(contentType, forHTTPHeaderField: "Content-Type")
    
    let data = "_service=vpnclient1-\(isVpnRunning ? "stop" : "start")&_http_id=\(httpId)".data(using: String.Encoding.utf8, allowLossyConversion: false)!
    request.httpBody = data as Data
    
    submitRequest(request: request, statusOnly: false)
  }
  
  func submitRequest(request: URLRequest, statusOnly: Bool) {
    activityIndicator.startAnimating()
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
      if error != nil {
        print(error!)
        return
      }
      
      if (!statusOnly) {
        DispatchQueue.main.async {
          self.isVpnRunning = !self.isVpnRunning
          self.updateUi()
        }
      }
      
      guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        return
      }
      
      if let data = data, let string = String(data: data, encoding: .utf8) {
        DispatchQueue.main.async {
          self.isVpnRunning = statusOnly ? !string.isEmpty : !self.isVpnRunning
          self.updateUi()
        }
      }
    })
    
    task.resume()
  }
  
  func updateUi() {
    let title = "\(self.isVpnRunning ? "Disable" : "Enable") VPN"
    self.toggleVpnButton.setTitle(title, for: UIControl.State.normal)
    self.activityIndicator.stopAnimating()
    self.toggleVpnButton.center = self.view.center
  }
}
