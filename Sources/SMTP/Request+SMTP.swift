

import Vapor

public extension Request {
    var smtp: SMTP {
        return SMTP(application: application, on: self.eventLoop)
    }
}

