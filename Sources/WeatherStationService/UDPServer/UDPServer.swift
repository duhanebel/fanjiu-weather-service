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

protocol UDPRequestHandler {
    func process(data: Data, from: SocketAddress) throws -> (data: Data, to: SocketAddress)?
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
    
    func start() throws {
        
        //var temp = [CChar](repeating: 0, count: 255)
        
        // create addrinfo based on hints
        // if host name is nil or "" we can connect on localhost
        // if host name is specified ( like "computer.domain" ... "My-MacBook.local" )
        // than localhost is not aviable.
        var temp = [CChar](repeating: 0, count: 255)

        let hosts: [String]
        if let bindIP = self.bindIP {
            hosts = [bindIP]
        } else {
            gethostname(&temp, temp.count)
            hosts = ["localhost", String(cString: temp)]
        }
        
        var hints = addrinfo()
        hints.ai_flags = 0
        hints.ai_family = PF_UNSPEC
        hints.ai_socktype = SOCK_DGRAM
        hints.ai_protocol = IPPROTO_UDP
        
        print("Server bound to:")
        for host in hosts {
            
            print("\t\(host)")
            print()
            
            // retrieve the info
            // getaddrinfo will allocate the memory, we are responsible to free it!
            
            var info: UnsafeMutablePointer<addrinfo>?
            defer {
                if info != nil {
                    freeaddrinfo(info)
                }
            }
            
            let status: Int32 = getaddrinfo(host, String(bindPort), nil, &info)
            guard status == 0 else {
                throw Error.unableToBind(String(cString: gai_strerror(errno)))
            }
            
            var p = info
            var serverSocket: Int32 = 0
            var i = 0

            // for each address avaiable
            
            while p != nil {
                
                i += 1
                
                // use local copy of info
                
                var _info = p!.pointee
                p = _info.ai_next
                // (1) create server socket
                
                serverSocket = socket(_info.ai_family, _info.ai_socktype, _info.ai_protocol)
                if serverSocket < 0 {
                    continue
                }
                
                // Ignore ipv6
                guard _info.ai_family == PF_INET else {
                    continue
                }
                
                _info.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { p in
                    p.pointee.sin_port = bindPort.bigEndian
                })

                // (2) bind
                //
                // associates a socket with a socket address structure, i.e. a specified local port number and IP address
                // if port is set to 0, bind will set first free port for us and update
                
                if bind(serverSocket, _info.ai_addr, _info.ai_addrlen) < 0 {
                    close(serverSocket)
                    continue
                }
                
                // (3) we need to know an actual address and port number after bind
                
                if getsockname(serverSocket, _info.ai_addr, &_info.ai_addrlen) < 0 {
                    close(serverSocket)
                    continue
                }
                
                // (4) retrieve the address and port from updated _info
               
                guard _info.ai_family == PF_INET else {
                    continue
                }
                
                
                try _info.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { p in
                    inet_ntop(AF_INET, &p.pointee.sin_addr, &temp, socklen_t(temp.count))
                    guard bindPort == p.pointee.sin_port.bigEndian else {
                        throw Error.unableToBind("Unable to bind to port \(bindPort)")
                    }
                })

                // Close al lsiening sockets
                
                if listen(serverSocket, 5) < 0 {} else {
                    close(serverSocket)
                    continue
                }
                
                print("\tsocket \(serverSocket)\tIPv4\t\(String(cString: temp))/\(bindPort)")
                
                // (6) enable receiving data
                // by installing event handler for a socket
                
                let serverSource = DispatchSource.makeReadSource(fileDescriptor: serverSocket)
                serverSource.setEventHandler {
                    
                    var info = sockaddr_storage()
                    var len = socklen_t(MemoryLayout<sockaddr_storage>.size)
                    
                    let s = Int32(serverSource.handle)
                    var buffer = [UInt8](repeating:0, count: 1024)
                    
                    withUnsafeMutablePointer(to: &info, { (pinfo) -> () in
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
                        
                        do {
                            guard let (replyData, replyAddress) = try self.requestProcessor.process(data: receivedData, from: address) else {
                                print("No data to reply for this packet")
                                return
                            }

                            print("Replying to packet")
                            var replyBuffer = Array<UInt8>(replyData)
                            var replyIn_addr = replyAddress.address
                            let replyAddr_in = UnsafeMutableRawPointer(&replyIn_addr).assumingMemoryBound(to: sockaddr.self)
                            
                            print("Sending to: \(replyAddress.host!):\(replyAddress.port!)")
                            var sentCount = 0
                            repeat {
                                let sent = sendto(s, &replyBuffer + sentCount, received - sentCount, 0, replyAddr_in, len)
                                guard sent > 0 else {
                                    return
                                }
                                sentCount += sent
    
                            } while sentCount < replyBuffer.count
                        } catch {
                            print("Error while processing request data: \(error)")
                            return
                        }
                    })
                }
                serverSources[serverSocket] = serverSource
                serverSource.resume()
                
            }
        }
        
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

