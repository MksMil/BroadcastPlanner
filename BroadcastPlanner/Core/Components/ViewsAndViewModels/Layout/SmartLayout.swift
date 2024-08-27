import SwiftUI

// MARK: - Any View and Size Grid Layout
@available(iOS 16.0, *)
struct SmartLayout: Layout{
    
    var hSpacing: Double
    var vSpacing: Double
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var point = bounds.origin
        let maxX = bounds.width + bounds.origin.x
        var maxAddedHeight = Double.zero
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if (point.x + size.width) <= maxX {
                //current row
                subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
                point.x += size.width + hSpacing
                maxAddedHeight = max(maxAddedHeight, size.height)
            } else {
                //next row
                point.x = bounds.origin.x
                point.y += maxAddedHeight + vSpacing
                maxAddedHeight = size.height
                subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
                point.x += size.width + hSpacing
            }
        }
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return proposal.replacingUnspecifiedDimensions() }
        let totalWidth = proposal.width ?? proposal.replacingUnspecifiedDimensions().width
        var width = Double.zero
        var height = subviews.isEmpty ? 0: subviews[0].sizeThatFits(.unspecified).height
        var maxAddedHeight = subviews[0].sizeThatFits(.unspecified).height
        
        for index in subviews.indices{
            
            let size = subviews[index].sizeThatFits(.unspecified)
            
            if (width + size.width) > totalWidth {
                //next row
                if index == subviews.count - 1 {
                    // if last
                    height += size.height + vSpacing
                } else {
                    width = size.width + hSpacing
                    maxAddedHeight = size.height
                    height += maxAddedHeight + vSpacing
                }
            } else {
                //current row
                if index == subviews.count - 1 {
                    //if last
                    height -= maxAddedHeight
                    maxAddedHeight = max(maxAddedHeight, size.height)
                    height += maxAddedHeight
                } else {
                    width += size.width + hSpacing
                    height -= maxAddedHeight
                    maxAddedHeight = max(maxAddedHeight, size.height)
                    height += maxAddedHeight
                }
            }
        }
        return CGSize(width: totalWidth, height: height)
    }
}

//#Preview {
//    BPAccountInfoView(cells: UserSpecialization.allCases)
//        .environmentObject(GlobalStorage())
//}
