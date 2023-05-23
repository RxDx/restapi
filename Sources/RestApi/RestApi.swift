import Foundation

/// An URLSessionProtocol that contains the method used to request data from network
public protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

/// An URLSession extension that conforms to URLSessionProtocol
extension URLSession: URLSessionProtocol {
}

/// A RestApiEncoder that contains the method used to serialize data from network
public protocol RestApiEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

/// A JSONEncoder extension that conforms to RestApiEncoder
extension JSONEncoder: RestApiEncoder {
}

/// A RestApiDecoder that contains the method used to deserialize data to network
public protocol RestApiDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

/// A JSONDecoder extension that conforms to RestApiDecoder
extension JSONDecoder: RestApiDecoder {
}


/// A class that provides easy REST requests with generics resources.
open class RestApi {
    
    /// An enum that contains all the error cases that RestApi suposes to throws.
    public enum RestApiError: Error {
        case invalidUrl
    }
    
    /// An enum that contains all the verbs supported by RestApi.
    public enum Verb: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    /// A string that will be concatenated with path, and will be used in every request, unless url parameter passed by the function is not nil.
    public private(set) var baseUrl: String
    /// A string that will be concatenated with baseUrl, and will be used in every request, unless path parameter passed by the function is not nil.
    public private(set) var path: String
    /// A dictionary that holds the header that will be used in every request.
    public private(set) var header: [String: String]
    /// A boolean flag that indicates if debug logs should be printed.
    public private(set) var debug: Bool
    /// A URLSession that will request data.
    private let urlSession: URLSessionProtocol
    /// A Encoder that will serialize your data.
    private let encoder: RestApiEncoder
    /// A Decoder that will deserialize your data.
    private let decoder: RestApiDecoder
    
