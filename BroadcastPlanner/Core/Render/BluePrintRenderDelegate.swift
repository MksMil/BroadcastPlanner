
protocol BluePrintRenderDelegate: AnyObject, BPJoystickExecutable{
  //state managment
  func updateScene()
  
  //unit managnent
  func addUnit(layoutUnit: any BluePrintEditable)
  func updateUnit(layoutUnit: any BluePrintEditable)
  func deleteUnit(id: String)
  
  //selection
  func selectUnitToRenderer(id: String)
  func deselectUnitToRenderer()
  
  //screenshot
  func resetScale(immediately: Bool)
}
