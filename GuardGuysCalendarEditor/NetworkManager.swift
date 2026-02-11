//
//  NetworkManager.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/5/23.
//

import Foundation


public class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    private override init() {}
    
    func makeApiRequestFor(_ requestInfo: RequestType) async throws -> Data {
        
        // updates where the parameters are stored
        let urlParams = requestInfo.paramType == "body" ? "" : urlParameters(params: requestInfo.parameters)
        let bodyParams = requestInfo.paramType == "body" ? bodyParameters(params: requestInfo.parameters) : nil
        
        guard let url = URL(string: "\(NetworkDomains.address)\(requestInfo.path)\(urlParams)") else { throw NetworkErrors.invalidUrl }
        
        // creates the api request
        var request = URLRequest(url: url)
        request.httpMethod = requestInfo.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyParams
        print(request)
        
        do {
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let responseData = response as? HTTPURLResponse else { throw NetworkErrors.unknownError }
            
            print("\(requestInfo.method.rawValue): \(request) API Server response code: \(responseData.statusCode)")
          
            switch responseData.statusCode {
            case 200...299: return data
            default:
                
                // network error handler
                
                let dictionary  = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : AnyObject]
                let jsonData    = try JSONSerialization.data(withJSONObject: dictionary as Any)
                let error       = try JSONDecoder().decode(ErrorResponse.self, from: jsonData)
                
                guard let firstMessage = error.errors?[0].message else { throw NetworkErrors.unknownError }
                
                switch firstMessage {
                case "user.password cannot be null": throw NetworkErrors.passwordValidation
                case "Validation isEmail on email failed": 
                    throw NetworkErrors.emailValidation
                default: throw NetworkErrors.unknownError
                }
            }
        }
        catch { 
            
            throw NetworkErrors.networkFailure }
    }
    
    func urlParameters(params: [String:Any]?) -> String {
        guard let params, !params.isEmpty else { return "" }
        var components: [String] = []
        for (key, value) in params {
            let keyEncoded = String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? String(describing: key)
            let valueEncoded = String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? String(describing: value)
            components.append("\(keyEncoded)=\(valueEncoded)")
        }
        return components.isEmpty ? "" : "?" + components.joined(separator: "&")
    }
    
    func bodyParameters(params: [String:Any]?) -> Data? {
        guard params != nil && params!.count > 0 else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
            print(String(data: data, encoding: .utf8)!)
            return data
        }
        catch { return nil }
    }
  
}

class NetworkDomains {
    public static var address = "https://guardguys.herokuapp.com"
}

public enum RequestType: RequestTypeProtocol {
    
    case getMembers
    case addMember(data: UserData)
    case editMember(id: Int, data: UserData)
    case deleteMember(id: Int)
    case login(email: String, password: String)
    case getEvents(date: Date)
    case addEvent(data: SubmitEvent)
    case editEvent(id: Int, data: SubmitEvent)
    case deleteEvent(id: Int)
    
    public var baseURL: URL {
        return URL(string: "https://guardguys.herokuapp.com")!
    }
    
    public var path: String {
        switch self {
            
        case .login(_, _):
            return "/api/users/login"
            
        case .getMembers, .addMember:
            return "/api/users/"
            
        case let .editMember(id, _):
            return "/api/users/\(id)"
            
        case let .deleteMember(id):
            return "/api/users/\(id)"
            
        case let .getEvents(date):
            return "/api/events/weekof/\(stringDate(from: date))"
            
        case .addEvent:
            return "/api/events/"
            
        case let .editEvent(id, _):
            return "/api/events/\(id)"
            
        case let .deleteEvent(id):
            return "/api/events/\(id)"
        }
    }
    
    public var method: MethodTypes {
        switch self {
        case .getMembers, .getEvents:
            return .get
        case .addMember, .login, .addEvent:
            return .post
        case .editMember, .editEvent:
            return .put
        case .deleteMember, .deleteEvent:
            return .delete
        }
    }
    
