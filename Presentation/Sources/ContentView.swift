import SwiftUI
import Data
import Domain
import Core

public struct ContentView: View {
    let repository: OrderRepository
    let createOrderUseCase: CreateOrderUseCase
    let fetchOrderUseCase: FetchOrdersUseCase
    let updateOrderStatus: UpdateOrderStatusUseCase

    public init() {
        self.repository = DefaultOrderRepositoryImpl()
        self.createOrderUseCase = CreateOrderUseCaseImpl(orderRepository: repository)
        self.fetchOrderUseCase = FetchOrdersUseCaseImpl(orderRepository: repository)
        self.updateOrderStatus = UpdateOrderStatusUseCaseImpl(orderRepository: repository)
    }
    
    public var body: some View {
        VStack {
            Text("글씨 테스트")
                .font(.custom(.jalnan(.title1)))
                .padding(.vertical, .xLarge)
            
            Button {
                Task {
                    do {
                        let response = try await updateOrderStatus.execute(code: "LBAI688545", status: .inProgress)
                        print(response)
                    } catch {
                        print("error: \(error.localizedDescription)")
                    }
                }
            } label: {
                AppIcon.communityEmpty
                    .foregroundStyle(.custom(.brand(.blackSprout)))
            }
        }
    }
}

#Preview {
    ContentView()
}
