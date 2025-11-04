//
//  ConnectionType.swift
//  HonestHouse
//
//  Created by Rama on 11/3/25.
//

import SwiftUI

enum ConnectionType {
    case bluetooth
    case ip
    
    var buttonImage: Image {
        switch self {
        case .bluetooth:
            return Image("bluetoothIcon")
        case .ip:
            return Image("addressIcon")
        }
    }
    
    var title: String {
        switch self {
        case .bluetooth:
            return "블루투스"
        case .ip:
            return "주소"
        }
    }
    
    var guideTitle: String {
        switch self {
        case .bluetooth:
            return "블루투스 연결"
        case .ip:
            return "IP 주소 연결"
        }
    }
    
    var guideDescription: [String] {
        switch self {
        case .bluetooth:
            return [
                "카메라의 전원을 켜주세요.",
                "휴대폰의 Wi-Fi를 켜고, 해당 카메라를 네트워크에 연결하세요.",
                "페어링 할 카메라를 선택하세요."
            ]
        
        //TODO: font color 다른 string 추가, 내용 수정 필요
        case .ip:
            return [
                "카메라의 전원을 켜주세요.",
                "휴대폰의 Wi-Fi를 켜고, 해당 카메라를 네트워크에 연결하세요.",
                "카메라 화면에 표시된 통신 주소(IP)를 입력해주세요.",
                "휴대폰의 Wi-Fi를 켜고, 해당 카메라를 네트워크에 연결하세요.",
                "입력 후 연결하기 버튼을 누르면, 카메라와 통신이 시작됩니다.\n연결 중 잠시 끊길 수 있으니 화면을 닫지 마세요."
            ]
        }
    }
}
