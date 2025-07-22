//
//  StateCongiguration.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 19.07.2025.
//


// MARK: - State configuration
struct StateCongiguration {
    //primary button
    let isPrimaryButtonVisisble: Bool
    let isPrimaryButtonEnable: Bool
    let primaryButtonIcon: ButtonIcon
    //secondaru button
    let isSecondaryButtonVisible: Bool
    let isSecondaryButtonEnabled: Bool
    let secondaryButtonIcon: ButtonIcon
    //back button
    let isBackButtonVisible: Bool
    let isBackButtonEnabled: Bool
    //menu state
    let menuState: MenuState
    //title
    let title: String
}
// MARK: static configurations
extension StateCongiguration{
    
    static let MessengerConfiguration : StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: false,
        isPrimaryButtonEnable: false,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: false,
        isBackButtonEnabled: false,
        menuState: .none,
        title: "Messenger"
    )
    
    static let AllDissabledConfiguration : StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: false,
        isPrimaryButtonEnable: false,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: false,
        isBackButtonEnabled: false,
        menuState: .none,
        title: ""
    )
    
    static let MainListConfiguration : StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: false,
        isPrimaryButtonEnable: false,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: false,
        isBackButtonEnabled: false,
        menuState: .none,
        title: "All Events"
    )
    static let OwnerInfoConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .edit,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .info,
        title: "My Info"
    )
    
    static let SettingsConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: false,
        isPrimaryButtonEnable: false,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .settings,
        title: "Settings"
    )
    static let BroadcastEditViewConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: true,
        isSecondaryButtonEnabled: true,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: false,
        isBackButtonEnabled: false,
        menuState: .none,
        title: "Edit Broadcast"
    )
    
    static let StadPointsEditViewConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: true,
        isSecondaryButtonEnabled: true,
        secondaryButtonIcon: .obvan,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .none,
        title: "Edit schema"
    )
    
    static let ClubCollectionConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .plus,
        isSecondaryButtonVisible: true,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .none,
        title: "Add/Edit Club"
    )
    
    static let AddEditClubConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .none,
        title: "Edit Club"
    )
    
    static let VenueCollectionConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .plus,
        isSecondaryButtonVisible: true,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .none,
        title: "Add/Edit Venue"
    )

    static let AddEditVenueConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .none,
        title: "Edit Venue"
    )
    
}
