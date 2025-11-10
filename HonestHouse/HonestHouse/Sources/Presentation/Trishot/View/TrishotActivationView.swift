//
//  TrishotActivationView.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import SwiftUI

struct TrishotActivationView: View {
    @State var vm: TrishotActivationViewModel
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            VStack(alignment: .center) {
                triCircleListView(vm.currentPresetIndex)
                Spacer()
                deactivateButtonView()
            }
        }
        .task {
            vm.activateTrishot()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func triCircleListView(_ index: Int) -> some View {
        VStack(spacing: 40) {
            ForEach(Array(vm.activatedPresets.enumerated()), id: \.element.id) { index, preset in
                }
            }
        }
        .animation(.default, value: index)
    }
    }
    }
    
    private func deactivateButtonView() -> some View {
        }
    }
}

#Preview {
    TrishotActivationView(vm: .init(container: .stub))
}
