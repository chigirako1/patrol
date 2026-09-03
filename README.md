# patrol


# twt img dlder ファイル名
AnkPixiv/Twitter/<userid>/<tweetid> <imageindex> <year>-<month>-<day>.<ext>

# px dl
## ファイル名（単一）
PxDl/${userName}(${userId})/${YY}-${MM}-${DD} ${title}(${id})

## ファイル名（複数）
PxDl/${userName}(${userId})/${YY}-${MM}-${DD} ${title}(${id})/${page2}

# ブックマークレット（tempermonekey動かないので？）
## twitterの複数枚画像の横スクロールを2x2グリッド表示のサムネイルにする
javascript:(function() {     const oldStyle = document.getElementById('x-image-grid-fixer-style');     if (oldStyle) oldStyle.remove();      const style = document.createElement('style');     style.id = 'x-image-grid-fixer-style';     style.textContent = `         div[data-testid="ScrollSnap-List"] {             display: grid !important;             grid-template-columns: repeat(2, 1fr) !important;             gap: 8px !important;             overflow: visible !important;             width: 100% !important;             margin: 0 !important;             padding: 0 !important;             transform: none !important;         }         div[data-testid="ScrollSnap-List"] > div[role="presentation"] {             width: 100% !important;             max-width: none !important;             transform: none !important;         }     `;     document.head.appendChild(style);      const fixElements = () => {         const lists = document.querySelectorAll('div[data-testid="ScrollSnap-List"]');         lists.forEach(list => {             list.style.display = 'grid';             list.style.gridTemplateColumns = 'repeat(2, 1fr)';             list.style.overflow = 'visible';         });     };      fixElements();      const observer = new MutationObserver(() => {         fixElements();     });      observer.observe(document.body, {         childList: true,         subtree: true     });      console.log('X%E3%81%AE%E7%94%BB%E5%83%8F%E3%82%B0%E3%83%AA%E3%83%83%E3%83%89%E5%8C%96%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88%E3%81%8C%E4%BD%9C%E5%8B%95%E3%81%97%E3%81%BE%E3%81%97%E3%81%9F%E3%80%82'); })();



# ###############################
# twitterのメディアタブで。スクロール対応版？？？修正版URLを保存
# ###############################
const artworkUrls = new Set(); // 重複を防ぐためにURLを保存

// 取得処理の本体
const collectUrls = () => {
    // statusを含むリンクをすべて取得
    const links = document.querySelectorAll('a[href*="/status/"]');
    links.forEach(link => {
        // hrefから余計なクエリ（?s=20など）を除去して純粋なURLにする
        const cleanUrl = link.href.split('?')[0];
        
        // Twitterの個別投稿URLの形式（/user/status/123...）に一致するか確認
        if (cleanUrl.match(/\/status\/\d+/)) {
            artworkUrls.add(cleanUrl);
        } else {
            console.log('マッチせず${cleanUrl}' + cleanUrl);
        }
    });
    console.log(`現在の取得URL数: ${artworkUrls.size} 件 (スクロールを続けてください。終了時は stopCollect() を実行)`);
};

// 画面の変化（スクロールによる要素追加）を監視する設定
const observer = new MutationObserver(collectUrls);
observer.observe(document.body, { childList: true, subtree: true });

// 停止および結果出力用の関数
window.stopCollect = () => {
    observer.disconnect();
    const finalResult = Array.from(artworkUrls).sort(); // 昇順に並び替え
    console.log("--- 取得停止。最終URLリスト ---");
    console.log(finalResult.join('\n'));
    console.log(`合計: ${finalResult.length} 件`);
};

// 初回の取得実行
collectUrls();


# ###############################
# pixivの一覧でartwork ID,種別、タイトルを表示
# ###############################
// /artworks/ を含むリンクをすべて取得
const links = document.querySelectorAll('a[href*="/artworks/"]');

const artworkList = [];
const seenIds = new Set(); // 重複排除

links.forEach(link => {
    const idMatch = link.href.match(/\/artworks\/(\d+)/);
    if (!idMatch) return;
    
    const id = idMatch[1];
    if (seenIds.has(id)) return;
    seenIds.add(id);

    // 1. タイトルの取得
    const img = link.querySelector('img');
    const title = img ? img.alt : (link.innerText || "タイトル不明");

    // 2. うごイラ判定
    // link（aタグ）の親要素を辿って、その中に「再生アイコン(svg)」があるか探します
    // 近傍の親要素（作品カード全体）を探索範囲にします
    const card = link.closest('div'); 
    const isUgoira = !!card?.querySelector('svg [points*="12,18"]') || !!card?.querySelector('svg path[d*="M12 18"]');
    const type = isUgoira ? "うごイラ" : "静止画/漫画";

    artworkList.push({ id, title, type });
});

// 表形式で出力
console.table(artworkList);

// テキスト形式で出力（ID / 種類 / タイトル）
console.log("ID\t種別\tタイトル");
console.log(artworkList.map(a => `${a.id}\t${a.type}\t${a.title}`).join('\n'));
