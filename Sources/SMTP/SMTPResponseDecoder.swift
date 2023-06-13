

import NIO

enum SMTPResponseDecoderError: Error {
    case malformedMessage
}

final class SMTPResponseDecoder: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = SMTPResponse
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var response = self.unwrapInboundIn(data)
        
        if let firstFourBytes = response.readString(length: 4), let code = Int(firstFourBytes.dropLast()) {
            let remainder = response.readString(length: response.readableBytes) ?? ""
            
            let firstChar = firstFourBytes.first!
            let fourthChar = firstFourBytes.last!
            
            switch (firstChar, fourthChar) {
            case ("2", " "), ("3", " "):
                let parsedMessage = SMTPResponse.ok(code, remainder)
                context.fireChannelRead(self.wrapInboundOut(parsedMessage))
            case(_,"-"):
                ()
            default:
                context.fireChannelRead(self.wrapInboundOut(.error(firstFourBytes + remainder)))
            }
        }
        else {
            context.fireErrorCaught(SMTPResponseDecoderError.malformedMessage)
        }
    }
}
