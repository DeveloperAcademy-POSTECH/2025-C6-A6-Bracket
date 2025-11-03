//
//  TrishotModeView.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import SwiftUI

// TODO: 민볼이 만든 뷰 이름으로 변경하기
struct TrishotModeView: View {
    
    @State var vm: TrishotModeViewModel
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            VStack(alignment: .center) {
                noticeTextView()
                Spacer()
                triCircleListView(vm.currentPresetIndex)
                Spacer()
                deactivateButtonView()
            }
        }
    }
    
    private func noticeTextView() -> some View {
        Text("Tri-shot 사용 중에는\n다른 기능을 이용할 수 없습니다.")
            .multilineTextAlignment(.center)
            .font(.num6)
            .foregroundStyle(Color.g7)
            .padding(.top, 41)
    }
    
    // TODO: - 로직 추가하기 & 뷰에 추가하기
    private func lockButtonView() -> some View {
        Circle().frame(width: 50, height: 50)
    }
    
    private func triCircleListView(_ index: Int) -> some View {
        VStack(spacing: 40) {
            ForEach(0..<3, id: \.self) { circleIndex in
                if circleIndex == index {
                    yellowCircle(circleIndex)
                } else {
                    darkCircle(circleIndex)
                }
            }
        }
        .animation(.default, value: index)
    }
    
    private func yellowCircle(_ circleIndex: Int) -> some View {
        Circle()
            .foregroundStyle(Color.yellow1)
            .frame(width: 110, height: 110)
            .overlay {
                Text("\(circleIndex + 1)")
                    .foregroundStyle(Color.g12)
            }
    }
    
    private func darkCircle(_ circleIndex: Int) -> some View {
        Circle()
            .strokeBorder(Color.yellow1)
            .foregroundStyle(Color.g12)
            .frame(width: 110, height: 110)
            .overlay {
                Text("\(circleIndex + 1)")
                    .foregroundStyle(Color.yellow1)
            }
    }
    
    private func deactivateButtonView() -> some View {
        Button {
            
        } label: {
            Text("중단하기")
        }
        .buttonStyle(DefaultButtonStyle(.activated))
    }
}

#Preview {
    TrishotModeView(vm: .init(container: .stub))
}
