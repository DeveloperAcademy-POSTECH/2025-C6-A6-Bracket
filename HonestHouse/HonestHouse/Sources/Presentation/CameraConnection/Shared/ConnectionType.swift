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
            return "블루투스 연결"
        case .ip:
            return "주소 연결"
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
                "카메라의 [MENU] 버튼을 눌러 메뉴를 표시하세요.",
                "‘연결 설정’ 탭에서 [스마트폰에 접속(태블릿)]을 선택하세요.",
                "[연결할 장치를 추가합니다]를 선택하세요.",
                "표시된 내용을 확인하고 [다음]을 눌러 ‘페어링’을 진행해주세요(연결 대기 중).",
                "앱 화면 하단에 ‘Bluetooth 연결하기'를 눌러 ‘Bluetooth 페어링 요청’을 승인해주세요.",
                "카메라에서 ‘이 스마트폰에 접속' 화면으로 전환되면 [OK]를 눌러주세요."
            ]
        
        //TODO: 연결 방법 추후 상세 기술
        case .ip:
            return [
                "카메라의 전원을 켜주세요.",
                "카메라의 네트워크 설정에서 연결을 활성화해주세요",
                "카메라 화면에 표시된 통신 주소(IP)를 상단에 입력해주세요.",
                "휴대폰의 Wi-Fi를 켜고, 해당 카메라 네트워크에 연결하세요.\n예: 196.100.1.2",
                "입력 후 연결하기 버튼을 누르면, 카메라와 통신이 시작됩니다.\n연결 중 잠시 끊길 수 있으니 화면을 닫지 마세요."
            ]
        }
    }
}
