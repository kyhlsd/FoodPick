//
//  SearchUserFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct SearchUserFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let myUserId: String?
        var searchText = ""
        var users: [Profile] = []
        var isLoading = false

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<SearchUserFeature.Alert>?

        var filteredUsers: [Profile] {
            guard let myUserId = myUserId else {
                return users
            }
            return users.filter { $0.userId != myUserId }
        }
    }

    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case searchTextChanged(String)
        case search
        case usersLoaded([Profile])
        case usersFailed(Error)
        case userTapped(Profile)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<SearchUserFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.searchUsers) var searchUsersUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .searchTextChanged(text):
                state.searchText = text
                if text.isEmpty {
                    state.users = []
                }
                return .none

            case .binding:
                return .none

            case .search:
                guard !state.searchText.isEmpty else {
                    state.users = []
                    return .none
                }

                state.isLoading = true
                let nickname = state.searchText

                return .run { send in
                    do {
                        let users = try await searchUsersUseCase.execute(nickname: nickname)
                        await send(.usersLoaded(users))
                    } catch {
                        await send(.usersFailed(error))
                    }
                }

            case let .usersLoaded(users):
                state.isLoading = false
                state.users = users
                return .none

            case let .usersFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("검색 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .userTapped(profile):
                state.destination = .otherProfile(
                    OtherProfileFeature.State(profile: profile, myUserId: state.myUserId)
                )
                return .none

            case .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}

// MARK: - Destinations
extension SearchUserFeature {
    @Reducer
    enum Destination {
        case otherProfile(OtherProfileFeature)
    }
}

extension SearchUserFeature.Destination.State: Sendable {}
