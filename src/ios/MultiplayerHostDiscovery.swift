//
//  MultiplayerHostDiscovery.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 9/15/24.
//

import Combine
import Foundation

@objcMembers class BonjourServicePublisher: NSObject, NetServiceDelegate {
  static let shared = BonjourServicePublisher()
  
  private var netService: NetService?
  
  var serviceName = UIDevice.current.name
  
  var launcherVM: LauncherViewModel?
  
  func startPublishing(port: Int32) {
    netService = NetService(domain: "local.", type: "_genzd._tcp.", name: serviceName, port: port)
    netService?.delegate = self
    if let launcherVM, let selectedIWAD = launcherVM.selectedIWAD, let iwadStrData = selectedIWAD.displayName.data(using: .utf8)  {
      var txtDict: [String: Data] = [
        "iwad": iwadStrData
      ]
      if !launcherVM.selectedExternalFiles.isEmpty {
        let mods = launcherVM.selectedExternalFiles.map { $0.displayName }.joined(separator: ",")
        if let modsData = mods.data(using: .utf8) {
          txtDict["mods"] = modsData
        }
      }
      let txtData = NetService.data(fromTXTRecord: txtDict)
      netService?.setTXTRecord(txtData)
    }
    netService?.publish(options: .listenForConnections)
  }
  
  func stopPublishing() {
    netService?.stop()
  }
  
  // NetServiceDelegate methods
  func netServiceDidPublish(_ sender: NetService) {
    print("Service published: \(sender.name) at \(sender.hostName ?? "unknown host"):\(sender.port)")
  }
  
  func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
    print("Failed to publish service: \(errorDict)")
  }
}

// Usage
//let publisher = BonjourServicePublisher()
//publisher.startPublishing(serviceName: "My Custom Service", port: 8080)

// Remember to stop publishing when done
// publisher.stopPublishing()

struct DiscoveredService: Identifiable {
  let id = UUID()
  let netService: NetService
}

class BonjourServiceBrowser: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, ObservableObject {
   private var serviceBrowser: NetServiceBrowser
   @Published var discoveredServices: [DiscoveredService] = []

   override init() {
       serviceBrowser = NetServiceBrowser()
       super.init()
       serviceBrowser.delegate = self
   }

   func startBrowsing() {
       serviceBrowser.searchForServices(ofType: "_genzd._tcp.", inDomain: "local.")
   }

   func stopBrowsing() {
       serviceBrowser.stop()
   }

   // NetServiceBrowserDelegate methods
   func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
     discoveredServices.append(DiscoveredService(netService: service))
     service.delegate = self
     service.resolve(withTimeout: 5.0)
   }

   func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
     if let index = discoveredServices.firstIndex(where: { $0.netService == service }) {
           discoveredServices.remove(at: index)
       }
   }
  
  func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
    guard let index = discoveredServices.firstIndex(where: { $0.netService == sender}) else {
      return
    }
    let txtRecord = NetService.dictionary(fromTXTRecord: data)
    print("TXT Record updated for service \(sender.name): \(txtRecord)")
    sender.setTXTRecord(data)
    discoveredServices[index] = DiscoveredService(netService: sender)
  }

   // NetServiceDelegate methods
//   func netServiceDidResolveAddress(_ sender: NetService) {
//       if let addresses = sender.addresses {
//           for address in addresses {
//               var hostname = CChar)
//               var servInfo = CChar)
//               address.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
//                   let sockaddrPointer = pointer.baseAddress!.assumingMemoryBound(to: sockaddr.self)
//                   getnameinfo(sockaddrPointer, socklen_t(address.count), &hostname, socklen_t(hostname.count), &servInfo, socklen_t(servInfo.count), NI_NUMERICHOST | NI_NUMERICSERV)
//               }
//               let ipAddress = String(cString: hostname)
//               let port = String(cString: servInfo)
//               print("Resolved service: \(sender.name) at \(ipAddress):\(port)")
//           }
//       }
//   }

   func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
       print("Failed to resolve service: \(errorDict)")
   }
}
