#!/bin/bash
######################################################################
## リリース情報 JSON 作成スクリプト
######################################################################

# プロジェクトの絶対パス取得
export PROJECT_HOME=$(cd $(dirname $0)/../../; pwd)
# 共通環境設定
. ${PROJECT_HOME}/script/dictionary/common.sh

######################################################################
## 環境設定
######################################################################

######################################################################
## mame リリース日 JSON 生成
######################################################################

MAME_RELEASE_JSON=$(mktemp)
echo -n -e "\t[\n" > ${MAME_RELEASE_JSON}
csvformat -T ${WHATSNEW_DIR}/releases.csv | awk -F "\t" '
    BEGIN {
        m = split("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec", d, "|")
        for(o = 1; o <= m; o++) {
            months[d[o]] = sprintf("%02d",o);
        }
    }
    {
        version = $1;
        # Feb 29, 2020, 05:00 UTC
        split($2, date, /[ ,]/);
        str = date[4] "/" months[date[1]] "/" date[2];
        command = "date -d " str " '+%Y-%m-%dT%H:%M:%S.000Z'";
        command | getline var;
        print "\t\t{ \"version\": " "\"" version "\", \"date\": " "\"" var "\" },"
    }
' >> ${MAME_RELEASE_JSON}
echo -n -e "\t]\n" >> ${MAME_RELEASE_JSON}

# 最後のカンマを外す
delete_last_comma_json ${MAME_RELEASE_JSON}

# releases.json に mame をキーとして合成
echo -n -e "{ \"mame\" :\n" > ${RELEASE_JSON}
cat ${MAME_RELEASE_JSON} >> ${RELEASE_JSON}
echo -n -e "}\n" >> ${RELEASE_JSON}

# JSON をバリデーション
cat ${RELEASE_JSON} | jq . > /dev/null
if [[ $? != 0 ]]
then
    echo "[ERROR] create_mame_md ${RELEASE_JSON} JSON error."
    exit 9
fi

exit 0
