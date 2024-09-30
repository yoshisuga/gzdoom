//
//  UpgradeView.swift
//  GenZDZero
//
//  Created by Yoshi Sugawara on 9/20/24.
//

import SwiftUI

struct UpgradeView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var viewModel = PurchaseViewModel()
  
  var body: some View {
    GeometryReader { geo in
      VStack {
        Text("Upgrade to the Full Version!").font(.largeTitle).foregroundStyle(.yellow).padding(.vertical).frame(maxWidth: .infinity)
        switch viewModel.productFetchState {
        case .fetching:
          HStack {
            ProgressView()
            Text("Talking to the App Store...")
          }.fixedSize()
        case .fetched:
          ColoredText("^[*](colored: 'yellow') ^[Unlimited launch configurations](colored: 'orange') ^[so you can explore and play more mods!](colored: 'cyan')\n").frame(maxWidth: geo.size.width * 0.75, alignment: .leading)
          ColoredText("^[*](colored: 'yellow') ^[Unlimited touch control layouts](colored: 'orange') ^[to tailor your controls to specific mods!](colored: 'cyan')\n").frame(maxWidth: geo.size.width * 0.75, alignment: .leading)
          ColoredText("^[*](colored: 'yellow') ^[Change the](colored: 'cyan') ^[app icon](colored: 'orange') ^[and choose your favorite!](colored: 'cyan')\n").frame(maxWidth: geo.size.width * 0.75, alignment: .leading)
          ColoredText("^[*](colored: 'yellow') ^[Support the developer](colored: 'cyan') ❤️").frame(maxWidth: geo.size.width * 0.75, alignment: .leading)
        case .failed:
          Text("Failed to reach the App Store, show try again button")
        }
        Spacer()
        if case let .failed(error) = viewModel.purchaseState {
          switch error {
          case .purchasePending:
            Text("Your purchase is pending. Please wait or restore your purchase.")
          case .userCancelled:
            EmptyView()
          default:
            Text("Your purchase was not successful. Please try again.")
          }
        } else if case let .restoreFailed(error) = viewModel.purchaseState {
          switch error {
            case .userCancelled:
            EmptyView()
          default:
            Text("Your restore was not successful. Please try again.")
          }
        }
        Button {
          Task {
            await viewModel.purchase()
          }
        } label: {
          switch viewModel.purchaseState {
          case .purchasing:
            Text("Purchasing...").foregroundStyle(.white).font(.selected)
          case .purchased:
            Text("Purchased!").foregroundStyle(.green).font(.selected)
          default:
            Text("Upgrade Now").foregroundStyle(.green).font(.selected)
          }
        }.buttonStyle(.bordered).disabled(!viewModel.productFetchState.isFetched)
        HStack {
          Button {
            Task {
              await viewModel.restorePurchases()
            }
          } label: {
            switch viewModel.purchaseState {
            case .restoring:
              Text("Restoring...")
            case .restored:
              Text("Purchase Restored!")
            default:
              Text("Restore Purchase")
            }
          }.buttonStyle(.bordered).disabled(!viewModel.productFetchState.isFetched)
          Button {
            dismiss()
          } label: {
            Text("Cancel").foregroundStyle(.red)
          }.buttonStyle(.bordered)
        }
        Spacer()
      }.onAppear {
        Task {
          await viewModel.fetchProduct()
        }
      }
    }
  }
}
