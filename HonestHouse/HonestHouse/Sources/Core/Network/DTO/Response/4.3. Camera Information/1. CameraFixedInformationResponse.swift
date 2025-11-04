//
//  CameraFixedInformationResponse.swift
//  HonestHouse
//
//  Created by Rama on 11/4/25.
//

import Foundation

extension CameraInformation {
    
    struct CameraFixedInformationResponse: BaseResponse {
        let manufacturer: String?
        let productName: String?
        let guid: String?
        let serialNumber: String?
        let macAddress: String?
        let firmwareVersion: String?
        
        enum CodingKeys: String, CodingKey {
            case manufacturer
            case productName = "productname"
            case guid
            case serialNumber = "serialnumber"
            case macAddress = "macaddress"
            case firmwareVersion = "firmwareversion"
        }
    }
}

extension CameraInformation.CameraFixedInformationResponse {
    typealias EntityType = CameraFixedInformation
    
    func toEntity() -> CameraFixedInformation {
        CameraFixedInformation(
            manufacturer: manufacturer,
            productName: productName,
            guid: guid,
            serialNumber: serialNumber,
            macAddress: macAddress,
            firmwareVersion: firmwareVersion
        )
    }
    
    static var stub1: CameraInformation.CameraFixedInformationResponse {
        .init(
            manufacturer: "",
            productName: "",
            guid: "",
            serialNumber: "",
            macAddress: "",
            firmwareVersion: ""
        )
    }
}
