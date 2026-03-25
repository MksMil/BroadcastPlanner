///Protocol to make link with parent Entity and LocalImage Entity
///when updating LocalImages from network from network.
///Every project entity that have LocalImage property conforms to this protocol.
///Used in DataManager class in image control section.

// TODO: objectID?
protocol ImageParent {
    func assignImage(image: LocalImage, ofType: GlobalProperties.ImageType)
}
