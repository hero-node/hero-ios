//
//  PacketTunnelProvider.swift
//  HeroTunnel
//
//  Created by 李潇 on 2019/2/15.
//Copyright © 2019 刘国平. All rights reserved.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
	

    func startTunnelWithOptions(options: [String : NSObject]?, completionHandler: (NSError?) -> Void) {
		
	}

    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject: AnyObject]?, context: UnsafeMutablePointer<Void>) {

		
	}

    func stopTunnelWithReason(reason: NEProviderStopReason, completionHandler: () -> Void) {

		completionHandler()
	}


}
