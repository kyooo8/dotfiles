; 抑制したホットキーは InputHook に通知されないことがある。
; 出力より先に取り消すことで、ホットキー経由でも単独押しが残らない。
RunMappedKey(key, action, *) {
    global layerState, hyperState
    if IsSet(layerState)
        layerState.Observe(key)
    if IsSet(hyperState)
        hyperState.Observe(key)
    action.Call()
}
