import SwiftUI

// MARK: - Spacing (8 pt grid, 4 pt for fine steps)
//
// Rule: spacing inside a group is always smaller than spacing between groups.
// Typical rhythm: 8 inside a group, 24 between groups, 48 above the hero.

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

enum Layout {
    /// Leading and trailing screen margin. Every edge (content, pills, glass buttons) aligns to it.
    static let margin: CGFloat = 20
    /// Minimum touch target.
    static let minTarget: CGFloat = 44
    /// Height of the primary action.
    static let primaryHeight: CGFloat = 56
    /// Row height for win rows.
    static let rowHeight: CGFloat = 60
    /// Leading inset of row text when a row has a 28 pt icon column.
    static let rowTextInset: CGFloat = 44
}

enum Radius {
    /// Icon tiles.
    static let tile: CGFloat = 14
    /// Cards and grouped rows (continuous corners). Pills and buttons are always Capsule.
    static let card: CGFloat = 22
}
