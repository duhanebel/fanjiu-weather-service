//
//  SocketAddress.swift
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

extension String {
    private func isValidIPAddress() -> Bool {
        return (URL(string: self) != nil)
    }
    var isValidIPv4: Bool {
        return (self.isValidIPAddress() && self.components(separatedBy: ".").count == 4)
    }
}

/// A wrapper around the `sockaddr`, `sockaddr_in`, and `sockaddr_in6` family of structs.
///
/// It provides storage for any socket address and implements methods that allow using that
/// storage as a pointer to a "generic" `sockaddr` struct.
struct SocketAddress {
   
    let address: sockaddr_in
    
    static var length: socklen_t {
        return socklen_t(MemoryLayout<sockaddr_in>.size)
    }
    
    /// Creates either a `Version4` or `Version6` socket address, depending on what `addressProvider` does.
    ///
    /// This initializer calls the given `addressProvider` with an `UnsafeMutablePointer<sockaddr>` that points to a buffer
    /// that can hold either a `sockaddr_in` or a `sockaddr_in6`. After `addressProvider` returns, the pointer is
    /// expected to contain an address. For that address, a `SocketAddress` is then created.
    ///
    /// This initializer is intended to be used with `Darwin.accept()`.
    ///
    /// - Parameter addressProvider: A closure that will be called and is expected to fill in an address into the given buffer.
    init?(addressProvider: (UnsafeMutablePointer<sockaddr>, UnsafeMutablePointer<socklen_t>) throws -> Void) {
        
        // `sockaddr_storage` is an abstract type that provides storage large enough for any concrete socket address struct:
        var addressStorage = sockaddr_storage()
        var addressStorageLength = socklen_t(MemoryLayout<sockaddr_storage>.size)
        
        let pStorage = UnsafeMutableRawPointer(&addressStorage).assumingMemoryBound(to: sockaddr.self)
        let pLength = UnsafeMutablePointer<socklen_t>(&addressStorageLength)
        
        do {
            try addressProvider(pStorage, pLength)
        } catch {
            return nil
        }

        guard addressStorage.ss_family == AF_INET else {
            return nil
        }
#if os(Linux)
        assert(MemoryLayout<sockaddr_storage>.size == SocketAddress.length)
#else
        assert(socklen_t(addressStorage.ss_len) == SocketAddress.length)
#endif
        let address = UnsafeMutableRawPointer(&addressStorage).assumingMemoryBound(to: sockaddr_in.self)
        self.address = address.pointee
            
    }
    
    init?(with storage: sockaddr_storage) {
        var stor = storage
        guard storage.ss_family == PF_INET else {
            return nil
        }
        let addr_in = withUnsafePointer(to: &stor) {
            $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                $0.pointee
            }
        }
        self.address = addr_in
    }
    
    init?(with address: String, port: UInt16) {
        var addr_in = sockaddr_in()
        
        guard address.isValidIPv4 else {
            return nil
        }
        
#if os(macOS)
        addr_in.sin_len = UInt8(MemoryLayout.size(ofValue: addr_in))
#endif
        addr_in.sin_family = sa_family_t(AF_INET)
        addr_in.sin_addr.s_addr = inet_addr(address)
        addr_in.sin_port = SocketAddress.porthtons(port: in_port_t(port))
        self.address = addr_in
    }
    
    private static func porthtons(port: in_port_t) -> in_port_t {
#if os(Linux)
        return htons(port)
#else
        let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        return isLittleEndian ? _OSSwapInt16(port) : port
#endif
    }
    
    /// Makes a copy of `address` and calls the given closure with an `UnsafePointer<sockaddr>` to that.
    func withSockAddrPointer<Result>(body: (UnsafePointer<sockaddr>, socklen_t) throws -> Result) rethrows -> Result {
        var localAddress = address // We need a `var` here for the `&`.
        let local = UnsafeMutableRawPointer(&localAddress).assumingMemoryBound(to: sockaddr.self)
        return try body(local, socklen_t(MemoryLayout<sockaddr>.size))
    }
    
    /// Returns the host and port as returned by `getnameinfo()`.
    
    var host: String? {
        var buf = [CChar](repeating:0, count:256)
        let result = withSockAddrPointer { sockAddr, length in
            getnameinfo(sockAddr, length, &buf, socklen_t(buf.count), nil, 0, 0)
        }
        guard result != -1 else {
            return nil
        }
        return String(cString: buf)
        
    }
    
    var port: UInt16? {
        return address.sin_port.bigEndian
    }
    
}

extension SocketAddress: Equatable {
    static func == (lhs: SocketAddress, rhs: SocketAddress) -> Bool {
        return lhs.address.sin_addr.s_addr == rhs.address.sin_addr.s_addr &&
        lhs.address.sin_family == rhs.address.sin_family &&
        lhs.address.sin_port == rhs.address.sin_port 
    }
}

extension SocketAddress: CustomDebugStringConvertible {
    var debugDescription: String {
        let host = self.host ?? "X.X.X.X"
        let port = self.port ?? 0
        return "Address: \(host):\(port)"
    }
}
