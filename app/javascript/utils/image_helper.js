/**
 * 
 * @param {*} imgUrl1 
 * @param {*} imgUrl2 
 */

export async function combineImages(imgUrl1, imgUrl2) {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');

  // 画像をロードする関数
  const loadImage = (url) => {
    return new Promise((resolve) => {
      const img = new Image();
      img.crossOrigin = "anonymous"; // 外部URLの場合はCORS設定が必要
      img.onload = () => resolve(img);
      img.src = url;
    });
  };

  // 両方の画像を読み込み
  const [img1, img2] = await Promise.all([loadImage(imgUrl1), loadImage(imgUrl2)]);

  // キャンバスのサイズを決定（例：2枚を横に並べる）
  canvas.width = img1.width + img2.width;
  canvas.height = Math.max(img1.height, img2.height);

  // キャンバスに描画
  ctx.drawImage(img1, 0, 0);             // 1枚目
  ctx.drawImage(img2, img1.width, 0);    // 2枚目（1枚目の右隣に配置）

  // 1枚の画像データ（base64）として取得
  const combinedDataUrl = canvas.toDataURL('image/png');
  
  /*
  // 結果を画面に表示
  const resultImg = document.createElement('img');
  resultImg.src = combinedDataUrl;
  document.body.appendChild(resultImg);*/

  // ...（以前のCanvas合成処理）...
  // 最後に結果のDataURLを返すと使いやすいです
  return canvas.toDataURL('image/png');
}