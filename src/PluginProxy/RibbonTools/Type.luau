export type T = {
    --- If true, this tool will inherit functionality from the Select Ribbon Tool
    useSelect: boolean?,
    
    --- Called when this tool is selected by the user
    --- @param prevTool Enum.RibbonTool The previously active tool
    Selected: ((prevTool: Enum.RibbonTool) -> ())?,

    --- Called when this tool is deselected by the user
    --- @param nextTool Enum.RibbonTool The tool that is being selected next
    Deselected: ((nextTool: Enum.RibbonTool) -> ())?,

    --- Called when the user clicks while this tool is active
    --- @param input InputObject Information about the input event
    Clicked: ((input: InputObject) -> ())?,

    --- Called when input changes while this tool is active
    --- @param input InputObject Information about the input event
    --- @param gameProcessed boolean Whether the game has already processed this input
    InputChanged: ((input: InputObject, gameProcessed: boolean) -> ())?,

    --- Called when a new input begins while this tool is active
    --- @param input InputObject Information about the input event
    --- @param gameProcessed boolean Whether the game has already processed this input
    InputBegan: ((input: InputObject, gameProcessed: boolean) -> ())?,

    --- Called when an input ends while this tool is active
    --- @param input InputObject Information about the input event
    --- @param gameProcessed boolean Whether the game has already processed this input
    InputEnded: ((input: InputObject, gameProcessed: boolean) -> ())?,
    
    --- Called when the mouse moves while this tool is active
    --- @param input InputObject Information about the mouse movement
    MouseMoved: ((input: InputObject) -> ())?,

    --- Called when the object under the mouse cursor changes while this tool is active
    --- @param target BasePart The new object under the cursor
    --- @param input InputObject Information about the mouse state
    MouseTargetChanged: ((target: BasePart, input: InputObject) -> ())?,

    --- Called when the user modifies their selection of instances
    --- @param selectedObjects {Instance} An array of currently selected instances
    SelectionChanged: ((selectedObjects: {Instance}) -> ())?,
}

return {}