    /// An init that is used to instanciate RestApi objects.
    /// - Parameters:
    ///   - baseUrl: A string that will be concatenated with path, and will be used in every request, unless url parameter passed by the function is not nil.
    ///   - path: A string that will be concatenated with baseUrl, and will be used in every request, unless path parameter passed by the function is not nil.
    ///   - header: A dictionary that holds the header that will be used in every request.
    ///   - debug: A boolean flag that will print debug logs if true.
    public init(
        baseUrl: String = "",
        path: String = "",
        header: [String: String] = [
            "Content-Type": "application/json; charset=utf-8",
            "Accept": "application/json; charset=utf-8"
        ],
        debug: Bool = false,
        urlSession: URLSessionProtocol = URLSession.shared,
        encoder: RestApiEncoder = JSONEncoder(),
        decoder: RestApiDecoder = JSONDecoder()
    ) {
        self.baseUrl = baseUrl
        self.path = path
        self.header = header
        self.debug = debug
        self.urlSession = urlSession
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: - GET
    
    /// A function that do an asynchronous throwable get request, accepts an resourceId parameter and returns an object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: An object of resource type.
    public func get<T: Codable>(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws -> T {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        let urlRequest = try buildUrlRequest(url: url, verb: .get, header: header)
        let data = try await data(for: urlRequest, debug: debug)
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - POST
    
    /// A function that do an asynchronous throwable post request, accepts an resource parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - resource: An optional object that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: An optional object of resource type.
    public func post<T: Codable, U: Codable>(
        url: String? = nil,
        path: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        resource: U? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws -> T? {
        let url = try buildUrl(url: url, path: path, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .post, header: header)
        if let resource = resource {
            urlRequest.httpBody = try encoder.encode(resource)
        }
        let data = try await data(for: urlRequest, debug: debug)
        return try? decoder.decode(T.self, from: data)
    }
    
    /// A function that do an asynchronous throwable post request, accepts an resource parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - resource: An optional object that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    public func post<T: Codable>(
        url: String? = nil,
        path: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        resource: T? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws {
        let url = try buildUrl(url: url, path: path, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .post, header: header)
        if let resource = resource {
            urlRequest.httpBody = try encoder.encode(resource)
        }
        let _ = try await data(for: urlRequest, debug: debug)
    }
    
    /// A function that do an asynchronous throwable post request, accepts an resource parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - payload: An optional dictionary that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: An optional object of resource type.
    public func post<T: Codable>(
        url: String? = nil,
        path: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        payload: [String: Any]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws -> T? {
        let url = try buildUrl(url: url, path: path, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .post, header: header)
        if let payload = payload {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload)
        }
        let data = try await data(for: urlRequest, debug: debug)
        return try? decoder.decode(T.self, from: data)
    }
    
    /// A function that do an asynchronous throwable post request, accepts an resource parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - payload: An optional dictionary that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    public func post(
        url: String? = nil,
        path: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        payload: [String: Any]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws {
        let url = try buildUrl(url: url, path: path, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .post, header: header)
        if let payload = payload {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload)
        }
        let _ = try await data(for: urlRequest, debug: debug)
    }
    
    // MARK: - PUT
    
    /// A function that do an asynchronous throwable put request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - resource: An optional object that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: An optional object of resource type.
    public func put<T: Codable, U: Codable>(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        resource: U? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws -> T? {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .put, header: header)
        if let resource = resource {
            urlRequest.httpBody = try encoder.encode(resource)
        }
        let data = try await data(for: urlRequest, debug: debug)
        return try? decoder.decode(T.self, from: data)
    }
    
    /// A function that do an asynchronous throwable put request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - resource: An optional object that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    public func put<T: Codable>(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        resource: T? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .put, header: header)
        if let resource = resource {
            urlRequest.httpBody = try encoder.encode(resource)
        }
        let _ = try await data(for: urlRequest, debug: debug)
    }
    
    /// A function that do an asynchronous throwable put request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - payload: An optional dictionary that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: An optional object of resource type.
    public func put<T: Codable>(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        payload: [String: Any]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws -> T? {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .put, header: header)
        if let payload = payload {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload)
        }
        let data = try await data(for: urlRequest, debug: debug)
        return try? decoder.decode(T.self, from: data)
    }
    
    /// A function that do an asynchronous throwable put request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - payload: An optional dictionary that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    public func put(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        payload: [String: Any]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .put, header: header)
        if let payload = payload {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload)
        }
        let _ = try await data(for: urlRequest, debug: debug)
    }
    
    
    // MARK: - PATCH
    
    /// A function that do an asynchronous throwable patch request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - resource: An optional object that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: An optional object of resource type.
    public func patch<T: Codable, U: Codable>(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        resource: U? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws -> T? {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .patch, header: header)
        if let resource = resource {
            urlRequest.httpBody = try encoder.encode(resource)
        }
        let data = try await data(for: urlRequest, debug: debug)
        return try? decoder.decode(T.self, from: data)
    }
    
    /// A function that do an asynchronous throwable patch request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - resource: An optional object that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    public func patch<T: Codable>(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        resource: T? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .patch, header: header)
        if let resource = resource {
            urlRequest.httpBody = try encoder.encode(resource)
        }
        let _ = try await data(for: urlRequest, debug: debug)
    }
    
    /// A function that do an asynchronous throwable patch request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - payload: An optional dictionary that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: An optional object of resource type.
    public func patch<T: Codable>(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        payload: [String: Any]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws -> T? {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .patch, header: header)
        if let payload = payload {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload)
        }
        let data = try await data(for: urlRequest, debug: debug)
        return try? decoder.decode(T.self, from: data)
    }
    
    /// A function that do an asynchronous throwable patch request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - payload: An optional dictionary that will be used in body request.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    public func patch(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        payload: [String: Any]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        var urlRequest = try buildUrlRequest(url: url, verb: .patch, header: header)
        if let payload = payload {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload)
        }
        let _ = try await data(for: urlRequest, debug: debug)
    }
    
    // MARK: - DELETE
    
    /// A function that do an asynchronous throwable delete request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: An optional object of resource type.
    public func delete<T: Codable>(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws -> T? {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        let urlRequest = try buildUrlRequest(url: url, verb: .delete, header: header)
        let data = try await data(for: urlRequest, debug: debug)
        return try? decoder.decode(T.self, from: data)
    }
    
    /// A function that do an asynchronous throwable delete request, accepts an resourceId parameter and returns an optional object.
    /// - Parameters:
    ///   - url: An optional string that will be concatenated with path, and will be used in the request url. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be concatenated with url, and will be used in the request url. If it's nil then self.path will be used.
    ///   - resourceId: An optional string that will be used in the request url unless it's not nil.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - params: An optional dictionary of query parameters that will be used in the request url.
    ///   - header: A dictionary that will be apprend to self.header dictionary and will be used as header in the request.
    ///   - debug: A boolean flag that will print debug logs if true.
    public func delete(
        url: String? = nil,
        path: String? = nil,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil,
        header: [String: String]? = nil,
        debug: Bool? = nil
    ) async throws {
        let url = try buildUrl(url: url, path: path, resourceId: resourceId, suffix: suffix, params: params)
        let urlRequest = try buildUrlRequest(url: url, verb: .delete, header: header)
        let _ = try await data(for: urlRequest, debug: debug)
    }
    
    // MARK: - COMMON
    
    /// A function that concatenates the string paramaters and returns an URL.
    /// - Parameters:
    ///   - url: An optional string that will be used as the first part of URL. If it's nil then self.baseUrl will be used.
    ///   - path: An optional string that will be used as the second part of URL. If it's nil then self.path will be used.
    ///   - suffix: An optional string that will be concatenated with url and path.
    ///   - resourceId: An optional string that will be used as the third part of URL unless it isn't nil.
    /// - Returns: An URL.
    private func buildUrl(
        url: String?,
        path: String?,
        resourceId: String? = nil,
        suffix: String? = nil,
        params: [String: String]? = nil
    ) throws -> URL {
        var urlString = "\(url ?? self.baseUrl)/\(path ?? self.path)"
        if let resourceId = resourceId {
            urlString += "/\(resourceId)"
        }
        if let suffix = suffix {
            urlString += suffix
        }
        guard var urlComponents = URLComponents(string: urlString) else {
            throw RestApiError.invalidUrl
        }
        if let params = params {
            urlComponents.queryItems = params.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        guard let url = urlComponents.url else {
            throw RestApiError.invalidUrl
        }
        return url
    }
    
    /// A function that receive the components parameters and builds an URLRequest with them.
    /// - Parameters:
    ///   - url: An URL.
    ///   - verb: An HTTP Verb.
    ///   - header: A dictionary that represents the header.
    /// - Returns: An URLRequest
    private func buildUrlRequest(
        url: URL,
        verb: Verb,
        header: [String: String]?
    ) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        self.header.forEach { (key, value) in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        header?.forEach { (key, value) in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        urlRequest.httpMethod = verb.rawValue
        return urlRequest
    }
    
    /// A function that requests the urlRequest and returns a data. An optional debug flag can be true and will print the request logs.
    /// - Parameters:
    ///   - urlRequest: An URLRequest.
    ///   - debug: A boolean flag that will print debug logs if true.
    /// - Returns: A response data.
    private func data(for urlRequest: URLRequest, debug: Bool?) async throws -> Data {
        let debug = debug ?? self.debug
        if debug {
            debugPrint("Request Verb: \(urlRequest.httpMethod ?? "Unknown Request Verb")")
            debugPrint("Request URL: \(urlRequest.url?.absoluteString ?? "Unknown Request URL")")
            debugPrint("Request Header: \(urlRequest.allHTTPHeaderFields?.description ?? "Unknown Request Header")")
            if let data = urlRequest.httpBody {
                debugPrint("Request Body: \(String(data: data, encoding: .utf8) ?? "Unknown Request Body")")
            } else {
                debugPrint("Request Body: Unknown Request Body")
            }
        }
        let (data, response) = try await urlSession.data(for: urlRequest, delegate: nil)
        if debug {
            debugPrint("Response: \(response.debugDescription)")
            debugPrint("Response Data:")
            debugPrint(String(data: data, encoding: .utf8) ?? "Unknown response data")
        }
        return data
    }
}
