//
//  WeatherUDPServer.swift
//  Socket
//
//  Created by Fabio Gallonetto on 07/02/2019.
//

import Foundation
import Socket
import Dispatch

protocol RequestProcessor {
    func process(data: Data, from: String, port: Int) throws -> (data: Data, destIP: String, port: Int)?
}

class WeatherUDPServer {
    
    static let bufferSize = 4096
    
    let requestProcessor: RequestProcessor
    let port: Int
    var listenSocket: Socket? = nil
    var continueRunningValue = true
    var connectedSockets = [Int32: Socket]()
    let socketLockQueue = DispatchQueue(label: "com.duhanebel.udpServer.socketLockQueue")
    var continueRunning: Bool {
        set(newValue) {
            socketLockQueue.sync { self.continueRunningValue = newValue }
        }
        get {
            return socketLockQueue.sync { self.continueRunningValue }
        }
    }
    
    init(port: Int, requestProcessor: RequestProcessor) {
        self.port = port
        self.requestProcessor = requestProcessor
    }
    
    deinit {
        // Close all open sockets...
        for socket in connectedSockets.values {
            socket.close()
        }
        self.listenSocket?.close()
    }
    
    func run() {
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async { [unowned self] in
            do {
                // Create an IPV6 socket...
                try self.listenSocket = Socket.create(family: .inet, type: .datagram, proto: .udp )
                
                guard let socket = self.listenSocket else {
                    print("Unable to open socket...")
                    return
                }
                
                print("Listening on port: \(socket.listeningPort)")
                repeat {
                    var data = Data()
                    try socket.listen(on: self.port, maxBacklogSize: Socket.SOCKET_DEFAULT_MAX_BACKLOG, allowPortReuse: false, node: "10.1.0.57")
                    print(socket.signature)
                    //let (bytes, address) = try socket.readDatagram(into: &data)
                    let (bytes, address) = try socket.listen(forMessage: &data, on: self.port, maxBacklogSize: Socket.SOCKET_DEFAULT_MAX_BACKLOG)
                    
                    print("Read \(bytes) from \(String(describing: address))")
                    self.processData(socket: socket, data: data, from: address!) // TODO handle

                } while self.continueRunning
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error...")
                    return
                }
                
                if self.continueRunning {
                    print("Error reported:\n \(socketError.description)")
                }
            }
        }
        dispatchMain()
    }
    
    func processData(socket: Socket, data: Data, from address: Socket.Address) {

        // Get the global concurrent queue...
        let queue = DispatchQueue.global(qos: .default)

        // Create the run loop work item and dispatch to the default priority global queue...
        queue.async { [unowned self, socket] in

            do {
                let (sender, port) = Socket.hostnameAndPort(from: address)! // TODO handle
                if let response = try self.requestProcessor.process(data: data, from: sender, port: Int(port)) {
                    let address = Socket.createAddress(for: response.destIP, on: Int32(response.port))! // TODO handle
                    try socket.write(from: response.data, to: address)
                }
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                if self.continueRunning {
                    print("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
    
    func shutdownServer() {
        print("\nShutdown in progress...")
        
        self.continueRunning = false
     
        // Close all open sockets...
        for socket in connectedSockets.values {
            
            self.socketLockQueue.sync { [unowned self, socket] in
                self.connectedSockets[socket.socketfd] = nil
                socket.close()
            }
        }
        
        DispatchQueue.main.sync {
            exit(0)
        }
    }
}


