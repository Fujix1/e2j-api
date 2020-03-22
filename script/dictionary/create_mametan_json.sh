#!/bin/bash
######################################################################
## What's new J 全文検索 API 用 辞書 JSON 生成スクリプト
######################################################################

# プロジェクトの絶対パス取得
export PROJECT_HOME=$(cd $(dirname $0)/../../; pwd)
# 共通環境設定
. ${PROJECT_HOME}/script/dictionary/common.sh

######################################################################
## 検索結果 JSON 生成
######################################################################

# 検索対象を正規化しテンポラリーディレクトリに格納
SEARCH_DIC_TMP_REGEX_DIR=$(mktemp -d)
find ${WHATSNEW_DIR} -name ${WHATSNEW_NAME} | while read whatsnewj
do
    # 形態素解析したテキストと同じ正規化したテキストに対して検索し
    # 改行をまたいだ単語を検索できるようにする。（TODO: 英単語の場合は要スペース挿入）
    sed -z -r 's/([亜-熙ぁ-んァ-ヶー])\n[ |　]*([亜-熙ぁ-んァ-ヶー]+)/\1\2/g' \
        ${whatsnewj} > ${SEARCH_DIC_TMP_REGEX_DIR}/$(basename ${whatsnewj})
done

SEARCH_DIC_TMP_REGEX=$(mktemp)
cat ${SEARCH_INDEX_JSON} | jq -r '.[]' | while read word
do
    grep -1 -n --ignore-case -F ${word} ${SEARCH_DIC_TMP_REGEX_DIR}/${WHATSNEW_NAME} | awk -v word="${word}" '
        BEGIN {
            filename = ""
            lineno = 0
            buffer = ""
        }
        /^--$/ {
            print "@" word "@" filename ":" lineno "@\n"
            print buffer
            filename = ""
            buffer = ""
        }
        /^\/tmp/ {
            # ファイル名取得
            if(filename == "") {
                ibeg = match($0, "whatsnewJ");
                iend = match($0, "-") - ibeg;
                filename = substr($0, ibeg, iend);
            }
            # コンテンツ取得
            match($0, /[\-|:][0-9]+[\-|:]/);
            buffer = buffer substr($0, RSTART + RLENGTH, length($0) - 1) "\n";
        }
        END {
            # 最終行
            print "@" word "@" filename ":" lineno "@\n"
            print buffer
        }
    ' >> ${SEARCH_DIC_TMP_REGEX}
done
rm -Rf ${SEARCH_DIC_TMP_REGEX_DIR}

exit 0

# cat ${SEARCH_DIC_TMP_REGEX} | awk '
#     BEGIN {
#         word = ""
#         filename = ""
#         content = ""
#         print "{"
#     }
#     /^@.+@$/ {
#         # 新しいブロックがきたら前のブロックのコンテンツを出力
#         if(content != "") {
#             # コンテンツを JSON エスケープして出力
#             # シェルエスケープ
#             gsub("\n", "\\n", content);
#             gsub("\x22", "&#34;", content);
#             gsub("\x27", "&#39;", content);
#             command = "jq -n \x27\x22" content "\x22 | @text\x27"
#             # print command
#             command | getline var
#             print "\t\t [ " "\"" filename "\", " var " ],"
#             content = ""
#             # jq -n "\"aaa\naaa\" | @html"
#             # jq -n "\"aaa\naaa\" | @text"
#         }
#         # @へごワード@whatsnewJ_0208.txt:0@
#         split($0, token, "@")
#         # 出力中の検索語と異なれば新しい連想配列を配置
#         if(word != token[2]) {
#             # 出力中の検索単語ブロックを閉じる
#             if(word != "") {
#                 print "\t}"
#             }
#             word = token[2]
#             # 検索単語を JSON エスケープして出力
#             "jq -n \x27\x22" word "\x22 | @html\x27" | getline var
#             print "\t" var ": {"
#         }
#         # これから出力するファイル名を取得
#         filename = token[3]
#     }
#     /^[^@].+$/ {
#         content = content $0 "\n"
#     }
# ' > /dev/null
