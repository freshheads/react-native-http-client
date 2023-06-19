@objc(HttpClient)
class HttpClient: NSObject {

  @objc(multiply:withB:withResolver:withRejecter:)
  func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    resolve(a*b)
  }

  @objc(get:optionsJson:resolver:rejecter:)
  func get(_ url: String, optionsJson: String?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    var components = URLComponents(string: url)
    
    if let optionsJson = optionsJson {
      let optionsData = Data(optionsJson.utf8)
      if let options = try? JSONSerialization.jsonObject(with: optionsData, options: .mutableContainers) as? [String: Any] {
        
        if let params = options["params"] as? [String: String] {
          components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
      }
    }

    guard let finalUrl = components?.url else {
      reject("E_URL_INVALID", "The URL provided is invalid", nil)
      return
    }

    var request = URLRequest(url: finalUrl)
    request.httpMethod = "GET"

    if let optionsJson = optionsJson {
      let optionsData = Data(optionsJson.utf8)
      if let options = try? JSONSerialization.jsonObject(with: optionsData, options: .mutableContainers) as? [String: Any] {
        
        if let headers = options["headers"] as? [String: String] {
          for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
          }
        }
      }
    }

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        reject("E_GET_FAILED", error.localizedDescription, error)
        return
      }
      
      if let response = response as? HTTPURLResponse {
        var responseHeaders = [String: String]()
        for (key, value) in response.allHeaderFields {
          if let key = key as? String, let value = value as? String {
            responseHeaders[key] = value
          }
        }
        
        var body = ""
        if let data = data {
            body = String(data: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet(charactersIn: "\u{0}")) ?? ""
        }
        
        let jsonResult: [String: Any] = [
          "statusCode": response.statusCode,
          "requestHeaders": request.allHTTPHeaderFields ?? [:],
          "responseHeaders": responseHeaders,
          "body": body
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonResult, options: .fragmentsAllowed),
           let jsonString = String(data: jsonData, encoding: .utf8) {
          resolve(jsonString)
        } else {
          reject("E_JSON_SERIALIZATION_FAILED", "Failed to serialize json", nil)
        }
        
      } else {
        reject("E_NO_RESPONSE", "No response received", nil)
      }
    }
    task.resume()
  }
}
