import Foundation
import NIO

public struct Email {
    public let from: EmailAddress
    public let to: [EmailAddress]
    public let cc: [EmailAddress]?
    public let bcc: [EmailAddress]?
    public let subject: String
    public let body: String
    public let plainTextBody: String?
    public let replyTo: EmailAddress?
    internal var attachments: [Attachment] = []

    public init(from: EmailAddress,
                to: [EmailAddress],
                cc: [EmailAddress]? = nil,
                bcc: [EmailAddress]? = nil,
                subject: String,
                body: String,
                plainTextBody: String? = nil,
                replyTo: EmailAddress? = nil
    ) {
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.body = body
        self.plainTextBody = plainTextBody
        self.replyTo = replyTo
    }
    
    public mutating func addAttachment(_ attachment: Attachment) {
        self.attachments.append(attachment)
    }
    
    internal func write(to out: inout ByteBuffer) {
        let date = Date()
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_GB")
        
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let formattedDate = df.string(from: date)
        
        out.writeString("From: \(self.formatMIME(emailAddress: self.from))\r\n")
        
        let toAddresses = self.to.map { self.formatMIME(emailAddress: $0)}.joined(separator: ", ")
        out.writeString("To: \(toAddresses)\r\n")
        
        if let cc = self.cc {
            let ccAddresses = cc.map { self.formatMIME(emailAddress: $0)}.joined(separator: ", ")
            out.writeString("Cc: \(ccAddresses)\r\n")
        }
        
        if let replyTo = self.replyTo {
            out.writeString("Reply-to: \(self.formatMIME(emailAddress: replyTo))\r\n")
        }
        
        out.writeString("Subject: \(self.subject)\r\n")
        out.writeString("Date: \(formattedDate)\r\n")
        out.writeString("Message-ID: <\(date.timeIntervalSince1970)\(self.from.address.drop { $0 != "@" })>\r\n")
        
        let mixedBoundary = self.boundary()
        out.writeString("Content-type: multipart/mixed; boundary=\"\(mixedBoundary)\"\r\n")
        out.writeString("Mime-Version: 1.0\r\n\r\n")
        
        out.writeString("--\(mixedBoundary)\r\n")
        
        let relatedBoundary = self.boundary()
        if self.attachments.filter({$0.disposition == .inline}).count > 0 {
            
            out.writeString("Content-type: multipart/related; boundary=\"\(relatedBoundary)\"\r\n")
            out.writeString("Mime-Version: 1.0\r\n\r\n")
            
            out.writeString("--\(relatedBoundary)\r\n")
        }
        let altBoundary = self.boundary()
        out.writeString("Content-type: multipart/alternative; boundary=\"\(altBoundary)\"\r\n")
        out.writeString("Mime-Version: 1.0\r\n\r\n")
        
        if let plainTextBody = self.plainTextBody {
            out.writeString("--\(altBoundary)\r\n")
            out.writeString("Content-Type: text/plain; charset=\"UTF-8\"\r\n\r\n")
            out.writeString("\(plainTextBody)\r\n")
        }
        
        out.writeString("--\(altBoundary)\r\n")
        
        
        
        out.writeString("Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n")
        out.writeString("\(self.body)\r\n")
        
        //End Alternative
        out.writeString("--\(altBoundary)--\r\n")
        
        if self.attachments.filter({$0.disposition == .inline}).count > 0 {
            for attachment in self.attachments.filter({$0.disposition == .inline}) {
                let disp = attachment.disposition.rawValue
                out.writeString("--\(relatedBoundary)\r\n")
                out.writeString("Content-type: \(attachment.contentType)\r\n")
                out.writeString("Content-Transfer-Encoding: base64\r\n")
                if attachment.contentId != nil {
                    out.writeString("Content-ID: <\(attachment.contentId!)>\r\n")
                }
                out.writeString("Content-Disposition: \(disp); filename=\"\(attachment.name)\"\r\n\r\n")
                out.writeString("\(attachment.data.base64EncodedString(options: .lineLength76Characters))\r\n")
            }
            
            out.writeString("--\(relatedBoundary)--\r\n")
            
            
        }
        
        
        if self.attachments.filter({$0.disposition == .attachment}).count > 0 {
            for attachment in self.attachments.filter({$0.disposition == .attachment}) {
                let disp = attachment.disposition.rawValue
                out.writeString("--\(mixedBoundary)\r\n")
                out.writeString("Content-type: \(attachment.contentType)\r\n")
                out.writeString("Content-Transfer-Encoding: base64\r\n")
                if attachment.contentId != nil {
                    out.writeString("Content-ID: <\(attachment.contentId!)>\r\n")
                }
                out.writeString("Content-Disposition: \(disp); filename=\"\(attachment.name)\"\r\n\r\n")
                out.writeString("\(attachment.data.base64EncodedString(options: .lineLength76Characters))\r\n")
            }
            
        }
        
        out.writeString("--\(mixedBoundary)--\r\n.")
    }
    
    private func boundary() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }

    func formatMIME(emailAddress: EmailAddress) -> String {
        if let name = emailAddress.name {
            return "\(name) <\(emailAddress.address)>"
        } else {
            return emailAddress.address
        }
    }
}
