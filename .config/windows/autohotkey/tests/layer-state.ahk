; 入力やタイマーに依存しない状態。時刻は呼び出し側から渡して検証可能にする。
class HoldLayerState {
    Active := ""
    Trigger := ""
    Started := 0
    Used := false

    Press(layer, key, now) {
        this.Observe(key)
        if this.Active != ""
            return false
        this.Active := layer
        this.Trigger := key
        this.Started := now
        this.Used := false
        return true
    }

    Observe(key) {
        if this.Active != "" && key != this.Trigger
            this.Used := true
    }

    Release(key, now) {
        if this.Active = "" || key != this.Trigger
            return false
        ; Karabiner の to_if_alone の既定値に合わせて 1 秒以内を単独押しとする。
        tap := !this.Used && now - this.Started <= 1000
        this.Active := ""
        this.Trigger := ""
        this.Used := false
        return tap
    }
}
