//
//
// Product: APITestCallAI
// Project: APITestCallAI
// Package: APITestCallAI
//


import Foundation
import Alamofire
import UIKit
class Constants {
    
    enum Headers {
        static let xApiKey = "x-api-key"
        static let xApiKeyValue = "eMnJUkNEvNBjDLvsJpmwL4fRFUX26jPH4VQw62zLckrB5GaBgsdrWajQEYCcHMRjychja349ZjEvL8Pex665ud5EBWuhN8aSTTS6Anp8af6DJ64pPJwJbRMsjGUZMHYb"
        static let language = "Accept-Language"
        static let contentType = "Content-Type"
        static let contentValue = "application/json"
        static let authorization = "Authorization"
        static let Accept = "Accept"
    }
}

struct SuccessModel: Codable {
    let status: Int
    let message: String
    let error: String
    enum CodingKeys: String, CodingKey {
        case status, message, error
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status) ?? 0
        message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
        error = try values.decodeIfPresent(String.self, forKey: .error) ?? ""
    }
}

let header: HTTPHeaders = [
    Constants.Headers.Accept: Constants.Headers.contentValue,
    Constants.Headers.contentType: Constants.Headers.contentValue,
    Constants.Headers.xApiKey: Constants.Headers.xApiKeyValue
]

class ApiClient: NSObject {
    static func apiRequest
    (urlString: String, method: HTTPMethod, headers: HTTPHeaders, parameter: Parameters, completion:
        @escaping (_ status: Bool, _ message: String, _ sampleData: Data) -> Void) {
        isNetworkAvailable { status, message in
            if status {
                let url = URL(string: "\(urlString)")!
//                print("URL: \(url)")
//                print("PARAMETERS: \(parameter)")
//                print("HTTPMethod: \(headers)")
                let manager = Alamofire.Session.default
                manager.session.configuration.timeoutIntervalForRequest = 10
                manager.request(url, method: method, parameters: method == .get ? nil : parameter,
                                encoding: JSONEncoding.default, headers: headers).responseData { response in
                    let data = response.data
                    responseData(response: response, completion: { status, message in
//                        print(String(data: response.data!, encoding: String.Encoding.utf8)!)
                        completion(status, message, data ?? Data())
                    })
                }
            } else {
                completion(false, "", Data())
//                showBanner(title: message, isSucess: false)
            }
        }
    }

}

func responseData(response: AFDataResponse<Data>, completion:
    @escaping (_ status: Bool, _ message: String) -> Void) {
    switch response.result {
    case .success(let res):
        if let code = response.response?.statusCode {
            switch code {
            case 205...299, 200...203:
                do {
                    print(String(data: response.data!, encoding: String.Encoding.utf8)!)
                    let responseData = try JSONDecoder().decode(SuccessModel.self, from: res)
                    completion(true, responseData.message)
                } catch {
                    print(String(data: res, encoding: .utf8) ?? "nothing received")
                    completion(true, "nothing received")
                }
            case 204, 400...502:
                do {
                    let responseData = try JSONDecoder().decode(SuccessModel.self, from: res)
                    completion(false, responseData.message)
                } catch {
                    print(String(data: res, encoding: .utf8) ?? "nothing received")
                    completion(false, "nothing received")
                }
            default:
             let error = NSError(domain: response.debugDescription, code: code, userInfo: response.response?.allHeaderFields as? [String: Any])
                completion(false, error.localizedDescription)
            }
        }
    case .failure(let error):
        completion(false, error.localizedDescription)
    }
}

// MARK: - Check network availability ------------------------------
func isNetworkAvailable(completionHandler: @escaping (_ success: Bool, _ message: String) -> Void) {
    let reachability = NetworkReachabilityManager()
    reachability?.startListening { status in
        switch status {
        case .notReachable:
            completionHandler(false, "CheckConnection")
            print("The network is not reachable")
        case .unknown:
            completionHandler(false, "NoReachable")
            print("It is unknown whether the network is reachable")
        // not sure what to do for this case
        case .reachable(.cellular):
            completionHandler(true, "mobilen/w")
            print("The network is reachable over the WWAN connection")
        case .reachable(.ethernetOrWiFi):
            completionHandler(true, "wifi")
            print("The network is reachable over the WiFi connection")
        }
    }
}

