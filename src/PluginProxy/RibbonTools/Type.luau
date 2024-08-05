export type T = {
    useSelect: boolean?,

    Selected: ((prevTool: Enum.RibbonTool) -> ())?,
    Deselected: ((nextTool: Enum.RibbonTool) -> ())?,

    Clicked: ((input: InputObject) -> ())?,
    InputChanged: ((input: InputObject, gameProcessed: boolean) -> ())?,
    InputBegan: ((input: InputObject, gameProcessed: boolean) -> ())?,
    InputEnded: ((input: InputObject, gameProcessed: boolean) -> ())?,
    
    MouseMoved: ((input: InputObject) -> ())?,
    MouseTargetChanged: ((target: BasePart, input: InputObject) -> ())?
}

return {}