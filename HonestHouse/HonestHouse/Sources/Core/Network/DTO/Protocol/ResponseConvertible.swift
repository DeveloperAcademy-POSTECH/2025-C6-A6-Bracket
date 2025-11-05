//
//  ResponseConvertible.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

protocol ResponseConvertible {
    associatedtype EntityType
    func toEntity() -> EntityType
}
