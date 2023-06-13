

import NIO
import NIOSSL

private let sslContext = try! NIOSSLContext(configuration: TLSConfiguration.makeClientConfiguration())

final class SendEmailHandler: ChannelInboundHandler {
    typealias InboundIn = SMTPResponse
    typealias OutboundIn = Email
    typealias OutboundOut = SMTPRequestAction
    
    enum Expect {
        case initialMessageFromServer
        case okForHello
        case okForStartTLS
        case okAfterStartTLSHello
        case tlsHandlerToBeAdded
        case okForAuthBegin
        case okAfterUsername
        case okAfterPassword
        case okAfterMailFrom
        case okAfterRecipient
        case okAfterDataCommand
        case okAfterMailData
        case okAfterQuit
        case nothing
    
        case error(Error)
    }
    
    private var currentlyWaitingFor = Expect.initialMessageFromServer {
        didSet {
            if case .error(let error) = self.currentlyWaitingFor {
                self.allDonePromise.fail(error)
            }
        }
    }
    
    private let email: Email
    private var recps = [EmailAddress]()
    private let serverConfiguration: SMTPServerConfig
    private let allDonePromise: EventLoopPromise<Void>
    private var useStartTLS: Bool {
        if case .startTLS = self.serverConfiguration.tlsConfiguration {
            return true
        }
        return false
    }
    
    init(configuration: SMTPServerConfig, email: Email, allDonePromise: EventLoopPromise<Void>) {
        self.email = email
        self.allDonePromise = allDonePromise
        self.serverConfiguration = configuration
        
        if email.bcc != nil {
            self.recps.append(contentsOf: email.bcc!)
        }
        if email.cc != nil {
            self.recps.append(contentsOf: email.cc!)
        }
        self.recps.append(contentsOf: email.to)
    }
    
    func send(context: ChannelHandlerContext, command: SMTPRequestAction) {
        context.writeAndFlush(self.wrapOutboundOut(command)).cascadeFailure(to: self.allDonePromise)
    }
    
    func sendAuthenticationStart(context: ChannelHandlerContext) {
        func goAhead() {
            self.send(context: context, command: .beginAuthentication)
            self.currentlyWaitingFor = .okForAuthBegin
        }
        
        switch self.serverConfiguration.tlsConfiguration {
        case .regularTLS:
            context.channel.pipeline.handler(type: NIOSSLClientHandler.self).map { (_:NIOSSLClientHandler) in
                goAhead()
            }.whenFailure { error in
                preconditionFailure("serious NIOSMTP bug: TLS handler should be present in \(self.serverConfiguration.tlsConfiguration) but SSL handler \(error)")
            }
        case .unsafeNoTLS, .startTLS:
            goAhead()
        }
        
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        self.allDonePromise.fail(ChannelError.eof)
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        self.currentlyWaitingFor = .error(error)
        self.allDonePromise.fail(error)
        context.close(promise: nil)
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let result = self.unwrapInboundIn(data)
        switch (result) {
        case .error(let message):
            self.allDonePromise.fail(SMTPError.mailSendError(message))
            return
        case .ok: ()
        }
        
        switch self.currentlyWaitingFor {
        case .initialMessageFromServer:
            self.send(context: context, command: .sayHello(serverName: self.serverConfiguration.hostname))
            self.currentlyWaitingFor = .okForHello
        case .okForHello:
            if self.useStartTLS {
                self.send(context: context, command: .startTLS)
                self.currentlyWaitingFor = .okForStartTLS
            }
            else {
                self.sendAuthenticationStart(context: context)
            }
        case .okAfterStartTLSHello:
            self.sendAuthenticationStart(context: context)
            
        case .okForStartTLS:
            self.currentlyWaitingFor = .tlsHandlerToBeAdded
            context.channel.pipeline.addHandler(try! NIOSSLClientHandler(context: sslContext, serverHostname: self.serverConfiguration.hostname), position: .first).whenComplete { result in
                guard case .tlsHandlerToBeAdded = self.currentlyWaitingFor else {
                    preconditionFailure("wrong state \(self.currentlyWaitingFor)")
                }
                
                switch result {
                case .failure(let error):
                    self.currentlyWaitingFor = .error(error)
                case .success:
                    self.send(context: context, command: .sayHello(serverName: self.serverConfiguration.hostname))
                    self.currentlyWaitingFor = .okAfterStartTLSHello
                }
            }
        case .okForAuthBegin:
            self.send(context: context, command: .authUser(self.serverConfiguration.username))
            self.currentlyWaitingFor = .okAfterUsername
        case .okAfterUsername:
            self.send(context: context, command: .authPassword(self.serverConfiguration.password))
            self.currentlyWaitingFor = .okAfterPassword
        case .okAfterPassword:
            self.send(context: context, command: .mailFrom(self.email.from.address))
            self.currentlyWaitingFor = .okAfterMailFrom
        case .okAfterMailFrom:
            let next = self.recps.removeFirst()
            self.send(context: context, command: .recipient(next.address))
            if self.recps.count > 0 {
                self.currentlyWaitingFor = .okAfterMailFrom
            }
            else {
                self.currentlyWaitingFor = .okAfterRecipient
            }
        case .okAfterRecipient:
            self.send(context: context, command: .data)
            self.currentlyWaitingFor = .okAfterDataCommand
        case .okAfterDataCommand:
            self.send(context: context, command: .transferData(self.email))
            self.currentlyWaitingFor = .okAfterMailData
        case .okAfterMailData:
            self.send(context: context, command: .quit)
            self.currentlyWaitingFor = .okAfterQuit
        case .okAfterQuit:
            self.allDonePromise.succeed(())
            context.close(promise: nil)
            self.currentlyWaitingFor = .nothing
        case .nothing:
            ()
        case .error:
            fatalError("error state")
        case .tlsHandlerToBeAdded:
            fatalError("bug in NIOTS: we shouldn't hit this state here")
        }
    }
}

enum SMTPError: Error {
    case mailSendError(String)
}
