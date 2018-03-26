//
//  Modbus.swift
//  SmartHome
//
//  Created by ckd－macpro on 2018/3/21.
//  Copyright © 2018年 ckd－macpro. All rights reserved.
//


import Foundation


class Modbus: NSObject {
    var mb: OpaquePointer?
    var modbusQueue:DispatchQueue
    var ipAddress: NSString?
    
    init(ipAddress: NSString, port: Int32, device: Int32) {
        modbusQueue = DispatchQueue(label: "com.zyeasy.modbusQueue")
        super.init()
        setupTCP(ipAddress: ipAddress, port: port, device: device)
    }
    
    func setupTCP(ipAddress: NSString, port: Int32, device: Int32){
        self.ipAddress = ipAddress
        mb = modbus_new_tcp(ipAddress.cString(using: String.Encoding.ascii.rawValue) , port)
        var modbusErrorRecoveryMode = modbus_error_recovery_mode(0)
        modbusErrorRecoveryMode.rawValue = MODBUS_ERROR_RECOVERY_LINK.rawValue | MODBUS_ERROR_RECOVERY_PROTOCOL.rawValue
        modbus_set_error_recovery(mb!, modbusErrorRecoveryMode)
        modbus_set_slave(mb!, device)
    }
    
    func connectWithError(error:inout NSError) -> Bool {
        let ret = modbus_connect(mb!)
        if ret == -1 {
            error = self.buildNSError(errno:errno)
            return false
        }
        return true
    }
    
    func connect(success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            let ret = modbus_connect(self.mb!)
            if ret == -1 {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
            else {
                DispatchQueue.main.async() {
                    success()
                }
            }
        }
    }
    
    func disconnect() {
        modbus_close(mb!)
    }
    
    func readBitsFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject])-> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            let tab_reg: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(count))
            if modbus_read_bits(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                for i in 0...count{
                    returnArray.add(Int(tab_reg[Int(i)]))
                }
                DispatchQueue.main.async() {
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
        }
    }
    
    func readInputBitsFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject])-> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            let tab_reg: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(count))
            if modbus_read_input_bits(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                for i in 0...count{
                    returnArray.add(Int(tab_reg[Int(i)]))
                }
                DispatchQueue.main.async() {
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
        }
    }
    
    func readRegistersFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            let tab_reg: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: Int(count))
            if modbus_read_registers(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                for i in 0...count{
                    returnArray.add(modbus_get_float_badc(&tab_reg[Int(i)]))
                }
                DispatchQueue.main.async() {
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
        }
    }

    func readInputRegistersFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            let tab_reg: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: Int(count))
            if modbus_read_input_registers(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                for i in 0...count{
                    returnArray.add(Int(tab_reg[Int(i)]))
                }
                DispatchQueue.main.async() {
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
        }
    }
    
    func writeBit(address: Int32, status: Bool, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            if modbus_write_bit(self.mb!, address, status ? 1 : 0) >= 0 {
                DispatchQueue.main.async() {
                    success()
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
        }
    }
    
    func writeBitsFromAndOn(address: Int32, numberArray: NSArray, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            let valueArray: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: numberArray.count)
            for i in 0...numberArray.count{
                valueArray[i] = UInt8(numberArray[i] as! Int)
            }
            
            if modbus_write_bits(self.mb!, address, Int32(numberArray.count), valueArray) >= 0 {
                DispatchQueue.main.async() {
                    success()
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
        }
    }
    
    func writeRegister(address: Int32, value: Int32, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            if modbus_write_register(self.mb!, address, value) >= 0 {
                DispatchQueue.main.async() {
                    success()
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
        }
    }

    func writeRegistersFromAndOn(address: Int32, numberArray: NSArray, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue.async() {
            let valueArray: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: numberArray.count)
            for i in 0...numberArray.count{
                valueArray[i] = UInt16(numberArray[i] as! Int)
            }
            
            if modbus_write_registers(self.mb!, address, Int32(numberArray.count), valueArray) >= 0 {
                DispatchQueue.main.async() {
                    success()
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async() {
                    failure(error)
                }
            }
        }
    }
    
    private func buildNSError(errno: Int32, errorString: NSString) -> NSError {
        let details = NSMutableDictionary()
        details.setValue(errorString, forKey: NSLocalizedDescriptionKey)
        let error = NSError(domain: "Modbus", code: Int(errno), userInfo: details as? [String : Any])
        return error
    }
    
    private func buildNSError(errno: Int32) -> NSError {
        let errorString = NSString(utf8String: modbus_strerror(errno))
        return self.buildNSError(errno: errno, errorString: errorString!)
    }
    
    deinit {
        modbus_free(mb!);
    }
}
