//
//  CustomSlider.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 8/6/24.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var value: Float
    var range: ClosedRange<Float>
    var step: Float

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            Text("Slider Value: \(value, specifier: "%.2f")")
                .padding()

            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(height: 4)

                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * 300, height: 4)

                Circle()
                    .foregroundColor(.blue)
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * 300 - 10)
                    .focusable(true)
                    .focused($isFocused)
                    .onChange(of: isFocused) { focused in
                        if focused {
                            // Handle focus change
                        }
                    }
                    .onTapGesture {
                        // Handle tap gesture
                    }
            }
            .frame(height: 20)
            .padding()
        }
        .frame(height: 50)
        .onAppear {
            // Initial focus state
            isFocused = true
        }
        .onMoveCommand { direction in
            switch direction {
            case .left:
                value = max(value - step, range.lowerBound)
            case .right:
                value = min(value + step, range.upperBound)
            default:
                break
            }
        }
    }
}
struct SliderSampleView: View {
    @State private var sliderValue: Float = 0.5

    var body: some View {
        CustomSlider(value: $sliderValue, range: 0...1, step: 0.01)
            .padding()
            .frame(width: 300)
    }
}
