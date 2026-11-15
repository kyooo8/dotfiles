; 入力やタイマーに依存しない状態。時刻は呼び出し側から渡して検証可能にする。
class HoldLayerState {
    static TapTimeoutMs := 200
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
        ; 短押しだけ文字を送る。長押しは他のキーを使わなくてもレイヤー扱い。
        tap := !this.Used && now - this.Started < HoldLayerState.TapTimeoutMs
        this.Active := ""
        this.Trigger := ""
        this.Used := false
        return tap
    }
}
