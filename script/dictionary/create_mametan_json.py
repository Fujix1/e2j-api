#!/usr/bin/python3
######################################################################
## What's new J 全文検索 API 用 辞書 JSON 生成スクリプト
######################################################################

import argparse
import re
import html
import json

# 出力 JSON
mametans = {}

# コマンドライン解析
#  usage: create_mametan_json.py [-h] file
parser = argparse.ArgumentParser()
parser.add_argument("file")
args = parser.parse_args()

# create_mametan_json.sh で作成したテンポラリー辞書を読み込み
content = ""
word = ""
filename = ""
fileline = 0
with open(args.file) as f:
    for line in f:
        # 単語のヘッダー行であれば取得して解析
        #  @筐体@whatsnewJ_0118u3.txt:0@
        if re.match(r'^@.+@whatsnewJ_.+@[0-9]+@$', line):
            # コンテンツの終わりが来たら JSON に挿入
            if content.strip() != "":
                # 連想配列にキーがなければリストを新規作成
                if word not in mametans:
                    mametans[word] = []
                # 取得したリストにコンテンツを加える
                mametans[word].append({ "filename": filename , "line": fileline, "content": content })
            # ヘッダー情報を保持
            split = re.split('@', line)
            word = split[1]
            filename = split[2]
            fileline = split[3]
            content = ""
        else:
            # ex.
            # 空行でなければコンテンツを取得
            if not re.match(r'^\n$', line):
                content = content + line

# JSON 出力
print(json.dumps(mametans, sort_keys = True, indent = 2, ensure_ascii = False))
