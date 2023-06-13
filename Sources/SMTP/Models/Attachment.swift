

import Foundation

public enum ContentDisposition: String {
    case inline, attachment
}

public struct Attachment {
    let name: String
    let contentType: String
    let data: Data
    var disposition: ContentDisposition = .attachment
    /// Use this ID to reference inline attachements in email body
    /// - EXAMPLE: \<img src="cid:contentIdHere" /\>
    var contentId: String? = nil

    public init(name: String, contentType: String, data: Data, disposition: ContentDisposition = .attachment, contentId: String? = nil) {
        self.name = name
        self.contentType = contentType
        self.data = data
        self.disposition = disposition
        self.contentId = contentId
    }
}
