//
//  UDPServer.swift
//  Socket
//
//  Created by Fabio Gallonetto on 09/02/2019.
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation

import Dispatch
#if os(macOS)
typealias DispatchSourceHandler = DispatchSource.DispatchSourceHandler
#endif


enum Result<R> {
    case success(R)
    case error(Error)
}

typealias ResultCompletion<T> = (Result<T>) -> Void

struct UDPRequestHandlerResponse {
    let data: Data
    let to: SocketAddress
}

protocol UDPRequestHandler {

    func process(data: Data, from: SocketAddress, completion: @escaping ResultCompletion<UDPRequestHandlerResponse?>)
}


class UDPServer {
    
    enum Error: Swift.Error {
        case invalidIPv4(String)
        case unableToBind(String)
    }
    
    // syncQueue help us print and read/write safely from our internal storage
    // while running, the main queue is blocking with readLine()
    
    private let syncQueue = DispatchQueue(label: "syncQueue")
    
    // to be able maintain curren status of all DispatchSources
    // we store all the information here
    
    var serverSources:[Int32:DispatchSourceRead] = [:]
    
    var requestProcessor: UDPRequestHandler
    
    init(processor: UDPRequestHandler, bindIP: String?, bindPort: UInt16) throws {
        if let bindIP = bindIP {
            guard bindIP.isValidIPv4 else {
                throw Error.invalidIPv4(bindIP)
            }
        }
        self.bindIP = bindIP
        self.bindPort = bindPort
        self.requestProcessor = processor
    }
    
    deinit {
        // first stop the server !!
        stop()
        print("UDP Server deinit")
    }
    
    let bindPort: UInt16
    let bindIP: String?
   
    static func getHostname() -> String {
        var buf = [CChar](repeating: 0, count: 255)
        gethostname(&buf, buf.count)
        return String(cString:buf)
    }
    
    func start() throws {
        let hosts: [String]
        if let bindIP = self.bindIP {
            hosts = [bindIP]
        } else {
            hosts = ["localhost", UDPServer.getHostname()]
        }
        
        print("Server bound to:")
        for host in hosts {
            
            print("\t\(host)")
            print()
            
            // retrieve the info
            // getaddrinfo will allocate the memory, we are responsible to free it!
            
            var info: UnsafeMutablePointer<addrinfo>?
            defer {
                if info != nil { freeaddrinfo(info) }
            }
            
            let status: Int32 = getaddrinfo(host, String(bindPort), nil, &info)
            guard status == 0 else {
                throw Error.unableToBind(String(cString: gai_strerror(errno)))
            }
            
            var info_cursor = info

            // for each address avaiable
            while info_cursor != nil {
                guard let current_addrinfo = info_cursor?.pointee else { continue }
                do {
                    try self.bindTo(address: current_addrinfo)
                } catch {
                    info_cursor = current_addrinfo.ai_next
                    continue
                }
                info_cursor = current_addrinfo.ai_next
            }
        }
    }
    
    private enum SocketError: Swift.Error {
        case unableToBind
    }
    
    private func bindTo(address: addrinfo) throws {
        // (1) create server socket
        var address_info = address
        let serverSocket = socket(address_info.ai_family, address_info.ai_socktype, address_info.ai_protocol)
        guard serverSocket >= 0 else { throw SocketError.unableToBind }
        
        // Ignore ipv6
        guard address_info.ai_family == PF_INET else { return }
        
        address_info.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, {
            $0.pointee.sin_port = bindPort.bigEndian
        })
        
        // (2) bind
        //
        // associates a socket with a socket address structure, i.e. a specified local port number and IP address
        // if port is set to 0, bind will set first free port for us and update
        guard bind(serverSocket, address_info.ai_addr, address_info.ai_addrlen) >= 0 else {
            close(serverSocket)
            throw SocketError.unableToBind
        }
        
        // (3) we need to know an actual address and port number after bind
        guard getsockname(serverSocket, address_info.ai_addr, &address_info.ai_addrlen) >= 0 else {
            close(serverSocket)
            throw SocketError.unableToBind
        }
        
        // (4) retrieve the address and port from updated _info
        guard address_info.ai_family == PF_INET else { return }
        
        var buf = Array<CChar>(repeating: 0, count: 255)
        try address_info.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { p in
            inet_ntop(AF_INET, &p.pointee.sin_addr, &buf, socklen_t(buf.count))
            guard bindPort == p.pointee.sin_port.bigEndian else {
                throw Error.unableToBind("Unable to bind to port \(bindPort)")
            }
        })
        
        // Close al listening sockets
        
        if listen(serverSocket, 5) < 0 {} else {
            close(serverSocket)
            throw Error.unableToBind("Unable to bind to port \(bindPort)")
        }
        
        print("\tsocket \(serverSocket)\tIPv4\t\(String(cString: buf))/\(bindPort)")
        
        // (6) enable receiving data
        // by installing event handler for a socket
        
        let serverSource = DispatchSource.makeReadSource(fileDescriptor: serverSocket)
        serverSource.setEventHandler(handler: self.newEventHandler(for: serverSource))
        
        serverSources[serverSocket] = serverSource
        serverSource.resume()
    }
    private func newEventHandler(for serverSource: DispatchSourceRead) -> DispatchSourceHandler {
        return { ()->() in
            var info = sockaddr_storage()
            var len = socklen_t(MemoryLayout<sockaddr_storage>.size)
    
            let s = Int32(serverSource.handle)
            var buffer = [UInt8](repeating:0, count: 1024)
    
            withUnsafeMutablePointer(to: &info) { (pinfo) -> () in
                let paddr = UnsafeMutableRawPointer(pinfo).assumingMemoryBound(to: sockaddr.self)
                let received = recvfrom(s, &buffer, buffer.count, 0, paddr, &len)
    
                guard let address = SocketAddress(with: pinfo.pointee) else {
                    print("Received data but can't parse source IP - discarding")
                    return
                }
    
                guard received > 0 else {
                    print("Received no data")
                    return
                }
    
                print("Receive data from: \(address.host!) \(address.port!)")
                let receivedData = Data(bytes: buffer, count: received)
    
                self.requestProcessor.process(data: receivedData, from: address) { result in
                   
                    switch(result) {
                    case .error(let error):
                        print("Error crafting the response: \(error)")
                        return
                    case .success(let response):
                        guard let response = response else {
                            print("No data to reply for this packet")
                            return
                        }
                        print("Replying to packet")
                        print("Sending to: \(response.to.host!):\(response.to.port!)")
                        self.sendData(over: s, data: response.data, to: response.to)
                        
                    }
                }
            }
        }
    }
    
    private func sendData(over handle: Int32, data: Data, to address: SocketAddress) {
        var replyBuffer = Array<UInt8>(data)
        var reply_addr = address.address
        let replyAddr_in = UnsafeMutableRawPointer(&reply_addr).assumingMemoryBound(to: sockaddr.self)
        let replyAddr_len = socklen_t(MemoryLayout.size(ofValue: replyAddr_in))
        var sentCount = 0
        repeat {
            let sent = sendto(handle, &replyBuffer + sentCount, replyBuffer.count - sentCount, 0, replyAddr_in, replyAddr_len)
            guard sent > 0 else { return }
            sentCount += sent
        } while sentCount < replyBuffer.count
    }
    
    func stop() {
        for (socket, source) in serverSources {
            source.cancel()
            close(socket)
            print(socket,"\tclosed")
            
        }
        serverSources.removeAll()
    }
}

