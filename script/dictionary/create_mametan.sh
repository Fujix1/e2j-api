#!/bin/bash
######################################################################
## What's new J 全文検索 API 用 インデックス JSON 生成スクリプト
######################################################################

# プロジェクトの絶対パス取得
export PROJECT_HOME=$(cd $(dirname $0)/../../; pwd)
# 共通環境設定
. ${PROJECT_HOME}/script/dictionary/common.sh

######################################################################
## 環境設定
######################################################################

# ゲーム名辞書
GAMENAMEJ_DIC=${DIC_DIR}/mame32j.lst
# 追加の MeCab ユーザー辞書
ADDITIONAL_DIC=${DIC_DIR}/mecab-mame.csv
# 生成される MeCav 辞書
MECAB_DIC=${DIC_DIR}/mecab.dic

######################################################################
## 共通関数
######################################################################

# 柔軟検索
#  引数${2}の文字列を削除した文字列を追加
#  引数${2}でスプリットした文字列を追加
#  ex.
#   麻雀水滸伝 -> [麻雀水滸伝, 水滸伝]
function extend_dic {
    cat ${1} | awk -v search="${2}" '
    /'"${2}"'/ {
        gamename = $1
        # 指定文字なしで連結した文字列
        stick = gamename;
        gsub(search, "", stick);
        #print stick
        # 指定文字でスプリットした文字列
        count = split(gamename, token, search);
        for (i=1; i <= count; i++) {
            print token[i]
        }
    }
    ' >> ${3}
}

######################################################################
## 形態素解析用 MeCab ゲーム名辞書作成
##   表層形,左文脈ID,右文脈ID,コスト,品詞,品詞細分類1,品詞細分類2,品詞細分類3,活用型,活用形,原形  ,読み  ,発音
##   ゲーム,        ,        ,1     ,名詞,一般       ,ゲーム名   ,*          ,*     ,*     ,ゲーム,げーむ,げーむ
######################################################################

