# Windows キーマップ

AutoHotkey **v2**、US 配列向け。Karabiner の `assets/complex_modifications` と
`homemade-keyboard/keymap.yaml` の Number・Symbol・Mouse・Hyper を移植したもの。

## 起動

- `custom.ahk`: 全レイヤー + 既存の Alt → Ctrl ショートカット（WezTerm の例外込み）。通常はこちら。
- `noKeybord.ahk`: 全レイヤーのみ。ファイル名は既存の起動設定との互換性のため維持。
- `only-symbol-layer.ahk`: F24 を送るファームウェア向けの Symbol 単体版。配列は新しいものに更新。
- `alt.ahk`: 既存の Alt ショートカットだけを使う場合の単体入口。

これらを重複起動しないこと。`#SingleInstance` は別名のスクリプト間の競合を防がない。
古いスクリプトをトレイから終了してから、必要な入口を起動する。
全レイヤー版の Number は右 Alt から `;`、Symbol は F24 から `/` に変更。
右 Alt は通常のキーに戻る。F24 は Symbol 単体版だけで使用する。

## 切り替え

| キー | 単独で押して離す | 押しながら操作 |
| --- | --- | --- |
| `;` | `;`（Shift 併用は `:`） | Number |
| `/` | `/`（Shift 併用は `?`） | Symbol |
| 右 Shift | 出力なし | Mouse |
| Esc | Esc | Hyper = 左 Ctrl + 左 Alt + 左 Shift + 左 Win |

レイヤーと Hyper は押した直後から有効。単独押しは 1 秒以内で、押している途中に
他のキー・マウスボタン・ホイールを操作していない場合のみ送る。
これは [Karabiner の `to_if_alone` の既定値](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to-if-alone/)
に合わせている。キーの自動リピートで判定時間を延長しない。

Number・Symbol・Mouse は同時に有効にならず、先に押したレイヤーが優先される。
例えば Number 中の `/` は NumLock、Symbol 中の `;` は `&` になる。
未割り当てキーは通常入力を通す。Base の `'` → Enter は既存どおり維持。
以前の `/` → Backspace、右 Shift → Esc は新しい切り替え操作に置き換わる。

## 配列

Number:

| キー | 出力 |
| --- | --- |
| Q / W / E | Home / ↑ / End |
| A / S / D | ← / ↓ / → |
| G / H | Delete / Backspace |
| Y | 0 |
| U / I / O | 7 / 8 / 9 |
| J / K / L | 4 / 5 / 6 |
| M / `,` / `.` | 1 / 2 / 3 |
| `/` | NumLock |

数字は参照先と同じ通常の数字キーなので NumLock OFF でも数字になる。
Shift や Ctrl は維持する（Shift+矢印で選択、Shift+数字は通常の記号入力）。

Symbol（IME OFF 時）:

