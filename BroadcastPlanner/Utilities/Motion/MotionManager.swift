//
//  MotionManager.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 13.10.2023.
//

import SwiftUI
import CoreMotion

final class MotionManager: ObservableObject {
    
    private let motionManager = CMMotionManager()
    
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var yaw: Double = 0.0
    
    func startMonitoringMotionUpdates(){
        guard self.motionManager.isDeviceMotionAvailable else {
            print("Device motion not available")
            return
        }
        
        self.motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion else {
                return
            }
            
            self.pitch = motion.attitude.pitch
            self.roll = motion.attitude.roll
            self.yaw = motion.attitude.yaw
        }
    }
    
    func stopMonitoringMotionUpdates(){
        self.motionManager.stopDeviceMotionUpdates()
    }
    
}
