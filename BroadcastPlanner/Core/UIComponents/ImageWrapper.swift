import SwiftUI

struct ImageWrapper: View {
    @EnvironmentObject var dataManager: DataManager
    
    let id: String
    let type: GlobalProperties.ImageType
    let imageSize: ImageSizes
    let placeHolder: String
    
    @State private var image: Image
    @State private var isLoading: Bool = false
  
    @State private var isLoaded: Bool = false
    
    init(id: String?,
         type: GlobalProperties.ImageType,
         imageSize: ImageSizes,
         placeHolder: String = "photo",
         image: Image = Image(systemName: "photo")) {
        self.id = id ?? ""
        self.type = type
        self.imageSize = imageSize
        self.placeHolder = placeHolder
        self.image = Image(systemName: placeHolder)
    }
    
    var body: some View {
      Group{
        if isLoading{
          ProgressView()
        } else {
          image
            .resizable()
            .padding(isLoaded ? 0: 8)
            .opacity(!isLoaded ? 0.3: 1)
        }
      }
      .task{
        update()
      }
      .onReceive(dataManager.updatePublisher) { value in
        
        guard !id.isEmpty else { return }
        if value.0 == .images, value.1.contains(id){
          update()
        }
      }
    }
    
   @MainActor func update(){
     guard !id.isEmpty else {
       return
     }
        if id == "nil" {
          withAnimation{
            image = Image(systemName: "person.circle")
          }
        }
        isLoading = true
        Task{
            if let newImage = await dataManager.getImageWithId(id, type: type, size: imageSize){
                await MainActor.run {
                  withAnimation{
                    image = Image(uiImage: newImage)
                    isLoaded = true
                  }
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