```text
キー   Q W E R T   U I O P
出力   ' ! = % ~   _ { } |
キー   A S D       J K L ;
出力   @ # $       + ( ) &
キー   Z X C V B   M , .
出力   ` * ^ " \   - [ ]
```

IME ON 時は既存と同じ全角相当（例: `（`、`［`、`’`、`”`）を送る。

Mouse:

| キー | 操作 |
| --- | --- |
| O / K / L / `;` | マウス移動 ↑ / ← / ↓ / → |
| F | 移動速度 2 倍 |
| I / P / `/` | 左 / 右 / 中ボタン（押している間保持、ドラッグ可能） |
| `[` / `'` | 戻る / 進むボタン |
| U / J | 下 / 上スクロール |
| `,` / `.` | 左 / 右スクロール |
| A / Z / M | 音量増 / 音量減 / ミュート |
| D / C | 輝度 +10 / -10 ポイント |

移動とスクロールは OS のキーリピート待ちなしで継続する。
Mouse を先に離した場合とスクリプト終了時にも、送信したマウスボタンを解放する。
輝度変更は Windows の [WmiSetBrightness](https://learn.microsoft.com/en-us/windows/win32/wmicoreprov/wmisetbrightness-method-in-class-wmimonitorbrightnessmethods)
対応パネルだけが対象。非対応の場合は短い通知を出す。外部モニターの DDC/CI 制御は実装していない。

## 移植上の差分

- Karabiner にある機種別除外は未移植。通常の AHK ホットキーなので全キーボードに適用される。
- Mouse の追加ボタンは Karabiner の `[` / `'` を採用。40% キーボード用 YAML では対応する位置が BS / Enter になっている。
- macOS の Command / Option は Windows の Win / Alt に対応。マウス速度・スクロール量・輝度刻みは Windows 用の値。
- Symbol の IME 別全角入力は参照先への厳密な一致より、既存 AHK の動作維持を優先。
- YAML の I 長押し IME は参照した Karabiner ルールに定義がなく、今回の Number・Symbol・Mouse・Hyper の移植には含めない。

`homemade-keyboard/README.md` は分割用ファイルを案内しているが、参照時点ではそのファイルがなく、代わりに laptop 用ファイルがある。
同 README のレイヤー一覧は Base / Number / Symbol だが、実際の `keymap.yaml` には Mouse もある。
配列は README ではなく YAML と Karabiner のルールに従った。

## 検証

配列宣言の照合（Python 標準ライブラリのみ）:

```sh
python3 tests/check_reference.py /path/to/karabiner/assets/complex_modifications
```

Number・Symbol・Mouse のキーと出力を参照 JSON と全件照合する。
併せて Include 先の存在と、クラス名を大文字小文字違いの変数で上書きしていないかを検査する。
AHK の構文、ホットキーの発火、IME、機器操作を検証するものではない。

Windows での状態遷移テスト（AutoHotkey v2 の実行ファイルで実行）:

```powershell
AutoHotkey64.exe /ErrorStdOut /Validate custom.ahk
AutoHotkey64.exe /ErrorStdOut /Validate noKeybord.ahk
AutoHotkey64.exe /ErrorStdOut /Validate only-symbol-layer.ahk
AutoHotkey64.exe /ErrorStdOut tests\layer-state.test.ahk
```

[`/Validate`](https://www.autohotkey.com/docs/v2/Scripts.htm#validate) は読み込み時の構文を検査し、入力の変更を開始せずに終了する。
最後の状態遷移テストは単独押し・同時押し・リピート・長押し・レイヤー競合・解放後の復帰を検証する。
実際のキーイベント経路は次の実機確認が必要。

| 確認 | 期待結果 |
| --- | --- |
| `;` / `/` の短押し、Shift 併用、Shift を先に離す | `;` / `/` / `:` / `?` が一度だけ入力される |
| `;`+W、Shift+`;`+W、`;`+Y、`;`+`/` | ↑、選択、0、NumLock。解放時に余分な `;` が出ない |
| `/`+I / K / `,` を IME ON/OFF で実行 | `{` / `(` / `[` と各全角相当。余分な `/` が出ない |
| レイヤー中に未割り当てキー・マウスを操作 | その操作が通り、解放時の単独文字は出ない |
| 右 Shift+I を保持して O/K/L/`;`、I または右 Shift を先に離す | ドラッグと停止。クリックが押しっぱなしにならない |
| Mouse 中に F、各ホイール・追加ボタン・音量・輝度 | 表の操作。非対応輝度では通知 |
| Esc 短押し、Esc+文字、1秒超保持、押下中の終了 | Esc または Hyper。解放後に修飾キーが残らない |
| 左 Shift/Ctrl/Alt/Win を押す → Esc を押す → 最初の修飾キーを離す → 文字 → Esc を離す | Esc 保持中は4修飾を維持し、解放後に残らない |
| Number/Symbol/Mouse のトリガーを異なる順序で押す | 先のレイヤーを保持し、解放後は通常入力に戻る |
| custom の Alt+C/V、WezTerm 内の Alt+C/V | 既存ショートカットが維持され、レイヤー中は配列が優先される |

今回の Linux 作業環境では配列照合のみ実行済み。
AutoHotkey 実行環境がないため、Windows の状態遷移テスト・構文確認・実機確認は未実施。
