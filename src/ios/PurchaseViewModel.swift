//
//  PurchaseViewModel.swift
//  GenZDZero
//
//  Created by Yoshi Sugawara on 9/20/24.
//


import Combine
import StoreKit
import SwiftUI

enum PurchaseError: Error {
  case purchaseVerificationFailed
  case userCancelled
  case purchasePending
  case unknownResult
  case failure(Error)
}

enum ProductFetchState: Equatable {
  case fetching, fetched(Product), failed(Error)
  
  static func == (lhs: ProductFetchState, rhs: ProductFetchState) -> Bool {
    switch (lhs, rhs) {
    case (.fetching, .fetching), (.fetched, .fetched), (.failed, .failed):
      return true
    default:
      return false
    }
  }
  
  var isFetched: Bool {
    if case .fetched = self {
      return true
    }
    return false
  }
}

class PurchaseViewModel: ObservableObject {
  static let shared = PurchaseViewModel()
  
  private let productId = "com.yoshisuga.GenZDZero.fullversion"
  
  enum PurchaseState: Equatable {
    case idle, purchasing, purchased, restoring, restored, failed(PurchaseError)
    case restoreFailed(PurchaseError)
    
    static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
      switch (lhs, rhs) {
      case (.idle, .idle), (.purchasing, .purchasing), (.purchased, .purchased),
        (.restoring, .restoring), (.restored, .restored), (.failed, .failed):
        return true
      default:
        return false
      }
    }
  }
  
  @Published var productFetchState: ProductFetchState = .fetching
  @Published var purchaseState: PurchaseState = .idle
  
  private var cancellable: AnyCancellable?
  @Published var isPurchased = false
  
  func fetchProduct() async {
    DispatchQueue.main.async {
      self.productFetchState = .fetching
    }
    do {
      let products = try await Product.products(for: [productId])
      if let product = products.first {
        DispatchQueue.main.async {
          self.productFetchState = .fetched(product)
        }
      }
    } catch {
      productFetchState = .failed(error)
    }
  }
  
  func purchase() async {
    guard productFetchState.isFetched,
    case let .fetched(product) = productFetchState else { return }
    DispatchQueue.main.async {
      self.purchaseState = .purchasing
    }
    do {
      let result = try await product.purchase()
      switch result {
      case .success(let verification):
        switch verification {
        case .verified:
          DispatchQueue.main.async {
            self.purchaseState = .purchased
          }
        case .unverified:
          DispatchQueue.main.async {
            self.purchaseState = .failed(.purchaseVerificationFailed)
          }
        }
      case .userCancelled:
        DispatchQueue.main.async {
          self.purchaseState = .failed(.userCancelled)
        }
      case .pending:
        DispatchQueue.main.async {
          self.purchaseState = .failed(.purchasePending)
        }
      @unknown default:
        DispatchQueue.main.async {
          self.purchaseState = .failed(.unknownResult)
        }
      }
    } catch {
      purchaseState = .failed(.failure(error))
    }
  }

  func restorePurchases() async {
    DispatchQueue.main.async {
      self.purchaseState = .restoring
    }
    do {
      try await AppStore.sync()
      for await transaction in Transaction.currentEntitlements {
        switch transaction {
        case .verified(let transaction):
          if transaction.productID == productId {
            DispatchQueue.main.async {
              self.purchaseState = .restored
            }
          }
        case .unverified:
          DispatchQueue.main.async {
            self.purchaseState = .restoreFailed(.purchaseVerificationFailed)
          }
        }
      }
    } catch {
      DispatchQueue.main.async {
        self.purchaseState = .restoreFailed(.failure(error))
      }
    }
  }

  func checkIfPurchased() async {
    for await transaction in Transaction.currentEntitlements {
      if case let .verified(trans) = transaction {
        if trans.productID == productId {
          isPurchased = true
          break
        }
      }
    }
  }
  
  init() {
    cancellable = $purchaseState.sink(receiveValue: { state in
      if state == .purchased || state == .restored {
        self.isPurchased = true
        PurchaseViewModel.shared.isPurchased = true
      }
    })
    Task {
      await checkIfPurchased()
    }
  }
}
