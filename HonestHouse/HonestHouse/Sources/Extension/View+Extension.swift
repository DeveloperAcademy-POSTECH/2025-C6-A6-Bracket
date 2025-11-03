//
//  View+Extension.swift
//  HonestHouse
//
//  Created by 이현주 on 11/3/25.
//

import SwiftUI

extension View {
    /*
     <사용법>
     VStack {
         Text("Content")
     }
     .screenPadding()
     */
    func screenPadding() -> some View {
        self.padding(Spacing.screen)
    }
}
