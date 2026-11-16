"""Karabiner の配列と AHK の宣言を照合する。実行時の入力動作は検証しない。"""
import argparse
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
KEYS = {"semicolon": ";", "slash": "/", "comma": ",", "period": ".",
        "open_bracket": "[", "quote": "'"}
SPECIAL = {"home": "Home", "end": "End", "up_arrow": "Up",
           "down_arrow": "Down", "left_arrow": "Left", "right_arrow": "Right",
           "delete_forward": "Delete", "delete_or_backspace": "Backspace",
           "keypad_num_lock": "NumLock"}
PLAIN = {"quote": "'", "equal_sign": "=", "grave_accent_and_tilde": "`",
         "hyphen": "-", "open_bracket": "[", "close_bracket": "]", "backslash": "\\"}
SHIFT = dict(zip("1234567890", "!@#$%^&*()")) | {
    "quote": '"', "equal_sign": "+", "grave_accent_and_tilde": "~",
    "hyphen": "_", "open_bracket": "{", "close_bracket": "}", "backslash": "|"}


def reference(name):
    data = json.loads((REFERENCE / (name + "-layer.json")).read_text())
    return [m for r in data["rules"] for m in r["manipulators"]
            if any(c["type"] == "variable_if" for c in m.get("conditions", []))]


class ReferenceTests(unittest.TestCase):
    def test_number(self):
        expected = {KEYS.get(m["from"]["key_code"], m["from"]["key_code"]):
                    SPECIAL.get(m["to"][0]["key_code"], m["to"][0]["key_code"])
                    for m in reference("number")}
        # Windows ではユーザー指定の旧ナビゲーションを優先する。
        expected.update({"f": "Right", "b": "Left", "p": "Up", "n": "Down",
                         "a": "Home", "e": "End", "d": "Delete", "h": "Backspace"})
        actual = dict(re.findall(r'^\s*"(.*?)", "(.*?)",?$',
                                 (ROOT / "number-layer.ahk").read_text("utf-8-sig"), re.M))
        self.assertEqual(expected, actual)

    def test_symbol(self):
        expected = {}
        for m in reference("symbol"):
            target = m["to"][0]
            table = SHIFT if "left_shift" in target.get("modifiers", []) else PLAIN
            expected[KEYS.get(m["from"]["key_code"], m["from"]["key_code"])] = table.get(
                target["key_code"], target["key_code"])
        actual = {}
        for line in (ROOT / "symbol-layer.ahk").read_text("utf-8-sig").splitlines():
            match = re.match(r'^\s*"(.*?)", \[(.*?)\],?$', line)
            if match:
                value = match[2].split(", ")[0]
                actual[match[1]] = value[1:-1].replace("``", "`")
        self.assertEqual(expected, actual)

    def test_mouse(self):
        expected = {}
        consumer = {"volume_increment": "Volume_Up", "volume_decrement": "Volume_Down",
                    "mute": "Volume_Mute", "display_brightness_increment": "BrightnessUp",
                    "display_brightness_decrement": "BrightnessDown"}
        buttons = {"button1": "LButton", "button2": "RButton", "button3": "MButton",
                   "button4": "XButton1", "button5": "XButton2"}
        motion = {("x", -1536): "MoveLeft", ("x", 1536): "MoveRight",
                  ("y", -1536): "MoveUp", ("y", 1536): "MoveDown",
                  ("vertical_wheel", 32): "WheelDown", ("vertical_wheel", -32): "WheelUp",
                  ("horizontal_wheel", 32): "WheelLeft", ("horizontal_wheel", -32): "WheelRight",
                  ("speed_multiplier", 2): "Fast"}
        for m in reference("mouse"):
            target = m["to"][0]
            if "consumer_key_code" in target:
                action = consumer[target["consumer_key_code"]]
            elif "pointing_button" in target:
                action = buttons[target["pointing_button"]]
            else:
                action = motion[next(iter(target["mouse_key"].items()))]
            expected[KEYS.get(m["from"]["key_code"], m["from"]["key_code"])] = action
        actual = dict(re.findall(r'^\s*"(.*?)", "(.*?)",?$',
                                 (ROOT / "mouse-layer.ahk").read_text("utf-8-sig"), re.M))
        self.assertEqual(expected, actual)


class StructureTests(unittest.TestCase):
    def test_global_assignments_do_not_overwrite_classes(self):
        # AHK は大文字小文字を区別せず、クラス名もグローバル変数になる。
        sources = [p.read_text("utf-8-sig") for p in ROOT.glob("*.ahk")]
        classes = {name.lower() for s in sources
                   for name in re.findall(r"^class (\w+)", s, re.M)}
        assigned = {name.lower() for s in sources
                    for name in re.findall(r"^(?:global )?(\w+)\s*:=", s, re.M)}
        self.assertEqual(set(), classes & assigned)

    def test_include_targets_exist(self):
        for path in list(ROOT.glob("*.ahk")) + list((ROOT / "tests").glob("*.ahk")):
            for target in re.findall(r'^#Include "(.*?)"', path.read_text("utf-8-sig"), re.M):
                with self.subTest(file=path.name, target=target):
                    self.assertTrue((path.parent / target.replace("\\", "/")).is_file())


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path, help="Karabiner assets/complex_modifications")
    REFERENCE = parser.parse_args().reference
    unittest.main(argv=[__file__])
