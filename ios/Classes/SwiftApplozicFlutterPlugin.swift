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
                self.sendErrorResultWithCallback(result: result, message: "Unable to parse user JSON")
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
                    
                    self.sendSuccessResultWithCallback(result: result, object: (response?.dictionary())!)
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
            self.getChatManager(result: result).launchChatList(from: UIApplication.topViewController()!, with: ALChatManager.defaultConfiguration)
        } else if(call.method == "launchChatWithUser") {
            self.getChatManager(result: result).launchChatWith(contactId: call.arguments as! String, from: UIApplication.topViewController()!, configuration: ALChatManager.defaultConfiguration)
            self.sendSuccessResultWithCallback(result: result, message: "Success")
        } else if(call.method == "launchChatWithGroupId") {
            var groupId = NSNumber(0)
            
            if let channelKey = call.arguments as? String {
                groupId = Int(channelKey)! as NSNumber
            } else if let channelKey = call.arguments as? Int {
                groupId = NSNumber(value: channelKey)
            } else {
                sendErrorResultWithCallback(result: result, message: "Invalid groupId")
                return
            }
            
            if(groupId == 0) {
                sendErrorResultWithCallback(result: result, message: "Invalid groupId")
                return
            }
            
            let channelService = ALChannelService()
            channelService.getChannelInformation(groupId, orClientChannelKey: nil) { (channel) in
                guard channel != nil else {
                    self.sendErrorResultWithCallback(result: result, message: "Channel is null, internal error occured")
                    return
                }
                self.getChatManager(result: result).launchGroupWith(clientGroupId: (channel?.clientChannelKey)!, from: UIApplication.topViewController()!, configuration: ALChatManager.defaultConfiguration)
                self.sendSuccessResultWithCallback(result: result, message: channel!.clientChannelKey)
            }
        } else if(call.method == "createGroup") {
            guard let channelInfo = call.arguments as? Dictionary<String, Any> else {
                self.sendErrorResultWithCallback(result: result, message: "Unable to parse groupInfo object")
                return
            }
            var membersList = NSMutableArray();
            
            if(channelInfo["groupMemberList"] != nil) {
                membersList = channelInfo["groupMemberList"] as! NSMutableArray
            }
            
            let channelService = ALChannelService()
            channelService.createChannel(channelInfo["groupName"] as? String,orClientChannelKey: channelInfo["clientGroupId"] as? String, andMembersList: membersList, andImageLink: channelInfo["imageUrl"] as? String, channelType: channelInfo["type"] as! Int16, andMetaData: channelInfo["metadata"] as? NSMutableDictionary, adminUser: channelInfo["admin"] as? String, withGroupUsers: channelInfo["users"] as? NSMutableArray) {
                (alChannel, error) in
                if(error == nil) {
                    self.sendSuccessResultWithCallback(result: result, message: (alChannel?.key.stringValue)!)
                } else {
                    self.sendErrorResultWithCallback(result: result, message: error!.localizedDescription)
                }
            }
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
            let contactService = ALContactService()
            guard let dictArray = call.arguments as? [Dictionary<String, Any>] else {
                sendErrorResultWithCallback(result: result, message: "Unable to parse contact data")
                return
            }
            
            if(dictArray.count > 0) {
                for userDict in dictArray {
                    let userDetail = ALContact(dict: userDict)
                    contactService.updateOrInsert(userDetail)
                }
                sendSuccessResultWithCallback(result: result, message: "Success")
            }
        } else if(call.method == "getLoggedInUserId") {
            if(ALUserDefaultsHandler.isLoggedIn()) {
                self.sendSuccessResultWithCallback(result: result, message: ALUserDefaultsHandler.getUserId())
            } else {
                self.sendErrorResultWithCallback(result: result, message: "User not authorised. UserId is empty")
            }
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
    
    func sendSuccessResultWithCallback(result: FlutterResult, object: [AnyHashable : Any]) {
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
    
    func customBackAction() {
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
    }
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
