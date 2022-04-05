//
//  UUID.swift
//  Receptor
//

import Foundation


extension UUID {

    public static var incrementing: () -> UUID {
        var uuid = 0
        return {
            defer { uuid += 1 }
            return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuid))")!
        }
    }
}
