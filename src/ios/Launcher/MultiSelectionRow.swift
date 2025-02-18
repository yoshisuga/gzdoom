//
//  MultiSelectionRow.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import SwiftUI

struct MultipleSelectionRow: View {
  var file: GZDoomFile
  var isSelected: Bool
  var action: () -> Void
  @GestureState private var isDragging = false
  @State private var longPressActivated = false
  private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
  @EnvironmentObject var viewModel: LauncherViewModel
  
  #if ZERO
  @State private var showUpgradeView = false
  #endif
  
  var body: some View {

    HStack {
      // Circle Dot to Indicate Category Color
      Circle()
        .fill(file.category?.color ?? Color.gray)
        .frame(width: 10, height: 10)
      
      Text(file.displayName)
        .foregroundColor(isSelected ? .red : .orange)
//        .onDrag {
//          let itemProvider = NSItemProvider(object: file.displayName as NSString)
//          let dragItem = UIDragItem(itemProvider: itemProvider)
//          dragItem.localObject = file
//          feedbackGenerator.impactOccurred()
//          longPressActivated = true
//          return itemProvider
//        }
        .id(file.displayName)
      
      Spacer()
      
      if isSelected {
        Image(systemName: "checkmark")
          .foregroundColor(.blue)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      if !longPressActivated {
        self.action()
      }
    }
    .background(isDragging ? Color.gray.opacity(0.2) : Color.clear)
//    .gesture(
//      LongPressGesture(minimumDuration: 0.5)
//        .onEnded { _ in
////          feedbackGenerator.impactOccurred()
//          longPressActivated = true
//        }
//    )
//    .simultaneousGesture(
//      DragGesture()
//        .updating($isDragging) { _, state, _ in
//          state = true
//        }
//        .onEnded { _ in
//          longPressActivated = false
////          feedbackGenerator.impactOccurred()
//          let itemProvider = NSItemProvider(object: file.displayName as NSString)
//          let dragItem = UIDragItem(itemProvider: itemProvider)
//          dragItem.localObject = file
//        }
//    )
//    .onDrag {
//      let itemProvider = NSItemProvider(object: file.displayName as NSString)
//      let dragItem = UIDragItem(itemProvider: itemProvider)
//      dragItem.localObject = file
//      return itemProvider
//    }
    .contextMenu {
      VStack {
        Text("Assign to category:")
        ForEach(FileCategory.allCases.filter { $0 != .all }, id: \.self) { category in
          Button {
//            if !PurchaseViewModel.shared.isPurchased {
//              showUpgradeView = true
//              return
//            }
            viewModel.assignFileToCategory(file: file, category: category)
          } label: {
            HStack {
              Circle()
                .fill(category.color)
                .frame(width: 10, height: 10)
              Text(category.title).foregroundStyle(category.color)
            }
          }
        }
      }
//      #if ZERO
//      .sheet(isPresented: $showUpgradeView) {
//        UpgradeView()
//      }
//      #endif
    }
//    Button(action: action) {
//      HStack {
//        Circle()
//          .fill(file.category?.color ?? Color.gray)
//          .frame(width: 10, height: 10)
//        Text(file.displayName).foregroundColor(isSelected ? .red : .orange)
//        if isSelected {
//          Spacer()
//          Image(systemName: "checkmark").foregroundColor(.red)
//        }
//      }
//    }
  }
}
