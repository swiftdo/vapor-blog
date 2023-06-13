
import NIO

public struct SMTPServerConfig {
    public enum TLSConfiguration {
        case startTLS
        case regularTLS
        case unsafeNoTLS
    }
    
    public var hostname: String
    public var port: Int
    public var username: String
    public var password: String
    public var tlsConfiguration: TLSConfiguration
    
    public init(hostname: String, port: Int, username: String, password: String, tlsConfiguration: TLSConfiguration) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.tlsConfiguration = tlsConfiguration
    }
    
   
}