    public var parameters: [String : Any]? {
        
        switch self {
        case .getMembers, .deleteMember, .getEvents, .deleteEvent: return nil
            
        case let .login(email, password):
            var dict: [String:Any] = [:]
            dict["email"] = email
            dict["password"] = password
            return dict
            
        case let .addMember(data):
            var dict: [String:Any] = [:]
            if data.username != nil { dict["username"] = data.username }
            if data.email != nil { dict["email"] = data.email }
            if data.password != nil || data.password == "" { dict["password"] = data.password }
            if data.isAdmin != nil { dict["isAdmin"] = data.isAdmin }
            return dict
            
            
        case let .editMember( _, data):
            var dict: [String:Any] = [:]
            if data.username != nil { dict["username"] = data.username }
            if data.email != nil { dict["email"] = data.email }
            if data.password != nil && data.password != "" { dict["password"] = data.password }
            if data.isAdmin != nil { dict["isAdmin"] = data.isAdmin }
            return dict
            
        case let .editEvent(_, data):
            var dict: [String:Any?] = [:]
            if data.date != nil { dict["date"] = data.date }
            if data.event != nil { dict["event"] = data.event }
            if data.onsite != nil { dict["onsite"] = data.onsite }
            if data.notes != nil { dict["notes"] = data.notes }
            if data.duration != nil { dict["duration"] =  data.duration }
            if data.userId != nil {
                dict["user_id"] = data.userId == -1 ? nil as Any? : data.userId }
            return dict as [String : Any]
            
        case let .addEvent(data):
            var dict: [String:Any?] = [:]
            if data.date != nil { dict["date"] = data.date }
            if data.event != nil { dict["event"] = data.event }
            if data.onsite != nil { dict["onsite"] = data.onsite }
            if data.notes != nil { dict["notes"] = data.notes }
            if data.duration != nil { dict["duration"] =  data.duration }
            if data.userId != nil { dict["user_id"] = data.userId == -1 ? nil as Any? : data.userId }
            return dict as [String : Any]
            
        }
        
        
    }
    
    public var paramType: String {
        switch self {
        case .getMembers, .deleteMember, .getEvents, .deleteEvent:
            return "url"
        case .addMember, .editMember, .login, .addEvent, .editEvent:
            return "body"
        }
    }
    
 
}
    
public protocol RequestTypeProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var method: MethodTypes { get }
    var paramType: String { get }
    
}

public enum MethodTypes: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public struct UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case id, username, email, password, isAdmin, createdAt, updatedAt
    }
    
    let id: Int?
    let username: String?
    let email: String?
    let password: String?
    let isAdmin: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    let uuid: UUID
    
    init(id: Int?, username: String?, email: String?, password: String?, isAdmin: Bool?, createdAt: String?, updatedAt: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.isAdmin = isAdmin
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.uuid = UUID()
    }
    
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(Int.self, forKey: .id)
        self.username = try values.decodeIfPresent(String.self, forKey: .username)
        self.email = try values.decodeIfPresent(String.self, forKey: .email)
        self.password = try values.decodeIfPresent(String.self, forKey: .password)
        self.isAdmin = try values.decodeIfPresent(Bool.self, forKey: .isAdmin)
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        self.uuid = UUID()
    }
}

public struct LoginResult: Codable {
    let user: UserData?
    let message: String?
}

public struct ScheduleEvent: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id, date, event, onsite, notes, duration, createdAt, updatedAt, user
        case userId = "user_id"
    }
    
    let uuid = UUID()
    let id: Int
    let date: String
    let event: String
    let onsite: Bool
    let notes: String
    let duration: Int64
    let userId: Int?
    let createdAt: String
    let updatedAt: String
    let user: UserData?
}

enum NetworkErrors: String, Error {
    case emailValidation = "Unable able to validate email format. Please try again."
    case usernameValidation = "The user name must be at least 3 letters!"
    case passwordValidation = "The password must be at least 3 letters!"
    case jsonEncoder = "Unable to encode json"
    case jsonDecoder = "The system is unable to decode the received json"
    case invalidUrl = "The url is invalid"
    case networkFailure = "Unable to get a valid return from the server"
    case invalidResponse = "The response was invalid"
    case notInstructor = "This user is not an instructor"
    case unauthorized = "The user is no longer authrorized"
    case pdfConversion = "Unable to convert the data to pdf"
    case unknownError = "This operation caused an unknown error, please try again."
}



struct ErrorResponse: Codable {
    let name: String
    let errors: [ErrorData]?
   
}

struct ErrorData: Codable {
    let message: String?
    let type: String?
    let path: String?
    let value: String?
    let origin: String?
}

