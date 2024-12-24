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
        var totalWidth = proposal.width ?? proposal.replacingUnspecifiedDimensions().width
        var width = Double.zero
        var height = subviews.isEmpty ? 0: subviews[0].sizeThatFits(.unspecified).height
        var maxAddedHeight = subviews[0].sizeThatFits(.unspecified).height
        var rows = 1
        
        for index in subviews.indices{
            
            let size = subviews[index].sizeThatFits(.unspecified)
            
            if (width + size.width) > totalWidth {
                //next row
                rows += 1
                //remove trailing spacing
                totalWidth = width - hSpacing
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
        
        if rows == 1 {
            totalWidth = subviews.reduce(0.0, { partialResult, view in
                partialResult + view.sizeThatFits(.unspecified).width
            }) + Double((subviews.count - 1)) * hSpacing
             height = subviews.reduce(0) { partialResult, view in
                max(partialResult, view.sizeThatFits(.unspecified).height)
            }
        }
        return CGSize(width: totalWidth, height: height)
    }
}

#Preview(body: {
    SmartLayout(hSpacing: 0, vSpacing: 0) {
        ForEach([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], id: \.self){ logo in
            Image(systemName:"\(logo).circle")
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                
        }
    }
    .border(.red)
})