MECAB_DIC_TMP=$(mktemp)
cat ${GAMENAMEJ_DIC} | awk '
	BEGIN {
		FS = "\t"
	}
    # 行の先頭はドライバー名
    /^[a-zA-Z0-9]/ {
        # ゲーム名抽出（バージョンなどを削除）
        # ゲーム名が英語の場合は最後のスペース以降の記号までをゲーム名とする
        idx = match($2, /\s[!-/:-@\[]+.+$/);
        if(idx) {
            gamename = substr($2, 0, idx - 1);
        } else {
            gamename = $2;
        }
        # 抽出したゲーム名から MeCab 辞書を作成
        count = split(gamename, token, /[＜ ]/);
        for (i=1; i <= count; i++) {
            gsub(/[ \!\-\.\x27\/,]/, "", token[i]);
            if(token[i] != "") {
                print token[i] ",-1,-1,1,名詞,固有名詞,一般,*,*,*,*,*,*,mame32j"
            }
        }
    }
' | sort | uniq > ${MECAB_DIC_TMP}

# 追加辞書
cat ${ADDITIONAL_DIC} >> ${MECAB_DIC_TMP}

# MeCab 辞書作成
/usr/lib/mecab/mecab-dict-index \
    -d /usr/share/mecab/dic/ipadic \
    -u ${MECAB_DIC} \
    -f utf-8 \
    -t utf-8 ${MECAB_DIC_TMP}
ret=$?
if [[ $ret != 0 ]]
then
    echo "[ERROR] mecab-dict-index error ${ret}."
    exit 9
fi
rm -f ${MECAB_DIC_TMP}

######################################################################
## 検索ワード辞書作成
######################################################################

# mecab で英単語・記号を除外する名詞（一般、固有、サ変接続）を抽出する
SEARCH_DIC_TMP_WORDS=$(mktemp)
find ${WHATSNEW_DIR} -maxdepth 1 -name ${WHATSNEW_NAME} | while read path
do
    # テキストファイルで、日本語改行後の行頭にスペースがある場合は
    # 連続する文章として連結する。英単語の場合は連結しない。
    SEARCH_DIC_TMP_REGEX=$(mktemp)
    sed -z -r 's/([亜-熙ぁ-んァ-ヶー])\n[ |　]*([亜-熙ぁ-んァ-ヶー]+)/\1\2/g' ${path} > ${SEARCH_DIC_TMP_REGEX}
    # MeCab による形態素解析
    mecab ${SEARCH_DIC_TMP_REGEX} \
        -u ${MECAB_DIC} \
        | egrep -v '^[!-~]+.+\*$' \
        | egrep '^.+[[:space:]]名詞,(一般|固有|サ変接続)' \
        | awk '{ print $1 }' \
        | sort \
        | uniq \
        >> ${SEARCH_DIC_TMP_WORDS}
    rm ${SEARCH_DIC_TMP_REGEX}
done

# 区切り文字列を展開して追加
SEARCH_DIC_EXTRACT=$(mktemp)
cp ${SEARCH_DIC_TMP_WORDS} ${SEARCH_DIC_EXTRACT}
extend_dic ${SEARCH_DIC_TMP_WORDS} '・' ${SEARCH_DIC_EXTRACT}
extend_dic ${SEARCH_DIC_TMP_WORDS} '？' ${SEARCH_DIC_EXTRACT}
extend_dic ${SEARCH_DIC_TMP_WORDS} '！' ${SEARCH_DIC_EXTRACT}
extend_dic ${SEARCH_DIC_TMP_WORDS} '麻雀' ${SEARCH_DIC_EXTRACT}
extend_dic ${SEARCH_DIC_TMP_WORDS} '★' ${SEARCH_DIC_EXTRACT}
extend_dic ${SEARCH_DIC_TMP_WORDS} 'II' ${SEARCH_DIC_EXTRACT}
extend_dic ${SEARCH_DIC_TMP_WORDS} '対戦' ${SEARCH_DIC_EXTRACT}
extend_dic ${SEARCH_DIC_TMP_WORDS} '[0-9]+' ${SEARCH_DIC_EXTRACT}
rm -f ${SEARCH_DIC_TMP_WORDS}

# 辞書正規化
#  英文字は大文字に統一
#  記号削除
sed -i -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' ${SEARCH_DIC_EXTRACT}
sed -i -e 's/[\[\]\:\&\-]//g' ${SEARCH_DIC_EXTRACT}

# 全ファイルの単語をサマリーする
SEARCH_DIC_SUMARRY=$(mktemp)
cat ${SEARCH_DIC_EXTRACT} \
    | sort \
    | uniq \
    > ${SEARCH_DIC_SUMARRY}
rm -f ${SEARCH_DIC_EXTRACT}

# サマリーから不要なワードを除外して JSON を生成する（TODO:ストップワード対応）
#  全角半角記号で始まる
#  1文字
#  @ を含む文字列（TODO: 単語処理用）
#  2桁の数値
#  スペースを含む
#  英文字のみ（TODO:英単語対応）
#  形態素解析及び改行処理が甘くて出力された意味不明な言葉（TODO:）
echo -n -e "[\n" > ${SEARCH_INDEX_JSON}
cat ${SEARCH_DIC_SUMARRY} \
    | egrep -v '^[！-／：　〜～。、■？（）「」＃→]' \
    | egrep -v '^[“”°–]' \
    | egrep -v '^[-+()%]+' \
    | egrep -v '@' \
    | egrep -v '^.$' \
    | egrep -v '^[0-9][0-9]$' \
    | egrep -v '^[A-Z]+$' \
    | egrep -v '\s' \
    | egrep -v -x 'うに|ます|イル|イン|エミュ|エミュレー|クロ|ゲー|コン|サウン|サポ|ション|シン|スト|スプ|タイ|ター|デー|トラ|ドライ|バイ|バー|ファ|プレ|プロ|ボー|マッ|メモ|メン|モー|ライト|ラッシュ|ラン|リー|レイ|ロー' \
    | uniq \
    | sort -r \
    | while read line
    do
        if [[ $line = "" ]]
        then
            continue
        fi
        echo -n -e "\t\""${line}"\",\n" >> ${SEARCH_INDEX_JSON}
    done
echo -n -e "]\n" >> ${SEARCH_INDEX_JSON}
rm -f ${SEARCH_DIC_SUMARRY}

# 最後のカンマを外す
delete_last_comma_json ${SEARCH_INDEX_JSON}
# JSON をバリデーション
cat ${SEARCH_INDEX_JSON} | jq . > /dev/null
if [[ $? != 0 ]]
then
    echo "[ERROR] create_mame_dic ${SEARCH_INDEX_JSON} JSON error."
    exit 9
fi

exit 0
