//
//  BaseService.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import Moya

/// 모든 CCAPI Service의 공통 기능을 제공하는 Base 클래스
class BaseService {
    private let networkManager: NetworkManager = NetworkManager.shared
    private let jsonDecoder = JSONDecoder()
    
    /// 응답이 있는 API 요청 (GET, PUT 등)
    /// NetworkManager가 401 재시도를 처리하므로 여기서는 디코딩만
    func request<T: Decodable, Target: TargetType>(
        _ target: Target,
        decoding: T.Type
    ) async throws -> T {
        let response = try await networkManager.request(target)
        
        // 200번대가 아니면 에러
        guard (200...299).contains(response.statusCode) else {
            throw CCAPIError.unexpectedStatusCode(response.statusCode)
        }
        
        // JSON 디코딩
        do {
            return try jsonDecoder.decode(T.self, from: response.data)
        } catch {
            throw CCAPIError.decodingFailed(error.localizedDescription)
        }
    }
    
    /// 응답이 없는 API 요청 (POST, DELETE 등)
    func request<Target: TargetType>(_ target: Target) async throws {
        let response = try await networkManager.request(target)
        
        guard (200...299).contains(response.statusCode) else {
            throw CCAPIError.unexpectedStatusCode(response.statusCode)
        }
    }
    
    /// Raw Data 응답 (이미지, 파일 다운로드 등)
    func requestData<Target: TargetType>(_ target: Target) async throws -> Data {
        let response = try await networkManager.request(target)
        
        guard (200...299).contains(response.statusCode) else {
            throw CCAPIError.unexpectedStatusCode(response.statusCode)
        }
        
        return response.data
    }
    
    /// String 응답 (텍스트 응답)
    func requestString<Target: TargetType>(_ target: Target) async throws -> String {
        let data = try await requestData(target)
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw CCAPIError.decodingFailed("Failed to decode as UTF-8 string")
        }
        
        return string
    }
}

