import Combine
import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var statusMessage: String?

    private let productIDs: [String]
    private let defaults: UserDefaults
    private let locallyVerifiedPurchasesKey = "squart.store.localVerifiedNonConsumables"
    private var transactionUpdatesTask: Task<Void, Never>?
    private var pendingVerifiedProductIDs: Set<String> = []
    private var locallyVerifiedProductIDs: Set<String> = []

    init(
        productIDs: [String] = StoreProduct.allCases.map { $0.id },
        defaults: UserDefaults = .standard
    ) {
        self.productIDs = productIDs
        self.defaults = defaults
        self.locallyVerifiedProductIDs = Set(defaults.array(forKey: locallyVerifiedPurchasesKey) as? [String] ?? [])
        self.purchasedProductIDs = self.locallyVerifiedProductIDs
        self.transactionUpdatesTask = observeTransactionUpdates()
        #if DEBUG
        print("[SquartStore] StoreManager init productIDs=\(productIDs) localVerified=\(locallyVerifiedProductIDs.sorted())")
        #endif
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var supporterProduct: Product? {
        products.first { $0.id == StoreProduct.supporter.id }
    }

    var isSupporterPurchased: Bool {
        purchasedProductIDs.contains(StoreProduct.supporter.id)
    }

    func loadProducts() async {
        #if DEBUG
        print("[SquartStore] loadProducts start")
        #endif
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.displayName < $1.displayName }
            #if DEBUG
            print("[SquartStore] loadProducts completed ids=\(products.map(\.id))")
            #endif

            if products.isEmpty {
                statusMessage = "Support options are not available yet."
            } else {
                statusMessage = nil
            }
        } catch {
            products = []
            statusMessage = "Could not load support options."
        }
    }

    func purchaseSupporter() async {
        #if DEBUG
        print("[SquartStore] purchase tapped")
        #endif
        guard let product = supporterProduct else {
            statusMessage = "Supporter purchase is not available yet."
            #if DEBUG
            print("[SquartStore] purchase blocked: supporter product unavailable")
            #endif
            return
        }

        do {
            #if DEBUG
            print("[SquartStore] purchase started product=\(product.id)")
            #endif
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                try await handle(verification)
                await refreshPurchasedProducts(policy: .mergePending)
                statusMessage = "Thank you for supporting Squart."
                #if DEBUG
                print("[SquartStore] purchase success")
                #endif
            case .userCancelled:
                statusMessage = nil
                #if DEBUG
                print("[SquartStore] purchase cancelled")
                #endif
            case .pending:
                statusMessage = "Purchase is pending approval."
                #if DEBUG
                print("[SquartStore] purchase pending")
                #endif
            @unknown default:
                statusMessage = "Purchase could not be completed."
                #if DEBUG
                print("[SquartStore] purchase unknown result")
                #endif
            }
        } catch {
            statusMessage = "Purchase failed. Please try again later."
            #if DEBUG
            print("[SquartStore] purchase failed error=\(error.localizedDescription)")
            #endif
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshPurchasedProducts(policy: .strict)
            statusMessage = isSupporterPurchased ? "Purchase restored." : "No supporter purchase was found."
            #if DEBUG
            print("[SquartStore] restore completed supporter=\(isSupporterPurchased)")
            #endif
        } catch {
            statusMessage = "Restore failed. Please try again later."
            #if DEBUG
            print("[SquartStore] restore failed error=\(error.localizedDescription)")
            #endif
        }
    }

    func refreshPurchasedProducts() async {
        await refreshPurchasedProducts(policy: .strict)
    }

    private func refreshPurchasedProducts(policy: EntitlementRefreshPolicy) async {
        #if DEBUG
        print("[SquartStore] entitlement refresh start policy=\(policy.rawValue) before=\(purchasedProductIDs.sorted()) pending=\(pendingVerifiedProductIDs.sorted()) localVerified=\(locallyVerifiedProductIDs.sorted())")
        #endif

        var entitlementIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                entitlementIDs.insert(transaction.productID)
            }
        }

        let resolvedIDs: Set<String>
        switch policy {
        case .strict:
            // Trust StoreKit entitlements; do not keep stale local cache after refund/revoke.
            resolvedIDs = entitlementIDs.union(pendingVerifiedProductIDs)
            pendingVerifiedProductIDs = pendingVerifiedProductIDs.subtracting(entitlementIDs)
        case .mergePending:
            // After a fresh purchase, entitlements may lag; keep local cache until sync catches up.
            resolvedIDs = entitlementIDs
                .union(pendingVerifiedProductIDs)
                .union(locallyVerifiedProductIDs)
            pendingVerifiedProductIDs = pendingVerifiedProductIDs.subtracting(entitlementIDs)
        }

        persistLocallyVerifiedPurchases(from: resolvedIDs)

        if purchasedProductIDs != resolvedIDs {
            purchasedProductIDs = resolvedIDs
            #if DEBUG
            print("[SquartStore] entitlement updated after=\(purchasedProductIDs.sorted()) entitlements=\(entitlementIDs.sorted()) pending=\(pendingVerifiedProductIDs.sorted()) localVerified=\(locallyVerifiedProductIDs.sorted())")
            #endif
        } else {
            #if DEBUG
            print("[SquartStore] entitlement unchanged after=\(purchasedProductIDs.sorted())")
            #endif
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else {
                    return
                }

                do {
                    try await handle(result)
                    await refreshPurchasedProducts(policy: .mergePending)
                } catch {
                    statusMessage = "A purchase update could not be verified."
                    #if DEBUG
                    print("[SquartStore] transaction update verification failed")
                    #endif
                }
            }
        }
    }

    private func handle(_ verification: VerificationResult<Transaction>) async throws {
        switch verification {
        case .verified(let transaction):
            purchasedProductIDs.insert(transaction.productID)
            pendingVerifiedProductIDs.insert(transaction.productID)
            if isLocallyPersistentNonConsumable(productID: transaction.productID) {
                locallyVerifiedProductIDs.insert(transaction.productID)
                persistLocalVerifiedIDs()
                #if DEBUG
                print("[SquartStore] persisted verified non-consumable product=\(transaction.productID)")
                #endif
            }
            #if DEBUG
            print("[SquartStore] transaction verified product=\(transaction.productID)")
            #endif
            await transaction.finish()
            #if DEBUG
            print("[SquartStore] transaction finished product=\(transaction.productID)")
            #endif
        case .unverified:
            #if DEBUG
            print("[SquartStore] transaction unverified")
            #endif
            throw StoreError.failedVerification
        }
    }

    private func persistLocallyVerifiedPurchases(from mergedProductIDs: Set<String>) {
        let stableIDs = mergedProductIDs.filter(isLocallyPersistentNonConsumable(productID:))
        guard Set(stableIDs) != locallyVerifiedProductIDs else {
            return
        }

        locallyVerifiedProductIDs = Set(stableIDs)
        persistLocalVerifiedIDs()
        #if DEBUG
        print("[SquartStore] local verified purchases updated=\(locallyVerifiedProductIDs.sorted())")
        #endif
    }

    private func persistLocalVerifiedIDs() {
        defaults.set(Array(locallyVerifiedProductIDs).sorted(), forKey: locallyVerifiedPurchasesKey)
    }

    private func isLocallyPersistentNonConsumable(productID: String) -> Bool {
        productID == StoreProduct.supporter.id
    }
}

private enum StoreError: Error {
    case failedVerification
}

private enum EntitlementRefreshPolicy: String {
    case strict
    case mergePending
}
