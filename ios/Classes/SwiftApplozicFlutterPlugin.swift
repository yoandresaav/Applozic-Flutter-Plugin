import Flutter
import UIKit
import Applozic

public class SwiftApplozicFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "applozic_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftApplozicFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "login") {
            guard let userDict = call.arguments as? Dictionary<String, Any> else {
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDict, options: .prettyPrinted)
                let jsonString = String(bytes: jsonData, encoding: .utf8)
                
                let alUser = ALUser.init(jsonString: jsonString)
                
                guard let user = alUser  else {
                    self.sendErrorResultWithCallback(result: result, message: "Unable to parse user JSON")
                    return
                }
                
                let chatManager = ALChatManager.init(applicationKey: user.applicationId as NSString)
                chatManager.connectUser(user) { (response, error) in
                    guard  error == nil else  {
                        self.sendErrorResultWithCallback(result: result, message: error!.localizedDescription)
                        return
                    }
                    self.sendSuccessResultWithCallback(result: result, object: response as Any)
                }
            } catch {
                self.sendErrorResultWithCallback(result: result, message: error.localizedDescription)
            }
        } else if(call.method == "isLoggedIn") {
            result(ALUserDefaultsHandler.isLoggedIn())
        } else if(call.method == "logout") {
            let registerUserClientService = ALRegisterUserClientService()
            registerUserClientService.logout { (response, error) in
                if(error == nil) {
                    self.sendSuccessResultWithCallback(result: result, message: "Success")
                } else {
                    self.sendErrorResultWithCallback(result: result, message: error!.localizedDescription)
                }
            }
        } else if(call.method == "launchChat") {
            //getChatManager(result: result).launchChatList(from: UIApplication.topViewController(), with: ALKConfiguration())
        } else if(call.method == "launchChatWithUser") {
            //getChatManager(result: result).launchChatWith(contactId: call.arguments as String, from: self, configuration: ALKConfiguration())
        } else if(call.method == "launchChatWithGroupId") {
            //getChatManager(result: result).launchGroupWith(clientGroupId: call.arguments as String, from: self, configuration: ALKConfiguration())
        } else if(call.method == "createGroup") {
            
        } else if(call.method == "updateUserDetail") {
            guard let user = call.arguments as? Dictionary<String, Any> else {
                sendErrorResultWithCallback(result: result, message: "Invalid kmUser object")
                return
            }
            if(ALUserDefaultsHandler.isLoggedIn()) {
                let userClientService = ALUserClientService()
                userClientService.updateUserDisplayName(user["displayName"] as? String, andUserImageLink: user["imageLink"] as? String, userStatus: user["status"] as? String, metadata: user["metadata"] as? NSMutableDictionary) { (_, error) in
                    guard error == nil else {
                        self.sendErrorResultWithCallback(result: result, message: error!.localizedDescription)
                        return
                    }
                    self.sendSuccessResultWithCallback(result: result, message: "Success")
                }
            } else {
                sendErrorResultWithCallback(result: result, message: "User not authorised. This usually happens when calling the function before login. Make sure you call either of the two functions before updating the user details")
            }
        } else if(call.method == "addContacts") {
            
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func sendSuccessResultWithCallback(result: FlutterResult, message: String) {
        result(message)
    }
    
    func sendErrorResultWithCallback(result: FlutterResult, message: String) {
        result(FlutterError(code: "Error", message: message, details: nil))
    }
    
    func sendSuccessResultWithCallback(result: FlutterResult, object: Any) {
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            let jsonString = String(bytes: jsonData, encoding: .utf8)
            result(jsonString)
        } catch {
            sendSuccessResultWithCallback(result: result, message: "Success")
        }
    }
    
    func getChatManager(result: FlutterResult) -> ALChatManager {
        let applicationKey = ALUserDefaultsHandler.getApplicationKey()
        if(applicationKey != nil) {
            return ALChatManager.init(applicationKey: applicationKey! as NSString)
        } else {
            sendErrorResultWithCallback(result: result, message: "Seems like you have not logged in!")
        }
        return ALChatManager.init(applicationKey: applicationKey! as NSString)
    }
    
    /// Add this in your AppDelegate.swift file
   /* static let applozicConfiguration: ALKConfiguration = {
          var config = ALKConfiguration()
          /// Change properties here...
          /// Read below to know about different properties used in `ALKConfiguration`
          return config
    }()*/
}

extension UIApplication {
class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
        return topViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
    }
    if let presented = controller?.presentedViewController {
        return topViewController(controller: presented)
    }
    return controller
}}
