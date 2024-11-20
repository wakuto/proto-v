# 入力されたバイナリファイルを4つのバンクにわけて16進出力する

import sys
import os


def dump_to_banks(input_file):
    try:
        # 入力ファイルをバイナリモードで開く
        with open(input_file, "rb") as f:
            data = f.read()
        
        # 入力ファイル名の基礎部分を取得
        base_name = os.path.splitext(input_file)[0]
        
        # 出力ファイルをバンクごとに生成
        bank_files = {
            0: open(f"{base_name}.bank0.hex", "w"),
            1: open(f"{base_name}.bank1.hex", "w"),
            2: open(f"{base_name}.bank2.hex", "w"),
            3: open(f"{base_name}.bank3.hex", "w"),
        }
        
        # データをアドレスごとにバンクに振り分けて書き込む
        for address, byte in enumerate(data):
            bank = address % 4
            bank_files[bank].write(f"{byte:02X}\n")
        
        # ファイルを閉じる
        for bf in bank_files.values():
            bf.close()
    except Exception as e:
        print(f"エラーが発生しました: {e}")

# コマンドライン引数の処理
if len(sys.argv) != 2:
    print("使い方: python bank_division.py <input_file.bin>")
else:
    dump_to_banks(sys.argv[1])

